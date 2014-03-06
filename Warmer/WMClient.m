//
//  WMHTTPSessionManager.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMClient.h"

NSString* const kWarmerAPILocalDevelopmentURL=@"http://localhost:3000/api";
NSString* const kWarmerAPIStagingURL=@"";
NSString* const kWarmerAPIProductionURL=@"";

@implementation WMClient

static id sharedManager = nil;

+ (void)initialize {
    if (self == [WMClient class]) {
        sharedManager = [self clientWithBaseURL:[NSURL URLWithString:kWarmerAPILocalDevelopmentURL] account:nil];
    }
}

+ (id)sharedInstance {
    return sharedManager;
}

-(void)setCurrentAccessToken:(WMAccessToken *)currentAccessToken
{
    _currentAccessToken=currentAccessToken;
    if(self.requestSerializer && [self.requestSerializer respondsToSelector:@selector(setAccessToken:)])
    {
        [self.requestSerializer performSelector:@selector(setAccessToken:) withObject:_currentAccessToken];
    }
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        self.requestSerializer=[WMJSONRequestSerializer serializer];
    }
    
    return self;
}

-(void)getProfileWithID:(NSString*)userId completion:(void (^)(WMUser* user, NSError *error))completion
{
    if(!userId)
    {
        completion(nil, nil);
        return;
    }
    
    NSString* userProfilePath=[NSString stringWithFormat:@"users/%@", userId];
    
    [self GET:userProfilePath parameters:nil resultClass:[WMUser class] resultKeyPath:nil completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if(responseObject && [[responseObject class] isSubclassOfClass:[WMUser class]])
        {
            completion(responseObject, nil);
        }
        else {
            completion(nil, nil);
        }
    }];
}

-(void)updateProfile:(WMUser*)user completion:(void (^)(WMUser* user, NSError *error))completion
{
    if(!user)
    {
        completion(nil, nil);
        return;
    }
    
    
}

-(void)beginScan:(BOOL)scan completion:(void (^)(WMScan* user, NSError *error))completion
{
    if(!self.currentUser)
    {
        return;
    }
    
    NSString* path=[NSString stringWithFormat:@"users/%@/scan", self.currentUser.userID];
    
    [self POST:path parameters:nil resultClass:[WMScan class] resultKeyPath:nil completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if(responseObject)
        {
            NSLog(@"%@", responseObject);
        }
    }];
}
@end
