//
//  WMBeacon.h
//  Warmer
//
//  Created by Marc Chambers on 3/5/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "MTLModel.h"
#import <CoreLocation/CoreLocation.h>
#import "WMBeaconConstants.h"

@interface WMBeacon : MTLModel

@property (nonatomic, strong) NSNumber* major;
@property (nonatomic, strong) NSNumber* minor;
@property (nonatomic, strong) NSNumber* ttl;

-(CLBeaconRegion*)asBeaconRegion;

@end
