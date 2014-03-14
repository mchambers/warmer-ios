//
//  WMProfileCard.m
//  Warmer
//
//  Created by Marc Chambers on 3/13/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMProfileCard.h"
#import <UIImage+ImageEffects.h>

@interface WMProfileCard ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) UIView* coverView;
@property (nonatomic, strong) WMProfileCard* _self;
@end

@implementation WMProfileCard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)thumbsUpTapped:(id)sender {
    [self dismiss];
}

- (IBAction)noThanksTapped:(id)sender {
    [self dismiss];
}

-(void)setUser:(WMUser *)user
{
    _user=user;
    
    
}

-(void)show
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    self.containerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    [self.containerView setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
    
    [self setCenter:CGPointMake(CGRectGetMidX(self.containerView.frame), -CGRectGetMaxY(self.containerView.frame))];
    
    [keyWindow addSubview:self.containerView];
    
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    
    self.coverView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    self.coverView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    
    [self.containerView addSubview:self.coverView];
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.coverView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }];
    [self.containerView addSubview:self];
    
    self.animator=[[UIDynamicAnimator alloc] initWithReferenceView:self.containerView];
    // Use UIKit Dynamics to make the alertView appear.
    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:self.containerView.center];
    snapBehaviour.damping = 0.95f;
    [self.animator addBehavior:snapBehaviour];
}

-(void)dismiss
{
    __block WMProfileCard* strongProfile=self;
    
    [UIView animateWithDuration:0.3 animations:^(void){
        strongProfile.coverView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
        strongProfile=nil;
    } completion:^(BOOL finished) {
        [self.containerView removeFromSuperview];
    }];
    
    [self.animator removeAllBehaviors];
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self]];
    gravityBehaviour.gravityDirection = CGVectorMake(0.0f, 10.0f);
    [self.animator addBehavior:gravityBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    [itemBehaviour addAngularVelocity:-M_PI_2 forItem:self];
    [self.animator addBehavior:itemBehaviour];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
