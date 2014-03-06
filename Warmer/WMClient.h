//
//  WMHTTPSessionManager.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <Overcoat.h>
#import "WMJSONRequestSerializer.h"

#import "WMAccessToken.h"
#import "WMUser.h"
#import "WMScan.h"
#import "WMBeacon.h"
#import "WMSighting.h"

extern NSString* const kWarmerAPILocalDevelopmentURL;
extern NSString* const kWarmerAPIStagingURL;
extern NSString* const kWarmerAPIProductionURL;

@interface WMClient : OVCClient

@property (nonatomic, retain) WMAccessToken* currentAccessToken;
@property (nonatomic, retain) WMUser* currentUser;

-(void)getProfileWithID:(NSString*)userId completion:(void (^)(WMUser* user, NSError *error))completion;
-(void)beginScan:(BOOL)scan completion:(void (^)(WMScan* user, NSError *error))completion;

+(id)sharedInstance;

@end
