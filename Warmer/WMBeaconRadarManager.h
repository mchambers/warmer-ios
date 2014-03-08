//
//  WMBeaconRadarManager.h
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMLocationManager.h"
#import "WMBeaconConstants.h"
#import "WMClient.h"

extern NSString* const kWarmerBeaconBeginBroadcastNotification;
extern NSString* const kWarmerBeaconEndBroadcastNotification;
extern NSString* const kWarmerBeaconBeaconsNearbyNotification;
extern NSString* const kWarmerBeaconNoMoreBeaconsNearbyNotification;

@interface WMBeaconRadarManager : NSObject

@property (nonatomic, retain) WMLocationManager* locationManager;
@property (nonatomic, assign, readonly) BOOL currentlyInRangeOfBeacons;

// notifications the radar manager can emit:
/*
 new sighting!
 
 new meseeks!
 
 new chat request!
 
 */

+(id)sharedInstance;

-(void)beginBroadcasting:(WMScan*)scan;
-(void)beginMonitoring;

@end
