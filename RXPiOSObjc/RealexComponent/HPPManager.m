//
//  HPPManager.m
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import "HPPManager.h"
#import "Dictionary+URLDictionary.h"
#import "String+URLString.h"
#import "HPPViewController.h"

@class HPPViewController;

@interface HPPManager ()
@property (nonatomic, readwrite, strong) HPPViewController *hppViewController;
@end

@implementation HPPManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hppViewController = [HPPViewController new];
        self.hppViewController.manager = self;
    }
    return self;
}

-(void)presentViewInViewController:(UIViewController *)viewController {
    if (![self.HPPURL.absoluteString  isEqual: @""]) {
        [self getHPPRequest];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.hppViewController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }else {
        //Error
        NSLog(@"HPPURL can't be blank");
    }
}

-(NSData*)getParametersString {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
        
    parameters[@"TIMESTAMP"] = timestamp;
    
    if (![self.merchantId  isEqual: @""]) {
        parameters[@"MERCHANT_ID"] = self.merchantId;
    }
    if (![self.account  isEqual: @""]) {
        parameters[@"ACCOUNT"] = self.account;
    }
    if (![self.orderId  isEqual: @""]) {
        parameters[@"ORDER_ID"] = self.orderId;
    }
    if (![self.amount  isEqual: @""]) {
        parameters[@"AMOUNT"] = self.amount;
    }
    if (![self.currency  isEqual: @""]) {
        parameters[@"CURRENCY"] = self.currency;
    }
    if (![self.autoSettleFlag  isEqual: @""]) {
        parameters[@"AUTO_SETTLE_FLAG"] = self.autoSettleFlag;
    }
    if (![self.cardPaymentButtonText  isEqual: @""]) {
        parameters[@"CARD_PAYMENT_BUTTON"] = self.cardPaymentButtonText;
    }
    if (![self.HPPResponseConsumerURL  isEqual: @""]) {
        parameters[@"MERCHANT_RESPONSE_URL"] = self.HPPResponseConsumerURL;
    }

    if  (self.supplementaryData) {
        for (NSString *key in self.supplementaryData.allKeys) {
            NSString *value = self.supplementaryData[key];
            [parameters setValue:value forKey:key];
        }
    }
    
    NSString *strToHash = [NSString stringWithFormat:@"%@.%@.%@.%@.%@", timestamp, self.merchantId, self.orderId, self.amount, self.currency];
    NSString *calc1 = [strToHash sha1];
    NSString *sha1Final = [[NSString stringWithFormat:@"%@.%@",calc1, self.secretKey ?: @""] sha1];
    
    parameters[@"SHA1HASH"] = sha1Final;
    
    parameters[@"RETURN_TSS"] = @"0";
    parameters[@"DCC_ENABLE"] = @"0";
    parameters[@"HPP_VERSION"] = @"2";
    parameters[@"HPP_LANG"] = @"ES";
    parameters[@"HPP_POST_DIMENSIONS"] = self.HPPRequestProducerURL.absoluteString;
    parameters[@"HPP_POST_RESPONSE"] = [NSString stringWithFormat:@"%@://%@", self.HPPRequestProducerURL.scheme, self.HPPRequestProducerURL.host];

    return [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
}

-(void)getHPPRequest {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:YES];
    });
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.HPPURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.f];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [self getParametersString];
        
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        @try {
            NSData *receiveData = data;
            if (receiveData) {
                self.HPPRequest = [NSJSONSerialization JSONObjectWithData:receiveData options:0 error:nil];

                if ([[self.HPPRequest allKeys] containsObject:@"errors"]) {
                    [self.delegate HPPManagerFailedWithPayError:self.HPPRequest[@"errors"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:NO];
                            [self.hppViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
                        });
                    return;
                }

                [self getPaymentForm];
            }else {
                [self.delegate HPPManagerFailedWithError:error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hppViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
                });
            }
        } @catch (NSException *exception) {
            [self.delegate HPPManagerFailedWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hppViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];

    [dataTask resume];
}

-(void)getPaymentForm {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:YES];
    });
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.HPPRequest[@"hppPayByLink"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.f];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
    
    [self.hppViewController loadRequest:request];
}

#pragma mark - Actions

-(void)HPPViewControllerCompletedWithResult:(NSString *)result {
    NSDictionary *decodedResponse = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (decodedResponse) {
        [self.delegate HPPManagerCompletedWithResult:decodedResponse];
    }else {
        [self HPPViewControllerFailedWithError:nil];
    }
}

- (void)HPPViewControllerFailedWithError:(nullable NSError *)error {
    [self.delegate HPPManagerFailedWithError:error];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hppViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    });
}


- (void)HPPViewControllerManagerFailedWithPayError:(NSString *)result {
    NSRange r1 = [result rangeOfString:@"Error: "];
    NSRange r2 = [result rangeOfString:@"<BR>"];
    NSRange r3 = [result rangeOfString:@"Mensaje: "];
    
    NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    NSString *sub = [result substringWithRange:rSub];
    
    NSString *sub2 = [result substringFromIndex:r3.location + + r3.length];

    NSDictionary *error = @{
        @"resultCode": sub,
        @"errorMessage": sub2
    };
    
    [self.delegate HPPManagerFailedWithPayError:@[error]];
}


- (void)HPPViewControllerWillDismiss {
    [self.delegate HPPManagerCancelled];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hppViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
