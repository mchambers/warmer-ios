//
//  WMHTTPSessionManager.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMClient.h"

NSString* const kWarmerAPILocalDevelopmentURL=@"http://0.0.0.0:3000/api";
NSString* const kWarmerAPIStagingURL=@"";
NSString* const kWarmerAPIProductionURL=@"http://warmer.cloudapp.net/api";
NSString* const kWarmerNotificationThumbPostedSuccessfully=@"com.ApproachLabs.Warmer.Notifications.ThumbPostedSuccessfully";
NSString* const kWarmerNotificationThumbPostedFailed=@"com.ApproachLabs.Warmer.Notifications.ThumbPostFailed";

@implementation WMClient

static id sharedManager = nil;

+ (void)initialize {
    if (self == [WMClient class]) {
        sharedManager = [self clientWithBaseURL:[NSURL URLWithString:kWarmerAPIProductionURL] account:nil];
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

-(void)getSightingsWithCompletion:(void (^)(NSArray* sightings, NSError *error))completion
{
    NSString* urlForResource=[NSString stringWithFormat:@"users/%@/sightings", self.currentUser.userID];
    
    [self GET:urlForResource parameters:nil resultClass:[WMSighting class] resultKeyPath:nil completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        NSLog(@"%@", responseObject);
        completion(responseObject, error);
    }];
}

-(NSError*)notFoundError
{
    return [NSError errorWithDomain:@"com.ApproachLabs.Warmer.Client.Error" code:404 userInfo:nil];
}

-(void)newSighting:(WMBeacon*)beacon completion:(void (^)(WMSighting* sighting, NSError *error))completion
{
    if(!beacon)
    {
        return;
    }
    
    [self POST:@"sightings" object:beacon resultClass:nil resultKeyPath:nil completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)updateProfile:(WMUser*)user completion:(void (^)(WMUser* user, NSError *error))completion
{
    if(!user)
    {
        completion(nil, [self notFoundError]);
        return;
    }
    
    if(!user.userID)
    {
        completion(nil, [self notFoundError]);
        return;
    }
    
    NSString* urlToUpdate=[NSString stringWithFormat:@"users/%@", user.userID];
    
    [self PUT:urlToUpdate object:user resultClass:[WMUser class] resultKeyPath:nil completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if(error)
        {
            completion(nil, error);
        }
        else
        {
            completion((WMUser*)responseObject, nil);
        }
    }];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      object:(MTLModel<MTLJSONSerializing>*)object
                     resultClass:(Class)resultClass
                   resultKeyPath:(NSString *)keyPath
                      completion:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSError *error))block
{
    NSDictionary* dictObj=[MTLJSONAdapter JSONDictionaryFromModel:object];
    return [self POST:@"sightings" parameters:dictObj resultClass:resultClass resultKeyPath:nil completion:block];
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     object:(MTLModel<MTLJSONSerializing>*)object
                    resultClass:(Class)resultClass
                  resultKeyPath:(NSString *)keyPath
                     completion:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSError *error))block
{
    NSDictionary* dictObj=[MTLJSONAdapter JSONDictionaryFromModel:object];
    return [self PUT:URLString parameters:dictObj resultClass:resultClass resultKeyPath:keyPath completion:block];
}

-(void)thumbUser:(WMUser*)thumbedUser like:(BOOL)like
{
    if(!self.currentUser)
        return;
    
    NSString* path=[NSString stringWithFormat:@"users/%@/thumb", thumbedUser.userID];
    
    [self POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWarmerNotificationThumbPostedSuccessfully object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWarmerNotificationThumbPostedFailed object:nil];
    }];
}

-(void)beginScan:(BOOL)scan completion:(void (^)(WMScan* scan, NSError *error))completion
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
            completion(responseObject, nil);
        }
    }];
}

@end
