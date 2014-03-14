//
//  WMRadarViewController.m
//  Warmer
//
//  Created by Marc Chambers on 3/6/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMRadarViewController.h"
#import <UIImageView+AFNetworking.h>
#import "WMButton.h"
#import "TLAlertView.h"
#import "WMProfileCard.h"

@interface WMRadarViewController ()

@property (nonatomic, weak) WMLocationManager* locationManager;

@property (nonatomic, strong) NSMutableArray* currentSightings;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconsNearby:) name:kWarmerBeaconBeaconsNearbyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noMoreBeaconsNearby:) name:kWarmerBeaconNoMoreBeaconsNearbyNotification object:nil];
}

-(void)noMoreBeaconsNearby:(NSNotification*)notif
{
    
}

-(void)beaconsNearby:(NSNotification*)notif
{
    // check for sightings; the sightings check auto-reschedules itself
    // as long as we are in a beacon region
    
    // eventually we might want to use APNS for this to reduce the server load
    // or use APNS + reducing the frequency of the manual checks
    // we'd also have to manually check if we detect the user has not
    // enabled push notifications
    
    [self checkForUnreadSightings];
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
    circle.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    circle.lineWidth = 2;
    
    radarRing1.fillColor=[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    radarRing1.strokeColor=[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
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

-(void)showCurrentSightings
{
    NSPredicate* pred=[NSPredicate predicateWithFormat:@"(expires > %@)", [NSDate date]];
    NSArray* unexpiredSightings=[self.currentSightings filteredArrayUsingPredicate:pred];
    
    long leftovers=unexpiredSightings.count-self.userImages.count;
    if(leftovers<0) leftovers=0;
    
    int j=0;
    for(int i=0; i<self.userImages.count; i++)
    {
        WMSighting* sighting;
        if(unexpiredSightings.count>j)
            sighting=unexpiredSightings[j++];
        
        if(sighting)
        {
            [self.userImages[i] setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sighting.sightedUser.pictureURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [self.userImages[i] setImage:image];
                [[self.userImages[i] layer] setCornerRadius:64.0f/2.0f];
                [[self.userImages[i] layer] setMasksToBounds:YES];
                [self.userImageButtons[i] setSighting:sighting];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
        }
        else
        {
            [self.userImages[i] setImage:nil];
            [self.userImageButtons[i] setSighting:nil];
        }
    }
}

-(void)checkForUnreadSightings
{
    NSLog(@"Checking for unread sightings on the server");
    __block NSMutableDictionary* currentlySightedUserIDs;
    
    [[WMClient sharedInstance] getSightingsWithCompletion:^(NSArray *sightings, NSError *error) {
        if(sightings)
        {
            if(!self.currentSightings)
                self.currentSightings=[NSMutableArray array];
            else
                [self.currentSightings removeAllObjects];
            
            if(!currentlySightedUserIDs)
                currentlySightedUserIDs=[NSMutableDictionary dictionary];
            
            // sort by most recent
            NSSortDescriptor* sort=[[NSSortDescriptor alloc] initWithKey:@"expires" ascending:NO];
            NSMutableArray* filtered=[NSMutableArray arrayWithArray:[sightings sortedArrayUsingDescriptors:@[sort]]];
            // filter expired
            [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"(expires > %@)", [NSDate date]]];
            
            // check for dupes
            for(int i=0; i<filtered.count; i++)
            {
                WMSighting* sighting=filtered[i];
                
                if(![currentlySightedUserIDs objectForKey:sighting.sightedUser.userID])
                {
                    [currentlySightedUserIDs setValue:@(YES) forKey:sighting.sightedUser.userID];
                    [self.currentSightings addObject:sighting];
                }
            }
            
            // mark as read on server
            
            // display current active sightings
            [self showCurrentSightings];
            
            // schedule a new sightings check if we're still in range of beacons
            // or if we've got unexpired sightings in our midst
            if([[WMBeaconRadarManager sharedInstance] currentlyInRangeOfBeacons] || (self.currentSightings && self.currentSightings.count > 0))
            {
                double delayInSeconds = 5.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self checkForUnreadSightings];
                });
            }
        }
    }];
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
        
        [self checkForUnreadSightings];
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
    //[self performSegueWithIdentifier:@"EditProfileModal" sender:self];
    //TLAlertView *alertView = [[TLAlertView alloc] initWithTitle:@"Title" message:@"Message" buttonTitle:@"OK"];
    //[alertView show];
    UINib* nib=[UINib nibWithNibName:@"ProfileCard" bundle:[NSBundle mainBundle]];
    WMProfileCard* profile=[[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    [profile show];
}
@end
