//
//  HPPViewController.h
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HPPManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface HPPViewController : UIViewController
-(void)loadRequest:(NSURLRequest*)request;

@property (nonatomic, strong) HPPManager* manager;
@end

NS_ASSUME_NONNULL_END
