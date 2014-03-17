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

extern NSString* const kWarmerNotificationThumbPostedSuccessfully;
extern NSString* const kWarmerNotificationThumbPostedFailed;

@interface WMClient : OVCClient

@property (nonatomic, retain) WMAccessToken* currentAccessToken;
@property (nonatomic, retain) WMUser* currentUser;

// profile
-(void)updateProfile:(WMUser*)user completion:(void (^)(WMUser* user, NSError *error))completion;
-(void)getProfileWithID:(NSString*)userId completion:(void (^)(WMUser* user, NSError *error))completion;

// scans
-(void)beginScan:(BOOL)scan completion:(void (^)(WMScan* user, NSError *error))completion;

// sightings
-(void)newSighting:(WMBeacon*)beacon completion:(void (^)(WMSighting* sighting, NSError *error))completion;
-(void)getSightingsWithCompletion:(void (^)(NSArray* sightings, NSError *error))completion;

// thumbs
-(void)thumbUser:(WMUser*)thumbedUser like:(BOOL)like;

+(id)sharedInstance;

@end
