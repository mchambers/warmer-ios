//
//  WMAccessToken.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface WMAccessToken : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSDate* expires;
@property (nonatomic, strong) NSString* refreshToken;

@end
