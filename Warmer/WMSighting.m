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
        @"userID":@"userId",
        @"sightedUserID":@"sightedUserId"
    };
}
@end
