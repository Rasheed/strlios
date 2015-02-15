//
//  OnlineLayerViewController.h
//  Mapbox Example
//
//  Copyright (c) 2014 Mapbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Mapbox.h"
#import "KLCPopup.h"
#import "STRouteChooserViewController.h"

@interface STHomeLayerViewController : UIViewController<CLLocationManagerDelegate, RMMapViewDelegate>

@end