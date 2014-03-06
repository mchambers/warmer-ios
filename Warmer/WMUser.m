//
//  WMUser.m
//  Warmer
//
//  Created by Marc Chambers on 3/5/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMUser.h"

@implementation WMUser

+(NSDictionary*)JSONKeyPathsByPropertyKey{
    return @{
             @"userID":@"_id",
             @"signedUp":@"signed_up",
             @"genderSeeking":@"gender_seeking",
             @"outFor":@"out_for",
             @"outWith":@"out_with"
             };
}

@end
