//
//  WMEditProfileViewController.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMEditProfileViewController.h"
#import <JLRoutes.h>

@interface WMEditProfileViewController ()
{
    NSDictionary* genders;
    NSDictionary* genderIndices;
}

@end

@implementation WMEditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    genders=@{  @"male":@(0),
                @"female":@(1),
                @"either":@(2)
            };
    
    genderIndices=@{@(0):@"male",
                    @(1):@"female",
                    @(2):@"either"
                    };
}

-(void)populate
{
    if(genders[self.user.gender])
    {
        self.yourGender.selectedSegmentIndex=[genders[self.user.gender] intValue];
    }
    
    if(self.user.genderSeeking && genders[self.user.genderSeeking])
    {
        self.lookingForGender.selectedSegmentIndex=[genders[self.user.genderSeeking] intValue];
    }
    else
    {
        self.lookingForGender.selectedSegmentIndex=[genders[@"either"] intValue];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [[WMClient sharedInstance] getProfileWithID:@"me" completion:^(WMUser *user, NSError *error) {
        NSLog(@"%@", user);
        
        self.user=user;
        
        [[WMClient sharedInstance] setCurrentUser:self.user];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self populate];
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)yourGenderChanged:(id)sender {
}

- (IBAction)lookingForGenderChanged:(id)sender {
    self.user.genderSeeking=genderIndices[@(self.lookingForGender.selectedSegmentIndex)];
}

- (IBAction)saveButtonTapped:(id)sender {
    // perform save
    
    [JLRoutes routeURL:[NSURL URLWithString:@"/scan"]];
}
@end
