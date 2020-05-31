//
//  String+URLString.h
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface  NSString (String_URLString)
-(NSString*)stringByAddingPercentEncodingForURLQueryValue;

-(NSString*)base64Encoded;
-(NSString*)base64Decoded;

-(NSString*)sha1;
@end

NS_ASSUME_NONNULL_END
