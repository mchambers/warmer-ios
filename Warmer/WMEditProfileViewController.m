//
//  WMEditProfileViewController.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMEditProfileViewController.h"
#import <JLRoutes.h>
#import <UIImageView+AFNetworking.h>

@interface WMEditProfileViewController ()
{
    NSDictionary* genders;
    NSDictionary* genderIndices;
}

@end

const int MAX_SLOGAN_CHARS=35;

@implementation WMEditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.userImageView.layer.cornerRadius=160/2;
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
    
    self.userSloganText.delegate=self;
}

-(void)updateCharCountLabel
{
    self.sloganCharCountLabel.text=[NSString stringWithFormat:@"%lu/%i", (unsigned long)self.userSloganText.text.length, MAX_SLOGAN_CHARS];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.sloganCharCountLabel.hidden==YES)
    {
        self.sloganCharCountLabel.alpha=0.0f;
        self.sloganCharCountLabel.hidden=NO;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sloganCharCountLabel.alpha=1.0f;
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^(void){
        self.sloganCharCountLabel.alpha=0.0f;
    } completion:^(BOOL finished) {
        if(finished) self.sloganCharCountLabel.hidden=YES;
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self updateCharCountLabel];
    if(string && string.length>0 && textField.text.length>=MAX_SLOGAN_CHARS) return NO;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.user.slogan=self.userSloganText.text;
    
    [self.view endEditing:YES];
    return YES;
}

-(void)populate
{
    if(!self.user) return;
    NSLog(@"Populating");
    
    if(self.user.pictureURL)
    {
        [self.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.user.pictureURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.userImageView.image=image;
            self.userImageView.layer.masksToBounds=YES;
            self.userImageView.layer.cornerRadius=self.userImageView.frame.size.width/2;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
    
    if(self.user.name)
        self.userNameLabel.text=self.user.name;
    
    if(self.user.slogan)
        self.userSloganText.text=self.user.slogan;
    
    if(genders[self.user.gender])
        self.yourGender.selectedSegmentIndex=[genders[self.user.gender] intValue];
    
    if(self.user.genderSeeking && genders[self.user.genderSeeking])
        self.lookingForGender.selectedSegmentIndex=[genders[self.user.genderSeeking] intValue];
    else
        self.lookingForGender.selectedSegmentIndex=[genders[@"either"] intValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[WMClient sharedInstance] getProfileWithID:@"me" completion:^(WMUser *user, NSError *error) {
        NSLog(@"%@", user);
        
        self.user=user;
        
        [[WMClient sharedInstance] setCurrentUser:self.user];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSLog(@"Calling populate");
            [self populate];
        });
    }];
}

- (IBAction)yourGenderChanged:(id)sender {
    // WE AREN'T THAT PROGRESSIVE YET :/
}

- (IBAction)lookingForGenderChanged:(id)sender {
    self.user.genderSeeking=genderIndices[@(self.lookingForGender.selectedSegmentIndex)];
}

- (IBAction)saveButtonTapped:(id)sender {
    // perform save
    [[WMClient sharedInstance] updateProfile:self.user completion:^(WMUser *user, NSError *error) {
        NSLog(@"%@", user);
        
        [[WMClient sharedInstance] setCurrentUser:user];
        
        if(!error)
        {
            // hide everything else
            // animate the avatar moving into place
            // do the crossfade transition
            [UIView animateWithDuration:0.5 animations:^{
                self.userNameLabel.alpha=0.0f;
                self.userSloganText.alpha=0.0f;
                self.sloganCharCountLabel.alpha=0.0f;
                self.yourGender.alpha=0.0f;
                self.lookingForGender.alpha=0.0f;
                self.saveButton.alpha=0.0f;
                self.lookingForGenderCallout.alpha=0.0f;
                self.yourGenderCallout.alpha=0.0f;
                
                self.userImageView.frame=CGRectMake(128, 252, 64, 64);
                self.userImageView.layer.cornerRadius=64.0/2.0;
            } completion:^(BOOL finished) {

                [JLRoutes routeURL:[NSURL URLWithString:@"/scan"]];
            }];

        }
    }];
}
@end
