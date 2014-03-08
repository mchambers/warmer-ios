//
//  WMBeaconRadarManager.m
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMBeaconRadarManager.h"

NSString* const kWarmerBeaconBeginBroadcastNotification = @"com.ApproachLabs.Warmer.Notifications.BeaconBroadcastBegin";
NSString* const kWarmerBeaconEndBroadcastNotification = @"com.ApproachLabs.Warmer.Notifications.BeaconBroadcastEnd";
NSString* const kWarmerBeaconBeaconsNearbyNotification = @"com.ApproachLabs.Warmer.Notifications.BeaconBeaconsNearby";
NSString* const kWarmerBeaconNoMoreBeaconsNearbyNotification = @"com.ApproachLabs.Warmer.Notifications.BeaconNoMoreNearby";

@implementation WMBeaconRadarManager
{
    int _currentNumRegions;
}

+ (id)sharedInstance {
    static dispatch_once_t once;
    static WMBeaconRadarManager *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[WMBeaconRadarManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init
{
    self=[super init];
    if(self)
    {
        WMLocationManager *locationManager = [WMLocationManager new];
        
        [self setLocationManager:locationManager];
        
        [[self locationManager] setAcceptableLocationHandler:^(CLLocation *location) {
            //
        }];
        
        [[self locationManager] setAuthorizationStatusChangeHandler:^(CLAuthorizationStatus status) {
            
            switch (status) {
                case kCLAuthorizationStatusNotDetermined:
                case kCLAuthorizationStatusRestricted:
                case kCLAuthorizationStatusDenied:
                    //pass: use the current ip address to determine location
                    break;
                case kCLAuthorizationStatusAuthorized:
                    //[[self locationManager] startUpdatingLocation];
                    break;
            }
            
        }];
    }
    return self;
}

-(void)beginBroadcasting:(WMScan*)scan
{
    [self.locationManager setBeaconBroadcastStateChanged:^(CBPeripheralManagerState state) {
    }];
    
    [self.locationManager setBeaconBroadcastBeginHandler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kWarmerBeaconBeginBroadcastNotification object:nil];
    }];
    
    [self.locationManager setBeaconBroadcastEndHandler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kWarmerBeaconEndBroadcastNotification object:nil];
        
    }];
    
    self.locationManager.broadcastRegion=[scan beaconRegion];
    [self.locationManager startBeaconBroadcast];
}

-(void)incCurrentNumRegions
{
    _currentNumRegions++;
}

-(void)decCurrentNumRegions
{
    _currentNumRegions--;
}

-(BOOL)currentlyInRangeOfBeacons
{
    return (_currentNumRegions>0);
}

-(void)beginMonitoring
{
    if(!self.locationManager) return;
    
    __weak WMBeaconRadarManager* weakSelf=self;
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        NSUUID* beaconUUID=[[NSUUID alloc] initWithUUIDString:WMBeaconUUID];
        CLBeaconRegion* proxRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:WMBeaconRegionIdentifier];
        
        [self.locationManager startMonitoringForRegion:proxRegion];
        
        [self.locationManager setBeaconRangingHandler:^(CLBeacon* beacon, CLBeaconRegion* region) {
            // report updated range so we can build a distance graph
        }];
        
        [self.locationManager setBeaconEnterRegionHandler:^(CLBeacon* beacon, CLBeaconRegion* region) {
            // aw yus;
            // notify the sighting service that WE'VE GOT ONE
            
            // if we weren't in range of any before and now we are, notify the listeners
            BOOL wasInRange=[weakSelf currentlyInRangeOfBeacons];
            [weakSelf incCurrentNumRegions];
            
            if(!wasInRange)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kWarmerBeaconBeaconsNearbyNotification object:nil];
            }
            
            [[WMClient sharedInstance] newSighting:[WMBeacon beaconWithCLBeacon:beacon] completion:^(WMSighting *user, NSError *error) {
                NSLog(@"%@", user);
            }];
        }];
        
        [self.locationManager setBeaconLeaveRegionHandler:^(CLBeaconRegion* region) {
            // notify the UI we're no longer in range of this particular human
            
            // if we're already interacting with them, maybe we just gray them out?
            
            // if that was the last person we were in range of, let's alert the listeners
            // we're out of the woods for now.
            [weakSelf decCurrentNumRegions];
            
            if([weakSelf currentlyInRangeOfBeacons])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kWarmerBeaconNoMoreBeaconsNearbyNotification object:nil];
            }
        }];
    }
    else
    {
        NSLog(@"Couldn't start monitoring for beacons, either because the operating system doesn't support it or beacon monitoring is not enabled on the device.");
    }
}

@end
