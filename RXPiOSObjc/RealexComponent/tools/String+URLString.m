//
//  String+URLString.m
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import "String+URLString.h"
@import CommonCrypto;

@implementation  NSString (String_URLString)
-(NSString*)stringByAddingPercentEncodingForURLQueryValue {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"-._~"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

-(NSString *)base64Encoded {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        return [data base64EncodedStringWithOptions:0];
    }
    return nil;
}

-(NSString *)base64Decoded {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

-(NSString*)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
