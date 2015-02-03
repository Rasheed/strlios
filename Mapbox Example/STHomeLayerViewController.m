//
//  OnlineLayerViewController.m
//  Mapbox Example
//
//  Copyright (c) 2014 Mapbox, Inc. All rights reserved.
//

#import "STHomeLayerViewController.h"

@interface STHomeLayerViewController()

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) NSMutableArray *points;


@end

#define kMapboxMapID @"rasheedwihaib.kp0el31n"

@implementation STHomeLayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    RMMapboxSource *onlineSource = [[RMMapboxSource alloc] initWithMapID:kMapboxMapID];

    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:onlineSource];
    
    mapView.zoom = 2;
    
    mapView.delegate = self;
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    mapView.userTrackingMode = RMUserTrackingModeFollow;

    [self.view addSubview:mapView];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
}


- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    [mapView removeAllAnnotations];
    
    CLLocationCoordinate2D tappedPoint = CLLocationCoordinate2DMake([mapView pixelToCoordinate:point].latitude, [mapView pixelToCoordinate:point].longitude);
    NSLog(@"You tapped at %f, %f", tappedPoint.latitude, tappedPoint.longitude);
    CLLocation *location = [self.locationManager location];
    
    if(location == nil) {
        location = [[CLLocation alloc] initWithLatitude:51.508898 longitude:-0.133996];
    }
    NSLog(@"Your current location is %f, %f", location.coordinate.latitude, location.coordinate.longitude);

    
    RMPointAnnotation *pointForDestination = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                    coordinate:[mapView pixelToCoordinate:point]
                                                                      andTitle:@"Destination"];
    
    [mapView addAnnotation:pointForDestination];
    
    [self zoomMapView:mapView toFit:location.coordinate andPoint:tappedPoint];

    NSString *urlString = [NSString stringWithFormat:@"https://prelimstrlapp.herokuapp.com/services/path/all/%f/%f/%f/%f", location.coordinate.latitude, location.coordinate.longitude, tappedPoint.latitude, tappedPoint.longitude];
    
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
            
            [mapView addAnnotation:annotation];
            
            [annotation setBoundingBoxFromLocations:self.points];

        }
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

@end