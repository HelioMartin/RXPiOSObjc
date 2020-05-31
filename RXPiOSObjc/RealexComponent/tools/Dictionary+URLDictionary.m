//
//  Dictionary+URLDictionary.m
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dictionary+URLDictionary.h"
#import "String+URLString.h"

@implementation NSDictionary (Dictionary_URLDictionary)
-(NSString*)stringFromHttpParameters {
    __block NSMutableArray *parameterArray = [NSMutableArray new];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *percentEscapedKey = [(NSString*)key stringByAddingPercentEncodingForURLQueryValue];
        NSString *percentEscapedValue = [(NSString*)obj stringByAddingPercentEncodingForURLQueryValue];
        [parameterArray addObject:[NSString stringWithFormat:@"%@=%@",percentEscapedKey, percentEscapedValue]];
    }];
    
    return [parameterArray componentsJoinedByString:@"&"];
}
@end
