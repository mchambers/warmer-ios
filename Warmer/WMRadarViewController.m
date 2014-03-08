//
//  WMRadarViewController.m
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMRadarViewController.h"
#import <UIImageView+AFNetworking.h>

@interface WMRadarViewController ()

@property (nonatomic, weak) WMLocationManager* locationManager;

@end

@implementation WMRadarViewController
{
    BOOL _broadcastAnimationPlaying;
    CAShapeLayer* circle;
    CAShapeLayer* radarRing1;
    CGPathRef newPath;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconBroadcastDidBegin:) name:kWarmerBeaconBeginBroadcastNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconBroadcastDidEnd:) name:kWarmerBeaconEndBroadcastNotification object:nil];

}

-(void)flashStatusMessage
{
    
}

-(void)playBroadcastAnimation
{
    [self cancelStatusLabel];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 3.0;
    animationGroup.repeatCount = INFINITY;
    
    // Set up the shape of the circle
    int radius = 25;
    int radiusMultiplier=16;
    
    if(circle)
        [circle removeFromSuperlayer];
    if(radarRing1)
        [radarRing1 removeFromSuperlayer];
    
    circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    newPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, (2.0*(radius*radiusMultiplier)), 2.0*(radius*radiusMultiplier)) cornerRadius:(radius*radiusMultiplier)].CGPath;
    
    radarRing1=[CAShapeLayer layer];
    radarRing1.path=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*(radius*1), 2.0*(radius*1)) cornerRadius:(radius*1)].CGPath;
    
    // Center the shape in self.view
    circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius,
                                  CGRectGetMidY(self.view.frame)-radius);
    
    CGPoint finalCenter=CGPointMake(CGRectGetMidX(self.view.frame)-(radius*radiusMultiplier),
                                    CGRectGetMidY(self.view.frame)-(radius*radiusMultiplier));
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3].CGColor;
    circle.lineWidth = 2;
    
    radarRing1.fillColor=[[UIColor orangeColor] colorWithAlphaComponent:0.3].CGColor;
    radarRing1.strokeColor=[[UIColor orangeColor] colorWithAlphaComponent:0.3].CGColor;
    radarRing1.lineWidth=1;
    
    radarRing1.position=CGPointMake(CGRectGetMidX(self.view.frame)-(radius*1),
                                    CGRectGetMidY(self.view.frame)-(radius*1));
    
    // Add to parent layer
    [self.view.layer addSublayer:circle];
    //[self.view.layer addSublayer:radarRing1];
    
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    drawAnimation.duration            = 3.0;
    drawAnimation.repeatCount         = 0;
    drawAnimation.autoreverses=NO;
    drawAnimation.fromValue = (id)circle.path;
    drawAnimation.toValue   = (__bridge id)newPath;
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    // need to keep it centered
    CABasicAnimation *drawAnimation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    drawAnimation2.duration            = 3.0;
    drawAnimation2.repeatCount         = 0;
    drawAnimation2.autoreverses=NO;
    drawAnimation2.fromValue = [NSValue valueWithCGPoint:circle.position];
    drawAnimation2.toValue   = [NSValue valueWithCGPoint:finalCenter];
    drawAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [animationGroup setAnimations:@[drawAnimation, drawAnimation2]];
    [circle addAnimation:animationGroup forKey:@"circle"];
    
    // set up the radar ring animation
    /*
    CABasicAnimation *radarRing1Pulse=[CABasicAnimation animationWithKeyPath:@"lineWidth"];
    radarRing1Pulse.duration=0.2;
    radarRing1Pulse.repeatCount=0;
    radarRing1Pulse.fromValue=@(1.0f);
    radarRing1Pulse.toValue=@(3.0f);
    radarRing1Pulse.autoreverses=YES;
    radarRing1Pulse.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup* radarRing1Group=[CAAnimationGroup animation];
    radarRing1Group.duration=3.0f;
    radarRing1Group.repeatCount=INFINITY;
    radarRing1Group.animations=@[radarRing1Pulse];
    
    [radarRing1 addAnimation:radarRing1Group forKey:@"radarRing1"];
    */
    _broadcastAnimationPlaying=YES;
}

-(void)updateCurrentUser
{
    WMUser* user=[[WMClient sharedInstance] currentUser];
    if(!user)
        return;
    
    self.myName.text=user.name;
    
    if(user.pictureURL)
    {
        [self.myProfileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:user.pictureURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.myProfileImage.image=image;
            self.myProfileImage.layer.masksToBounds=YES;
            self.myProfileImage.layer.cornerRadius=self.myProfileImage.frame.size.width/2;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
}

-(void)cancelStatusLabel
{
    [self.statusLabel.layer removeAllAnimations];
}

-(void)animateStatusLabelWithText:(NSString*)text
{
    self.statusLabel.text=text;
    
    [self.view.layer removeAllAnimations];
    _broadcastAnimationPlaying=NO;
    
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:INFINITY];
        self.statusLabel.alpha=0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateCurrentUser];
}

-(void)beaconBroadcastDidBegin:(NSNotification*)notif
{
    WMBeaconRadarManager* radar=[WMBeaconRadarManager sharedInstance];

    if(radar.locationManager.isBroadcasting)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self playBroadcastAnimation];
        });
        
        [radar beginMonitoring];
    }
}

-(void)beaconBroadcastDidEnd:(NSNotification*)notif
{
    [self animateStatusLabelWithText:@"Broadcast has stopped."];
}

-(void)viewDidAppear:(BOOL)animated
{
    WMBeaconRadarManager* radar=[WMBeaconRadarManager sharedInstance];
    
    if(!radar)
    {
        return;// fuck!
    }
    
    if(radar.locationManager.isBroadcasting)
    {
        [self playBroadcastAnimation];
    }
    else
    {
        [self animateStatusLabelWithText:@"Starting broadcast..."];
        
        // start broadcasting
        [[WMClient sharedInstance] beginScan:YES completion:^(WMScan *scan, NSError *error) {
            if(!error && scan)
            {
                [radar beginBroadcasting:scan];
            }
        }];
        
        [[WMClient sharedInstance] getSightingsWithCompletion:^(NSArray *sightings, NSError *error) {
            
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)myProfileButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"EditProfileModal" sender:self];
}
@end
