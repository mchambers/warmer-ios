//
//  WMScan.h
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <Mantle.h>
#import <CoreLocation/CoreLocation.h>
#import "WMBeaconConstants.h"

/*
 var scanSchema=new Schema({
 userId: { type: Schema.Types.ObjectId, ref: 'User' },
 startedAt: { type: Date, default: Date.now },
 device: String,
 major: Number,
 minor: Number,
 ttl: Number,
 active: Boolean
 });
 */

@interface WMScan : MTLModel <MTLJSONSerializing>

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSDate* startedAt;
@property (nonatomic, retain) NSString* device;
@property (nonatomic, retain) NSNumber* major;
@property (nonatomic, retain) NSNumber* minor;
@property (nonatomic, retain) NSNumber* ttl;
@property (nonatomic, assign) BOOL active;

-(CLBeaconRegion*)beaconRegion;

@end
