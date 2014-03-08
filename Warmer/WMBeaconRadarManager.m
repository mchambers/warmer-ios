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

@implementation WMBeaconRadarManager

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

-(void)beginMonitoring
{
    if(!self.locationManager) return;
    
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
            
            [[WMClient sharedInstance] newSighting:[WMBeacon beaconWithCLBeacon:beacon] completion:^(WMSighting *user, NSError *error) {
                NSLog(@"%@", user);
            }];
        }];
        
        [self.locationManager setBeaconLeaveRegionHandler:^(CLBeaconRegion* region) {
            // notify the UI we're no longer in range of this particular human
            
            // if we're already interacting with them, maybe we just gray them out?
            
        }];
    }
    else
    {
        NSLog(@"Couldn't start monitoring for beacons, either because the operating system doesn't support it or beacon monitoring is not enabled on the device.");
    }
}

@end
