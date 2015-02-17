//
//  OnlineLayerViewController.m
//  Mapbox Example
//
//  Copyright (c) 2014 Mapbox, Inc. All rights reserved.
//

#import "STHomeLayerViewController.h"
#import "UIViewController+MJPopupViewController.h"

@interface STHomeLayerViewController()

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) RMMapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *routes;
@property (nonatomic) bool *controlVisible;

@property (nonatomic) CLLocationCoordinate2D endpoint;

@property (nonatomic, strong) IBOutlet UIView *mapViewContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIView *labelContainer;
@property (weak, nonatomic) IBOutlet UILabel *fastestLabel;
@property (weak, nonatomic) IBOutlet UILabel *walkableLabel;
@property (weak, nonatomic) IBOutlet UILabel *strlLabel;
@property (weak, nonatomic) IBOutlet UIView *controlContainer;
@property (weak, nonatomic) IBOutlet UIButton *startWalkButton;
@property (strong, nonatomic) IBOutlet UIView *ratingView;

@end

#define kMapboxMapID @"rashstacks.l7pe2n95"

@implementation STHomeLayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.routes = [[NSMutableDictionary alloc] init];
    
    RMMapboxSource *onlineSource = [[RMMapboxSource alloc] initWithMapID:kMapboxMapID];

    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:onlineSource];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(51.5248, -0.1336);
    self.mapView.zoom = 2;
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    [self.mapViewContainer addSubview:self.mapView];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];

    [self.controlContainer setHidden:YES];
    [self.startWalkButton setHidden:YES];
    [self.ratingView setHidden:YES];
}

- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    [mapView removeAllAnnotations];
    
    CLLocationCoordinate2D tappedPoint = CLLocationCoordinate2DMake([mapView pixelToCoordinate:point].latitude, [mapView pixelToCoordinate:point].longitude);
    self.endpoint = tappedPoint;
    NSLog(@"You tapped at %f, %f", tappedPoint.latitude, tappedPoint.longitude);
    CLLocation *location = [self.locationManager location];
    if(location == nil) {
        location = [[CLLocation alloc] initWithLatitude:51.5248 longitude:-0.1336];
    }
    NSLog(@"Your current location is %f, %f", location.coordinate.latitude, location.coordinate.longitude);

    
    RMPointAnnotation *pointForDestination = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                    coordinate:[mapView pixelToCoordinate:point]
                                                                      andTitle:@"Destination"];
    
    [mapView addAnnotation:pointForDestination];
    
    [self zoomMapView:mapView toFit:location.coordinate andPoint:tappedPoint];

    NSString *urlString = [NSString stringWithFormat:@"https://prelimstrlapp.herokuapp.com/services/path/all/%f/%f/%f/%f", location.coordinate.latitude, location.coordinate.longitude, tappedPoint.latitude, tappedPoint.longitude];
    
    NSLog(@"urlstring %@", urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if(!error)
    {
        NSError *e = nil;
        NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
        for(id key in JSON) {
            if ([key rangeOfString:@"Distance"].location != NSNotFound) {
                NSString *value =[NSString stringWithFormat:@"%@",[JSON objectForKey: key]];
                NSString *labelcontent = [NSString stringWithFormat:@"%ldm", (long)value.integerValue];
                if([key isEqualToString:@"fastestRouteDistance"]) {
                    [self.fastestLabel setText:labelcontent];
                } else if([key isEqualToString:@"walkableRouteDistance"]) {
                    [self.walkableLabel setText:labelcontent];
                } else if([key isEqualToString:@"strlRouteDistance"]) {
                    [self.strlLabel setText:labelcontent];
                }
                continue;
            }
            
            NSArray *value = [JSON objectForKey:key];
            self.points = [value mutableCopy];
            
            for (NSUInteger i = 0; i < [self.points count]; i++)
                [self.points replaceObjectAtIndex:i
                                       withObject:[[CLLocation alloc] initWithLatitude:[[[self.points objectAtIndex:i] objectAtIndex:1] doubleValue]
                                                                             longitude:[[[self.points objectAtIndex:i] objectAtIndex:0] doubleValue]]];
            
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:mapView
                                                                  coordinate:location.coordinate
                                                                    andTitle:key
                                        ];
            
            [self.routes setValue:self.points forKey:key];

            
            [mapView addAnnotation:annotation];
            
            [annotation setBoundingBoxFromLocations:self.points];
            
        }
        [self.controlContainer setHidden:NO];
        [self.startWalkButton setHidden:NO];

    }

}

