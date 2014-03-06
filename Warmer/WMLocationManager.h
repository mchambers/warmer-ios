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
@property (nonatomic, copy) void (^beaconRangingHandler)(NSArray* beacons, CLBeaconRegion* region);
@property (nonatomic, copy) void (^beaconEnterRegionHandler)(CLBeacon* beacon, CLBeaconRegion* region);
@property (nonatomic, copy) void (^beaconLeaveRegionHandler)(CLBeaconRegion* region);
@property (nonatomic, copy) void (^beaconBroadcastErrorStateOccurred)(CBPeripheralManagerState state);

// beacon broadcast stuffs
@property (nonatomic, retain) CLBeaconRegion* broadcastRegion;
@property (nonatomic, readonly) BOOL isBroadcasting;

-(void)startBeaconBroadcast;
-(void)stopBeaconBroadcast;

@end
