//
//  LocationViewController.m
//  YonyouIM
//
//  Created by litfb on 15/3/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "LocationViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

#import "YYIMChatHeader.h"
#import "SimpleSelTableViewCell.h"
#import "YYIMUIDefs.h"
#import "YYIMUtility.h"

@interface LocationViewController ()<MAMapViewDelegate, AMapSearchDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (retain, nonatomic) MAMapView *aMapView;
@property (retain, nonatomic) CLLocationManager *locationManager;

@property (retain, nonatomic) AMapSearchAPI *aMapSearchAPI;

@property (retain, nonatomic) MAPointAnnotation *pointAnnotation;

@property (retain, nonatomic) NSArray *pois;

@property BOOL flag;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"位置";
    
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = confirmBtn;
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleSelTableViewCell" bundle:nil] forCellReuseIdentifier:@"SimpleSelTableViewCell"];
    
    self.aMapView = [[MAMapView alloc] initWithFrame:self.mapView.bounds];
    self.flag = NO;
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendAction {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    // 取数据
    AMapPOI *poi = [self.pois objectAtIndex:indexPath.row];
    if (!poi) {
        return;
    }
    // 截图
    UIImage *screenshotImage = [self.aMapView takeSnapshotInRect:self.aMapView.frame];
    NSString *path = [YYIMResourceUtility saveImage:screenshotImage];
    // 发消息
    [self.delegate doSendLocation:path address:[NSString stringWithFormat:@"%@%@", poi.address, poi.name] longitude:poi.location.longitude latitude:poi.location.latitude];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SimpleSelTableViewCell";
    SimpleSelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    // 取数据
    AMapPOI *poi = [self.pois objectAtIndex:indexPath.row];
    [cell setName:[poi name]];
    [cell setDetail:[NSString stringWithFormat:@"%@%@%@", poi.city, poi.district, poi.address]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    AMapPOI *poi = [self.pois objectAtIndex:indexPath.row];
    if (!poi) {
        return;
    }
    
    [self coordinateChange:[NSString stringWithFormat:@"%@%@", poi.address, poi.name] latitude:poi.location.latitude longitude:poi.location.longitude];
}

#pragma mark amap

- (void)mapView:(MAMapView *) mapView didUpdateUserLocation:(MAUserLocation *) userLocation
updatingLocation:(BOOL) updatingLocation {
    if (!self.flag && updatingLocation) {
        // 取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        [self doSearchWithLocation:point];
        
        self.flag = YES;
    }
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

- (void)doSearchWithLocation:(AMapGeoPoint *)point {
    //初始化检索对象
    self.aMapSearchAPI = [[AMapSearchAPI alloc] init];
    [self.aMapSearchAPI setDelegate:self];
    //构造 AMapPlaceSearchRequest 对象,配置关键字搜索参数
    AMapPOIAroundSearchRequest *poiRequest = [[AMapPOIAroundSearchRequest alloc] init];
//    poiRequest.searchType = AMapSearchType_PlaceAround;
    poiRequest.location = point;
    poiRequest.radius = 1000;
    poiRequest.requireExtension = YES;
    //发起 POI 搜索
    [self.aMapSearchAPI AMapPOIAroundSearch:poiRequest];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if(response.pois.count == 0) {
        return;
    }
    //处理搜索结果
    self.pois = response.pois;
    [self.tableView reloadData];
    if ([self.pois count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

#pragma mark 

- (void)coordinateChange:(NSString *) address latitude : (CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    if (self.pointAnnotation) {
        [self.aMapView removeAnnotation:self.pointAnnotation];
    }
    
    self.pointAnnotation = [[MAPointAnnotation alloc] init];
    self.pointAnnotation.coordinate = coordinate;
    self.pointAnnotation.title = address;
    [self.aMapView addAnnotation:self.pointAnnotation];
    
    [self.aMapView setCenterCoordinate:coordinate animated:YES];
}

@end
