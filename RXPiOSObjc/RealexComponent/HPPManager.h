//
//  HPPManager.h
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HPPManagerDelegate <NSObject>

-(void)HPPManagerCompletedWithResult:(NSDictionary*)result;
-(void)HPPManagerFailedWithError:(NSError*)error;
-(void)HPPManagerFailedWithPayError:(NSArray*)errors;
-(void)HPPManagerCancelled;

@end

@interface HPPManager : NSObject

//Methods
- (void)HPPViewControllerCompletedWithResult:(NSString *)result;
- (void)HPPViewControllerFailedWithError:(nullable NSError *)error;
- (void)HPPViewControllerManagerFailedWithPayError:(NSString *)result;
- (void)HPPViewControllerWillDismiss;

@property (nonatomic) NSURL *HPPRequestProducerURL;
@property (nonatomic) NSString *HPPResponseConsumerURL;
@property (nonatomic) NSURL *HPPURL;

@property (nonatomic, strong) NSString *merchantId;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *autoSettleFlag;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *secretKey;
@property (nonatomic, strong) NSString *cardPaymentButtonText;

@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *supplementaryData;

@property (nonatomic, weak) id<HPPManagerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *HPPRequest;

-(void)presentViewInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
