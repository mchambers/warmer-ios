//
//  WMLocationManager.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface WMLocationManager : CLLocationManager <CBPeripheralManagerDelegate>

@property (nonatomic, assign) CLLocationAccuracy minimumAcceptableLocationAccuracy;
@property (nonatomic, assign) NSTimeInterval maximumAcceptableLocationAge;
@property (nonatomic, assign) NSTimeInterval locationUpdateTimeOutInterval;
@property (nonatomic, copy) void (^locationUpdateHandler)(CLLocation *newLocation, CLLocation *oldLocation);
@property (nonatomic, copy) BOOL (^locationUpdateTimeOutHandler)();
@property (nonatomic, copy) void (^acceptableLocationHandler)(CLLocation *location);
@property (nonatomic, copy) void (^authorizationStatusChangeHandler)(CLAuthorizationStatus status);
@property (nonatomic, copy) void (^beaconRangingHandler)(CLBeacon* beacon, CLBeaconRegion* region);
@property (nonatomic, copy) void (^beaconEnterRegionHandler)(CLBeacon* beacon, CLBeaconRegion* region);
@property (nonatomic, copy) void (^beaconLeaveRegionHandler)(CLBeaconRegion* region);
@property (nonatomic, copy) void (^beaconBroadcastStateChanged)(CBPeripheralManagerState state);
@property (nonatomic, copy) void (^beaconBroadcastBeginHandler)(void);
@property (nonatomic, copy) void (^beaconBroadcastEndHandler)(void);
@property (nonatomic, copy) void (^beaconBroadcastErrorHandler)(CBPeripheralManagerState state);


// beacon broadcast stuffs
@property (nonatomic, retain) CLBeaconRegion* broadcastRegion;
@property (nonatomic, readonly) BOOL isBroadcasting;

@property (nonatomic, strong) NSMutableDictionary* peripheralData;
@property (nonatomic, strong) CBPeripheralManager* peripheralManager;

-(void)startBeaconBroadcast;
-(void)stopBeaconBroadcast;

@end
