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

@end
