//
//  ShowMapViewController.m
//  hbgooglemap
//
//  Created by boob on 2017/6/5.
//  Copyright © 2017年 YY.COM. All rights reserved.
//

//文档
//https://developers.google.com/maps/documentation/ios-sdk/

#import "ShowMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface ShowMapViewController ()<GMSMapViewDelegate>

@property (nonatomic, strong)  GMSMapView *mapView;
@property (nonatomic, strong) GMSCameraPosition *camera;

@end

@implementation ShowMapViewController

- (void)loadView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                            longitude:103.848
                                                                 zoom:16];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = mapView;
    self.mapView = mapView;
    self.camera = camera;
    self.mapView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     * 设置我的地点定位,两条都要设置
     */
    self.mapView.settings.myLocationButton = YES;
    self.mapView.myLocationEnabled = YES;
    
    NSLog(@"User's location: %@", self.mapView.myLocation);
    
    /**
     * 设置指南针
     */
    self.mapView.settings.compassButton = YES;
    
    
    /**
     * 添加标注
     */
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = self.camera.target;
    marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    
//    CLLocationCoordinate2D panoramaNear = {50.059139,-122.958391};
//    
//    GMSPanoramaView *panoView =
//    [GMSPanoramaView panoramaWithFrame:CGRectZero
//                        nearCoordinate:panoramaNear];
//    
//    self.view = panoView;
}


/**
 * 自定义标注
 */
-(void)usermarker:(CLLocationCoordinate2D)position{
 
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = position;
    //CLLocationCoordinate2DMake(41.887, -87.622);
//    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:@"smallcar"];
    marker.map = self.mapView;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSMapViewDelegate

/**
 * 点击商家 街景,点击居中移动并提示
 */
- (void)mapView:(GMSMapView *)mapView
didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location {
    
    NSLog(@"You tapped %@: %@, %f/%f", name, placeID, location.latitude, location.longitude);
    
    GMSMarker * infoMarker = [GMSMarker markerWithPosition:location];
    infoMarker.snippet = placeID;
    infoMarker.title = name;
    infoMarker.opacity = 0;
    CGPoint pos = infoMarker.infoWindowAnchor;
    pos.y = 1;
    infoMarker.infoWindowAnchor = pos;
    infoMarker.map = mapView;
    self.mapView.selectedMarker = infoMarker;
    
}

/**
 * 点击地图上的坐标
 */
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
   
     NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
    [self usermarker:coordinate];

}


- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [mapView clear];
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
  
      id handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error == nil) {
            GMSReverseGeocodeResult *result = response.firstResult;
            GMSMarker *marker = [GMSMarker markerWithPosition:cameraPosition.target];
            marker.title = result.lines[0];
            marker.snippet = result.lines[1];
            marker.map = mapView;
        }
    };
    [self.geocoder reverseGeocodeCoordinate:cameraPosition.target completionHandler:handler];
}

-(GMSGeocoder *)geocoder{
    return [GMSGeocoder geocoder];
}

@end
