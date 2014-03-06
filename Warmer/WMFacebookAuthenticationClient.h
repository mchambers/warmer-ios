//
//  WMFacebookAuthenticationClient.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMClient.h"

@interface WMFacebookAuthenticationClient : WMClient

@property (nonatomic, strong) NSString* facebookAccessToken;

-(void)authenticateWithFacebookAccessToken:(NSString*)accessToken completion:(void (^)(WMAccessToken* token, NSError *error))completion;

@end
