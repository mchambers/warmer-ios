//
//  WMProfileCard.h
//  Warmer
//
//  Created by Marc Chambers on 3/13/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMUser.h"

@protocol WMProfileCardDelegate <NSObject>
@optional
@end

@interface WMProfileCard : UIView
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *slogan;
@property (weak, nonatomic) IBOutlet UIScrollView *reviews;
@property (weak, nonatomic) IBOutlet UIButton *noThanksButton;

@property (weak, nonatomic) IBOutlet UIButton *thumbsUpButton;
@property (nonatomic, retain) WMUser* user;
@property (nonatomic, retain) id<WMProfileCardDelegate> delegate;
- (IBAction)thumbsUpTapped:(id)sender;
- (IBAction)noThanksTapped:(id)sender;

-(void)show;
-(void)dismiss;

@end
