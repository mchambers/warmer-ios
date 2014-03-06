//
//  WMBeacon.m
//  Warmer
//
//  Created by Marc Chambers on 3/5/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMBeacon.h"

@implementation WMBeacon

-(CLBeaconRegion*)asBeaconRegion
{
    NSUUID* uuid=[[NSUUID alloc] initWithUUIDString:WMBeaconUUID];
    CLBeaconRegion* beacon=[[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[self.major unsignedShortValue] minor:[self.minor unsignedShortValue] identifier:WMBeaconRegionIdentifier];
    return beacon;
}

@end
