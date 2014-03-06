//
//  WMSighting.h
//  Warmer
//
//  Created by Marc Chambers on 3/5/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <Mantle.h>

/*
 var sightingSchema=new Schema({
 userId: { type: Schema.Types.ObjectId, ref: 'User' },
 sightedUserId: { type: Schema.Types.ObjectId, ref: 'User' },
 expires: { type: Date, default: Date.now },
 read: Boolean
 });

 */

@interface WMSighting : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString* sightingID;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* sightedUserID;

@end
