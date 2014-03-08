//
//  WMLocationManager.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMLocationManager.h"

@interface WMLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, weak) NSTimer *requestTimer;
@property (nonatomic, weak) NSDate *requestDate;

@property (nonatomic, strong) NSMutableDictionary* peripheralData;
@property (nonatomic, strong) CBPeripheralManager* peripheralManager;

@end

@implementation WMLocationManager
{
    NSMutableDictionary* knownBeaconStates;
    NSMutableDictionary* pendingBeaconRegionEntryMessages;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [self setDelegate:self];
        [self setMaximumAcceptableLocationAge:-10.0];
        
        if ([self respondsToSelector:@selector(setActivityType:)] &&
            [self respondsToSelector:@selector(setPausesLocationUpdatesAutomatically:)])
        {
            [self setActivityType:CLActivityTypeOther];
            [self setPausesLocationUpdatesAutomatically:NO];
        }
    }
    
    return self;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if(!_isBroadcasting) return; // so fuckin wut
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on, so start broadcasting
        [peripheral startAdvertising:self.peripheralData];
        if(self.beaconBroadcastBeginHandler)
            self.beaconBroadcastBeginHandler();
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff || peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        // Bluetooth isn't on. Stop broadcasting
        _isBroadcasting=NO;
        
        //[peripheral stopAdvertising];
        
        if(self.beaconBroadcastEndHandler)
            self.beaconBroadcastEndHandler();
    }
    
    if(self.beaconBroadcastStateChanged)
    {
        self.beaconBroadcastStateChanged(peripheral.state);
    }
}

-(void)setBroadcastRegion:(CLBeaconRegion *)broadcastRegion
{
    if(_isBroadcasting)
    {
        [self stopBeaconBroadcast];
    }
    
    _broadcastRegion=broadcastRegion;
    
    self.peripheralData = [_broadcastRegion peripheralDataWithMeasuredPower:nil];
}

-(void)startBeaconBroadcast
{
    if(!_isBroadcasting)
    {
        _isBroadcasting=YES;
        
        // Start the peripheral manager
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    }
}

-(void)stopBeaconBroadcast
{
    if(_isBroadcasting)
    {
        [self.peripheralManager stopAdvertising];
    }
}

- (void)resetRequestTimer
{
    [[self requestTimer] invalidate];
    [self setRequestTimer:nil];
    [self setRequestDate:nil];
}

- (void)startRequestTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[self locationUpdateTimeOutInterval]
                                                      target:self
                                                    selector:@selector(handleTimeOut:)
                                                    userInfo:nil
                                                     repeats:NO];
    [self setRequestTimer:timer];
    [self setRequestDate:[NSDate date]];
}

- (void)startUpdatingLocation
{
    [self resetRequestTimer];
    if ([self locationUpdateTimeOutHandler] &&
        [self locationUpdateTimeOutInterval] > 0.0)
    {
        [self startRequestTimer];
    }
    
    [super startUpdatingLocation];
}

- (void)handleTimeOut:(NSTimer *)timer
{
    if ([self locationUpdateTimeOutHandler])
    {
        if (!self.locationUpdateTimeOutHandler())
        {
            [self stopUpdatingLocation];
            [self resetRequestTimer];
        }
        else
        {
            [self startRequestTimer];
        }
    }
}


#pragma mark - Location manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ([self locationUpdateHandler])
    {
        self.locationUpdateHandler(newLocation, oldLocation);
    }
    
    if ([self acceptableLocationHandler])
    {
        NSTimeInterval timeDelta = [[self requestDate] timeIntervalSinceNow];
        
        static float accuracy = 1500.0f;
        
        if (accuracy < 5000.0f)
        {
            accuracy += fabs(timeDelta) * 200.0f;
        }
        
        if ([newLocation horizontalAccuracy] <= accuracy &&
            [[newLocation timestamp] timeIntervalSinceNow] > [self maximumAcceptableLocationAge])
        {
            accuracy = 1500.0f;
            [self stopUpdatingLocation];
            [self resetRequestTimer];
            self.acceptableLocationHandler(newLocation);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([self authorizationStatusChangeHandler])
    {
        self.authorizationStatusChangeHandler(status);
    }
}


-(void)dealloc
{
    knownBeaconStates=nil;
}

-(CLRegionState)stateForBeaconRegion:(NSString*)regionIdentifier
{
    if(!knownBeaconStates || !knownBeaconStates[regionIdentifier])
    {
        return CLRegionStateUnknown;
    }
    
    return [knownBeaconStates[regionIdentifier] intValue];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    [beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeacon* beacon=(CLBeacon*)obj;
        
        if(pendingBeaconRegionEntryMessages[region.identifier] && [pendingBeaconRegionEntryMessages[region.identifier] isEqualToValue:@(YES)])
        {
            [pendingBeaconRegionEntryMessages removeObjectForKey:region.identifier];
            
            if(self.beaconEnterRegionHandler)
            {
                self.beaconEnterRegionHandler(beacon, region);
            }
        }
        else
        {
            if(self.beaconRangingHandler)
            {
                self.beaconRangingHandler(beacon, region);
            }
            
        }
    }];
    
}

// we force all our region updates through this and track it ourselves
// in case we get duplicate notifications or miss a region enter/exit notification
-(void)updateStateForBeaconRegion:(CLRegion*)region newState:(CLRegionState)state
{
    CLRegionState lastKnownStateForRegion;
    
    if(knownBeaconStates==nil)
    {
        knownBeaconStates=[NSMutableDictionary dictionary];
    }
    
    if(knownBeaconStates[region.identifier]==nil)
    {
        lastKnownStateForRegion=CLRegionStateUnknown;
    }
    else
    {
        lastKnownStateForRegion=[knownBeaconStates[region.identifier] intValue];
    }
    
    if(state==lastKnownStateForRegion)
    {
        return; // we already notified our homies of this state for this region
    }
    
    knownBeaconStates[region.identifier]=@(state);
    
    void (^regionDepartBlock)(void)=^(void){
        [self stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        self.beaconLeaveRegionHandler((CLBeaconRegion*)region);
    };
    
    switch(state)
    {
        case CLRegionStateUnknown:
        {
            if(lastKnownStateForRegion==CLRegionStateInside)
            {
                regionDepartBlock();
            }
            break;
        }
        case CLRegionStateInside:
        {
            // start ranging for beacons, queue a region entry message
            // when we have our first hard beacon
            
            if(!pendingBeaconRegionEntryMessages)
            {
                pendingBeaconRegionEntryMessages=[NSMutableDictionary dictionary];
            }
            
            pendingBeaconRegionEntryMessages[region.identifier]=@(YES); // we'll consider ourselves having "entered" the region once
                                                                        // we've successfully ranged our first beacon
            
            [self startRangingBeaconsInRegion:(CLBeaconRegion*)region];
            break;
        }
        case CLRegionStateOutside:
        {
            if(lastKnownStateForRegion==CLRegionStateInside)
            {
                regionDepartBlock();
            }
            break;
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if([region isKindOfClass:[CLBeaconRegion class]])
    {
        [self updateStateForBeaconRegion:region newState:state];
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if([region isKindOfClass:[CLBeaconRegion class]])
    {
        [self updateStateForBeaconRegion:region newState:CLRegionStateInside];
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if([region isKindOfClass:[CLBeaconRegion class]])
    {
        [self updateStateForBeaconRegion:region newState:CLRegionStateOutside];
    }
    
}

@end
