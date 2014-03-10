//
//  WMRadarViewController.h
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMAppDelegate.h"
#import "WMClient.h"
#import "WMBeaconRadarManager.h"

@interface WMRadarViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *myProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *myName;
@property (weak, nonatomic) IBOutlet UIButton *myProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction)myProfileButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *userImages;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *userImageButtons;

@end
