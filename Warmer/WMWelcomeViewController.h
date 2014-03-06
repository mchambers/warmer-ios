//
//  WMWelcomeViewController.h
//  Warmer
//
//  Created by Marc Chambers on 3/4/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Facebook.h>
#import "WMFacebookAuthenticationClient.h"
#import <MBProgressHUD.h>

@interface WMWelcomeViewController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;

@end
