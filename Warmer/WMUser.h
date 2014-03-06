//
//  WMUser.h
//  Warmer
//
//  Created by Marc Chambers on 3/5/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <Mantle.h>

@interface WMUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, retain) NSString* userID;
@property (nonatomic, retain) NSString* slogan;
@property (nonatomic, retain) NSString* pictureURL;
@property (nonatomic, retain) NSNumber* rating;
@property (nonatomic, retain) NSDate*   signedUp;
@property (nonatomic, retain) NSString* gender;
@property (nonatomic, retain) NSString* genderSeeking;
@property (nonatomic, retain) NSString* outFor;
@property (nonatomic, retain) NSString* outWith;

@end
