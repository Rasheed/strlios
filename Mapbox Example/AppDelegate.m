//
//  AppDelegate.m
//  Mapbox Example
//
//  Copyright (c) 2014 Mapbox, Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "STHomeLayerViewController.h"
#import "OfflineLayerViewController.h"
#import "InteractiveLayerViewController.h"

#import "Mapbox.h"

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[RMConfiguration configuration] setAccessToken:@"pk.eyJ1IjoicmFzaGVlZHdpaGFpYiIsImEiOiJaOTBoMFI4In0.5rmY9BbciXR2L_8JC_CaVA"];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    for (NSString *typeString in [NSArray arrayWithObjects:@"Home", nil])
    {
        Class ViewControllerClass = NSClassFromString([NSString stringWithFormat:@"STHomeLayerViewController"]);
        
        UIViewController *viewController = [[ViewControllerClass alloc] initWithNibName:nil bundle:nil];
        
        viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:[NSString stringWithFormat:@"Home"]
                                                                  image:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", typeString]] 
                                                                    tag:0];
        
        [viewControllers addObject:viewController];
    }
    
    tabBarController.viewControllers = viewControllers;
    
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end