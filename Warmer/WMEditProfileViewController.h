//
//  WMEditProfileViewController.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMClient.h"

@interface WMEditProfileViewController : UIViewController

@property (nonatomic, strong) WMUser* user;

@property (weak, nonatomic) IBOutlet UISegmentedControl *yourGender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lookingForGender;

- (IBAction)yourGenderChanged:(id)sender;
- (IBAction)lookingForGenderChanged:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