- (void) zoomMapView:(RMMapView *) mapView toFit:(CLLocationCoordinate2D) from andPoint:(CLLocationCoordinate2D) to {
    CLLocationCoordinate2D cpCoord = from;
    CLLocationCoordinate2D carCoord = to;
    
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(fmin(cpCoord.latitude, carCoord.latitude), fmin(cpCoord.longitude, carCoord.longitude));
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(fmax(cpCoord.latitude, carCoord.latitude), fmax(cpCoord.longitude, carCoord.longitude));
    
    sw.latitude -= sw.latitude * 0.0001;
    sw.longitude -= sw.longitude * 0.0001;
    
    ne.latitude += ne.latitude * 0.0001;
    ne.longitude += ne.longitude * 0.0001;
    
    
    [mapView zoomWithLatitudeLongitudeBoundsSouthWest:sw northEast:ne animated:NO];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMShape *shape = [[RMShape alloc] initWithView:mapView];
    if ([[annotation title] isEqualToString:@"fastestroutepoints"]) {
        shape.lineColor = [[UIColor redColor] colorWithAlphaComponent:0.7f];
    } else
    if([[annotation title] isEqualToString:@"walkableroutepoints"]) {
        shape.lineColor = [[UIColor greenColor] colorWithAlphaComponent:0.7f];
    } else
    if([[annotation title] isEqualToString:@"strlroutepoints"]) {
        shape.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.7f];
    }
    
    shape.lineWidth = 3.0;
    
    for (CLLocation *point in self.points)
        [shape addLineToCoordinate:point.coordinate];
    
    return shape;
}
- (IBAction)clickFastest:(id)sender {
    [self toggleLayerNamed:@"fastestroutepoints"];
}
- (IBAction)clickWalkable:(id)sender {
    [self toggleLayerNamed:@"walkableroutepoints"];
}
- (IBAction)clickStrl:(id)sender {
    [self toggleLayerNamed:@"strlroutepoints"];
}

- (void) toggleLayerNamed:(NSString *) name {
    bool removed = NO;
    for(RMAnnotation *annotation in [self.mapView annotations]) {
        if([[annotation title] isEqualToString:name]) {
            [self.mapView removeAnnotation:annotation];
            removed = YES;
        }
    }
    if(!removed) {
        RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                              coordinate:self.mapView.centerCoordinate
                                                                andTitle:name ];
        self.points = [self.routes objectForKey:name];
        [self.mapView addAnnotation:annotation];
    }
}

- (IBAction)controlClick:(id)sender {
    if(self.controlVisible) {
        [UIView beginAnimations:@"buttonContainer" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        //new position
        [[self controlContainer]setTransform:CGAffineTransformMakeTranslation(0, 0)];
        
        [UIView commitAnimations];

        self.controlVisible = false;
        
    } else {
        [UIView beginAnimations:@"buttonContainer" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        //new position
        [[self controlContainer]setTransform:CGAffineTransformMakeTranslation(0, 60)];
    
        [UIView commitAnimations];
    
        self.controlVisible = true;
    }
}

- (IBAction)startWalk:(id)sender {
    
    STRouteChooserViewController *controller=[[STRouteChooserViewController alloc] initWithNibName:@"STRouteChooserViewController" bundle:nil];
    controller.delegate = self;
    [self presentPopupViewController:controller animationType:MJPopupViewAnimationFade];
}

-(void)routeSelected:(STRouteChooserViewController *)sender withName:(NSString *)name {
    
    [self.controlContainer setHidden:YES];
    [self.startWalkButton setHidden:YES];
    [self startSelectedRoute:name];
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(void)startSelectedRoute:(NSString *) name {
    [self.mapView removeAllAnnotations];
    NSString *pathName = [NSString stringWithFormat:@"%@routepoints",name];
    RMPointAnnotation *pointForDestination = [[RMPointAnnotation alloc] initWithMapView:self.mapView
                                                                             coordinate:self.endpoint
                                                                               andTitle:@"Destination"];
    
    [self.mapView addAnnotation:pointForDestination];
    [self toggleLayerNamed:pathName];
    [self.ratingView setHidden:NO];

    
}

@end