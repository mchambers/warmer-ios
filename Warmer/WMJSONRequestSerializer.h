//
//  WMJSONRequestSerializer.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "AFURLRequestSerialization.h"
#import "WMAccessToken.h"

@interface WMJSONRequestSerializer : AFJSONRequestSerializer

@property (nonatomic, retain) WMAccessToken* accessToken;

@end
