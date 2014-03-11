//
//  WMSighting.m
//  Warmer
//
//  Created by Marc Chambers on 3/5/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMSighting.h"

@implementation WMSighting

+(NSDictionary*)JSONKeyPathsByPropertyKey
{
    return @{
        @"sightingID":@"_id",
        @"user":@"userId",
        @"sightedUser":@"sightedUser"
    };
}

+(NSValueTransformer*)sightedUserJSONTransformer
{
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[WMUser class]];
}

+(NSValueTransformer*)expiresJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(id dateString) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        //2014-03-08T09:42:12.170Z
        //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        
        NSDate* myDate;
        NSError* error;
        
        if (![dateFormatter getObjectValue:&myDate
                                 forString:dateString
                                     range:nil
                                     error:&error]) {
            return nil;
        }
        
        return myDate;
    }];
}
@end
