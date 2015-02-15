//
//  STRouteChooserViewController.m
//  Mapbox Example
//
//  Created by Rasheed Wihaib on 09/02/2015.
//  Copyright (c) 2015 Mapbox / Development Seed. All rights reserved.
//

#import "STRouteChooserViewController.h"

@interface STRouteChooserViewController ()

@end

@implementation STRouteChooserViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
}
- (IBAction)click:(id)sender {
    NSLog(@"adS");
}
- (IBAction)walkableButtonClick:(id)sender {
    [self routeSelectedName:@"walkable"];
}
- (IBAction)fastestButtonClick:(id)sender {
    [self routeSelectedName:@"fastest"];

}
- (IBAction)strlButtonClick:(id)sender {
    [self routeSelectedName:@"strl"];
}

-(void) routeSelectedName:(NSString *) name {
    NSLog(@"%@", name);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
