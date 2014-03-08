//
//  WMAppDelegate.m
//  Warmer
//
//  Created by Marc Chambers on 3/3/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

#import "WMAppDelegate.h"
#import <Facebook.h>
#import "WMEditProfileViewController.h"

@implementation WMAppDelegate

-(void)changeRootViewAnimated:(UIViewController*)vc
{
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = vc; }
                    completion:nil];
}

-(void)setupRoutes
{
    [JLRoutes addRoute:@"/login" handler:^BOOL(NSDictionary *parameters) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"Login"];
        
        [self changeRootViewAnimated:vc];
        
        return YES;
    }];
    
    [JLRoutes addRoute:@"/user/:userId" handler:^BOOL(NSDictionary *parameters) {
        return YES;
    }];
    
    [JLRoutes addRoute:@"/user/me/edit" handler:^BOOL(NSDictionary *parameters) {
        return YES;
    }];
    
    [JLRoutes addRoute:@"/errors/wontwork" handler:^BOOL(NSDictionary *parameters) {
        
        return YES;
    }];
    
    [JLRoutes addRoute:@"/scan" handler:^BOOL(NSDictionary *parameters) {
        NSLog(@"Routing to scan");
        BOOL animate=YES;
        
        if(parameters && parameters[@"animate"])
        {
            animate=[parameters[@"animate"] boolValue];
        }
        
        if([self.window.rootViewController.presentedViewController isKindOfClass:[WMEditProfileViewController class]])
        {
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc=[sb instantiateViewControllerWithIdentifier:@"Radar"];
            
            if(animate)
                [self changeRootViewAnimated:vc];
            else
                self.window.rootViewController=vc;
        }
        
        return YES;
    }];
}

-(void)ensureAppWillWork
{
    NSArray *locationServicesAuthStatuses = @[@"Not determined",@"Restricted",@"Denied",@"Authorized"];
    NSArray *backgroundRefreshAuthStatuses = @[@"Restricted",@"Denied",@"Available"];
    
    BOOL monitoringAvailable = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    NSLog(@"Monitoring available: %@", [NSNumber numberWithBool:monitoringAvailable]);
    
    int lsAuth = (int)[CLLocationManager authorizationStatus];
    NSLog(@"Location services authorization status: %@", [locationServicesAuthStatuses objectAtIndex:lsAuth]);
    
    int brAuth = (int)[[UIApplication sharedApplication] backgroundRefreshStatus];
    NSLog(@"Background refresh authorization status: %@", [backgroundRefreshAuthStatuses objectAtIndex:brAuth]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Pacifico" size:24.0f]}];

    [self ensureAppWillWork];
    [self setupRoutes];
    
    [JLRoutes routeURL:[NSURL URLWithString:@"/login"]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
