//
//  WMEditProfileViewController.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMClient.h"

@interface WMEditProfileViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) WMUser* user;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userSloganText;
@property (weak, nonatomic) IBOutlet UILabel *sloganCharCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *yourGenderCallout;
@property (weak, nonatomic) IBOutlet UILabel *lookingForGenderCallout;

@property (weak, nonatomic) IBOutlet UISegmentedControl *yourGender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lookingForGender;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)yourGenderChanged:(id)sender;
- (IBAction)lookingForGenderChanged:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
