//
//  WMAppDelegate.h
//  Warmer
//
//  Created by Marc Chambers on 3/3/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JLRoutes.h>
#import "WMLocationManager.h"
#import "WMBeaconConstants.h"

@interface WMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WMLocationManager* locationManager;

@end
