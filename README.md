# RXPiOSObjc

Classes to implement Addon Payments HPP pay method in a Objective-C iOS project.

## Sample usage

```ObjC
HPPManager *hppManager = [HPPManager new];
hppManager.delegate = self;
    
hppManager.HPPRequestProducerURL = [NSURL URLWithString:@"PRODUCER_URL"];
hppManager.HPPURL = [NSURL URLWithString:@"ADDONPAYMENTS_PAY_URL"];
hppManager.HPPResponseConsumerURL = @"RESPONSE_URL";
       
hppManager.merchantId = @"";
hppManager.account = @"";
hppManager.amount = @"";
hppManager.orderId = @"";
   
hppManager.autoSettleFlag = @"0";
hppManager.currency = @"EUR";
hppManager.cardPaymentButtonText = @"Pay";

hppManager.secretKey = @"";
    
    
[hppManager presentViewInViewController:self];
```

## Author

Helio Martín - helio.martin@icloud.com

## License

RXPiOSObjc is available under the MIT license. See the LICENSE file for more info.
