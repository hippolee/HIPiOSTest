//
//  LocationShowController.m
//  YonyouIM
//
//  Created by litfb on 15/3/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "LocationShowController.h"
#import <MAMapKit/MAMapKit.h>
#import "YYIMUIDefs.h"
#import "YYIMUtility.h"

@interface LocationShowController ()<MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapView;

@property (retain, nonatomic) MAMapView *aMapView;
@property (retain, nonatomic) CLLocationManager *locationManager;

@end

@implementation LocationShowController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"位置";
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    self.aMapView = [[MAMapView alloc] initWithFrame:self.mapView.bounds];
    
    if (YYIM_iOS8) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.mapView addSubview:self.aMapView];
    
    self.aMapView.delegate = self;
    self.aMapView.showsUserLocation = YES;
    self.aMapView.userTrackingMode = MAUserTrackingModeFollow;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.aMapView setZoomLevel:16.1 animated:YES];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = self.address;
    [self.aMapView addAnnotation:pointAnnotation];
    
    [self.aMapView setCenterCoordinate:coordinate animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MAAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
            MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
            pre.showsAccuracyRing = NO;
            [self.aMapView updateUserLocationRepresentation:pre];
            break;
        }
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout= YES; //设置气泡可以弹出,默认为 NO
        return annotationView;
    }
    return nil;
}

@end
