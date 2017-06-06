
//
//  MarkViewController.m
//  hbgooglemap
//
//  Created by boob on 2017/6/5.
//  Copyright © 2017年 YY.COM. All rights reserved.
//

#import "MarkViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MarkViewController ()<GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView * mapView;
@property (nonatomic, strong) GMSCameraPosition *camera;

@end

@implementation MarkViewController

- (void)loadView {
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
    //                                                            longitude:103.848
    //                                                                 zoom:16];
    //    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //    self.view = mapView;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.712216
                                                            longitude:-74.20000
                                                                 zoom:14];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = _mapView;
    
    _mapView.delegate = self;
    
    
    
    self.mapView = _mapView;
    self.camera = camera;
    self.mapView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
//    [self addGroundOverlay];

    CLLocation * cl1 = [[CLLocation alloc] initWithLatitude:40.712216 longitude:-74.22655];
    CLLocation * cl2 = [[CLLocation alloc] initWithLatitude:40.712216 longitude:-74.20000];
    
    [self fetchPolylineWithOrigin:cl1 destination:cl2 completionHandler:^(GMSPolyline * po) {
        po.strokeWidth = 4;
        po.strokeColor = [UIColor redColor];
        po.map = self.mapView;
        NSLog(@"成功");
    }];
//    [self drawpath];
 
//     [[GMSPlacesClient sharedClient] currentPlaceWithCallback:^(GMSPlaceLikelihoodList * _Nullable likelihoodList, NSError * _Nullable error) { }]
}

/**
 * 地面层叠
 */
-(void)addGroundOverlay{
    
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(40.712216,-74.22655);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(40.773941,-74.12544);
    GMSCoordinateBounds *overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest
                                                                              coordinate:northEast];
    
    // Image from http://www.lib.utexas.edu/maps/historical/newark_nj_1922.jpg
    UIImage *icon = [UIImage imageNamed:@"newark_nj_1922"];
    GMSGroundOverlay *overlay =
    [GMSGroundOverlay groundOverlayWithBounds:overlayBounds icon:icon];
    overlay.bearing = 0;
    overlay.map = self.mapView;
    
}

/**
 * 画直线
 */
-(void)drawpath{
    GMSCameraPosition *cameraPosition=[GMSCameraPosition cameraWithLatitude:18.5203 longitude:73.8567 zoom:12];
    _mapView =[GMSMapView mapWithFrame:CGRectZero camera:cameraPosition];
    _mapView.myLocationEnabled=YES;
    GMSMarker *marker=[[GMSMarker alloc]init];
    marker.position=CLLocationCoordinate2DMake(18.5203, 73.8567);
    marker.icon=[UIImage imageNamed:@"House"] ;
    marker.groundAnchor=CGPointMake(0.5,0.5);
    marker.map=_mapView;
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:CLLocationCoordinate2DMake(@(18.520).doubleValue,@(73.856).doubleValue)];
    [path addCoordinate:CLLocationCoordinate2DMake(@(16.7).doubleValue,@(73.8567).doubleValue)];
    
    GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    rectangle.strokeWidth = 2.f;
    rectangle.map = _mapView;
    self.view=_mapView;
}


/**
 * 画导航线
 */
- (void)fetchPolylineWithOrigin:(CLLocation *)origin
destination:(CLLocation *)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error)
         {
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             if(error)
             {
                 if(completionHandler)
                     completionHandler(nil);
                 return;
             }
             NSArray *routesArray = [json objectForKey:@"routes"];
             
             // run completionHandler on main thread                                           
             dispatch_sync(dispatch_get_main_queue(), ^{
                 GMSPolyline *polyline = nil;
                 if ([routesArray count] > 0)
                 {
                     NSDictionary *routeDict = [routesArray objectAtIndex:0];
                     NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                     NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                     GMSPath *path = [GMSPath pathFromEncodedPath:points];
                     polyline = [GMSPolyline polylineWithPath:path];
                 }
                 if(completionHandler)
                     completionHandler(polyline);
             });
              }];
    [fetchDirectionsTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
