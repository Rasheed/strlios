//
//  STRouteChooserViewController.h
//  Mapbox Example
//
//  Created by Rasheed Wihaib on 09/02/2015.
//  Copyright (c) 2015 Rasheed Wihaib. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STRouteChooserViewController;
@protocol STRouteChooserDelegate <NSObject>
- (void) routeSelected: (STRouteChooserViewController *) sender withName:(NSString *) name;
@end
@interface STRouteChooserViewController : UIViewController

@property (nonatomic, weak) id <STRouteChooserDelegate> delegate;

@end
