//
//  ViewController.m
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import "ViewController.h"
#import "HPPManager.h"

@interface ViewController () <HPPManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onPay:(id)sender {
    HPPManager *hppManager = [HPPManager new];
    hppManager.delegate = self;
    
    hppManager.HPPRequestProducerURL = [NSURL URLWithString:@""];
    hppManager.HPPURL = [NSURL URLWithString:@""];
    hppManager.HPPResponseConsumerURL = @"";
    
    hppManager.merchantId = @"";
    hppManager.account = @"";
    hppManager.amount = @"";
    hppManager.orderId = @"";
    
    hppManager.autoSettleFlag = @"0";
    hppManager.currency = @"EUR";
    hppManager.cardPaymentButtonText = @"Pagar ahora";

    hppManager.secretKey = @"";
    
    
    
    [hppManager presentViewInViewController:self];
}

#pragma mark - HPPManagerDelegate

- (void)HPPManagerCompletedWithResult:(NSDictionary *)result {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Result" message:result.description preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    }]];

    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)HPPManagerFailedWithError:(nonnull NSError *)error {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    }]];

    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)HPPManagerFailedWithPayError:(nonnull NSArray *)errors {
    if (errors) {
        NSMutableString *strErrors = [NSMutableString new];

        for (NSDictionary *error in errors) {
            [strErrors appendFormat:@"%@ -> %@", error[@"resultCode"], error[@"errorMessage"]];
            [strErrors appendString:@"\n"];
        }

        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:strErrors preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        }]];

        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)HPPManagerCancelled {
}

@end
