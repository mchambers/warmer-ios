//
//  WMScan.m
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMScan.h"

@implementation WMScan

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return nil;
}

-(CLBeaconRegion*)beaconRegion
{
    NSUUID* uuid=[[NSUUID alloc] initWithUUIDString:WMBeaconUUID];
    CLBeaconRegion* beacon=[[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[self.major unsignedShortValue] minor:[self.minor unsignedShortValue] identifier:WMBeaconRegionIdentifier];
    return beacon;
}

@end
