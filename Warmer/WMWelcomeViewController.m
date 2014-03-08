//
//  WMWelcomeViewController.m
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMWelcomeViewController.h"
#import "WMEditProfileViewController.h"

@interface WMWelcomeViewController ()

@end

@implementation WMWelcomeViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue.destinationViewController class] isSubclassOfClass:[WMEditProfileViewController class]])
    {
        
    }
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    self.loginLabel.text=@"There was an error connecting to your Facebook account. Please try again.";
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // Retrieve the FB access token.
    NSString* accessToken=[[[FBSession activeSession] accessTokenData] accessToken];
    
    // Pass it to our platform to log da fuq in
    WMFacebookAuthenticationClient* fbAuthClient=[[WMFacebookAuthenticationClient alloc] init];
    
    [fbAuthClient authenticateWithFacebookAccessToken:accessToken completion:^(WMAccessToken *token, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(token)
        {
            self.fbLoginButton.delegate=nil;

            [[WMClient sharedInstance] setCurrentAccessToken:token];
            [self performSegueWithIdentifier:@"EditProfile" sender:self];
        }
        else
        {
            
        }
    }];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    [UIView animateWithDuration:0.3f animations:^(void){
        self.fbLoginButton.alpha=0.0f;
        self.loginLabel.alpha=0.0f;
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.loginLabel.text=@"Facebook lets us know you're real. We'll never post on your behalf.";
}

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
	// Do any additional setup after loading the view.
    
    self.fbLoginButton.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
