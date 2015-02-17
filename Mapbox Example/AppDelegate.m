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

    [[RMConfiguration configuration] setAccessToken:@"pk.eyJ1IjoicmFzaHN0YWNrcyIsImEiOiJFaEhlSjg4In0.l5yROIJgxa6rL3h8pSyK_g"];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    [tabBarController.tabBar setBarTintColor:[self colorFromHexString:@"#FF8A8A"] ];
    [tabBarController.tabBar setBackgroundColor: [self colorFromHexString:@"#FF8A8A"]];
    [tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    for (NSString *typeString in [NSArray arrayWithObjects:@"Home", nil])
    {
        Class ViewControllerClass = NSClassFromString([NSString stringWithFormat:@"STHomeLayerViewController"]);
        
        UIViewController *viewController = [[ViewControllerClass alloc] initWithNibName:@"STHomeLayerViewController" bundle:nil];
        
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

// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end