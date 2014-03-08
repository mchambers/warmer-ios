//
//  WMFacebookAuthenticationClient.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMFacebookAuthenticationClient.h"

@implementation WMFacebookAuthenticationClient

- (instancetype)init
{
    return [self initWithBaseURL:[NSURL URLWithString:kWarmerAPIProductionURL]];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        self.requestSerializer=[AFJSONRequestSerializer serializer];
    }
    
    return self;
}

-(void)authenticateWithFacebookAccessToken:(NSString*)accessToken completion:(void (^)(WMAccessToken* token, NSError *error))completion
{
    if(!accessToken)
        completion(nil, nil);
    
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Token %@", accessToken] forHTTPHeaderField:@"Authorization"];
    
//    [self.requestSerializer setAuthorizationHeaderFieldWithToken:accessToken];
    
    [self GET:@"auth/facebook" parameters:nil resultClass:[WMAccessToken class] resultKeyPath:nil completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        
        NSLog(@"%@", responseObject);
        
        completion(responseObject, nil);
        
    }];
    
}
@end
