//
//  WMAccessToken.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMAccessToken.h"

@implementation WMAccessToken

+(NSDictionary*)JSONKeyPathsByPropertyKey
{
    return @{
             @"accessToken":@"access_token",
             @"refreshToken":@"refresh_token",
             };
}

@end
