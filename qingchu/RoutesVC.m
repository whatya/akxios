//
//  RoutesVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/12.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "RoutesVC.h"
#import "CommonConstants.h"
#import "HttpManager.h"
#import <MapKit/MapKit.h>
#import "ProgressHUD.h"
#import "HistoryAnnotion.h"
#import "HistoryAnnotionView.h"
#import "UIImage+JSQMessages.h"
#import "CallOutView.h"
#import "DXAnnotationView.h"
#import "DXAnnotationSettings.h"

@interface RoutesVC ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (strong,nonatomic) NSDate  *uiDate;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSArray *validPoints;

@end

@implementation RoutesVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.uiDate = [NSDate date];
    self.mapView.delegate = self;
    AddCornerBorder(self.dateBtn, 10, 0, nil);
}

- (IBAction)toogleDay:(UIButton *)sender
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    if (sender.tag == 1973) {
        NSDate *preDate = [self.uiDate dateByAddingTimeInterval:-secondsPerDay];
        self.uiDate = preDate;
        
    }else{
        NSDate *nexDate = [self.uiDate dateByAddingTimeInterval:secondsPerDay];
        self.uiDate = nexDate;
    }
}
- (IBAction)toogleLine:(UIButton *)sender {
    [self removeAllLines];
    if (self.validPoints.count > 0) {
        [self addRouteWithPoints:self.validPoints];
    }
}

- (void)removeAllLines
{
    NSArray *lines = self.mapView.overlays;
    if (lines.count > 0) {
        [self.mapView removeOverlays:lines];
    }
}

- (void)setUiDate:(NSDate *)uiDate
{
    _uiDate = uiDate;
    NSDateFormatter *uiFormater = [[NSDateFormatter alloc] init];
    [uiFormater setDateFormat:@"MM月dd日"];
    [self.dateBtn setTitle:[uiFormater stringFromDate:uiDate] forState:UIControlStateNormal];
    
    if ([[uiFormater stringFromDate:uiDate] isEqualToString:[uiFormater stringFromDate:[NSDate date]]]) {
        self.nextBtn.enabled    = NO;
        self.nextBtn.alpha      = 0.5;
    }else{
        self.nextBtn.enabled    = YES;
        self.nextBtn.alpha      = 1;
    }

    
    NSDateFormatter *apiFormatter = [[NSDateFormatter alloc] init];
    [apiFormatter setDateFormat:@"yyyyMMdd"];
    [self fetchRoutesWithDateString:[apiFormatter stringFromDate:uiDate]];
    
}

#pragma mark- 添加路径
- (void)addRouteWithPoints:(NSArray*)pointsArray {

    NSInteger pointsCount = [pointsArray count];
    
    CLLocationCoordinate2D pointsToUse[pointsCount];
    
    for(int i = 0; i < pointsCount; i++) {
        CGPoint p = CGPointFromString([pointsArray objectAtIndex:i]);
        pointsToUse[i] = CLLocationCoordinate2DMake(p.x,p.y);
    }
    
    MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount];
    [self.mapView addOverlay:myPolyline];
}

#pragma mark- 路径代理
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:MKPolyline.class]) {
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        [lineView setStrokeColor:[UIColor greenColor]];
        
        return lineView;
    } else if ([overlay isKindOfClass:MKPolygon.class]) {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithOverlay:overlay];
        [polygonView setStrokeColor:[UIColor magentaColor]];
        
        return polygonView;
    }
    
    return nil;
}

#pragma mark- 大头针代理
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    HistoryAnnotion *anno = (HistoryAnnotion*)annotation;
    
    UIImageView *pinView = nil;
    
    CallOutView *calloutView = nil;
    
    UIImage *imageTemp = nil;

    switch (anno.type) {
        case HistoryNormal:
            imageTemp = [UIImage imageNamed:@"historyNormal"];
            break;
        case HistoryStart:
            imageTemp = [UIImage imageNamed:@"historyStart"];
            break;
        case HistoryEnd:
            imageTemp = [UIImage imageNamed:@"historyEnd"];
            break;
        default:
            imageTemp = [UIImage imageNamed:@"historyNormal"];
            break;
    }

    pinView = [[UIImageView alloc] initWithImage:imageTemp];
    
    calloutView = [[[NSBundle mainBundle] loadNibNamed:@"CallOutView" owner:self options:nil] firstObject];
    calloutView.timeLB.text = anno.title;
    calloutView.addressLB.text = anno.subtitle;
    
    calloutView.circleWidthCST.constant = 0;
    calloutView.routeWidthCST.constant = 0;
    calloutView.hospitalWidthCST.constant = 0;
    calloutView.medicineWidthCST.constant = 0;
    
    DXAnnotationSettings *setting = [DXAnnotationSettings defaultSettings];

    DXAnnotationView *annotationView =  annotationView = [[DXAnnotationView alloc] initWithAnnotation:anno
                                                                                      reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                                                              pinView:pinView
                                                                                          calloutView:calloutView
                                                                                             settings:setting];
    
    
    return annotationView;

}

#pragma mark- 获取路径点
- (void)fetchRoutesWithDateString:(NSString*)dateString
{
    [self removeAllLines];
    [ProgressHUD show:@"获取轨迹..." Interaction:YES];
    NSArray *keys = @[@"time",@"imei"];
    NSArray *values = @[dateString,self.imei];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/data@getHbLocData.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            if (IsSuccessful(jsonData)) {
                NSArray *addresses = jsonData[@"data"];
                if ([addresses isKindOfClass:[NSArray class]]) {
                    NSMutableArray *newPointsArray = [NSMutableArray new];
                    for (NSDictionary *point in addresses){
                        NSString *latValue = point[@"lat"];
                        NSString *lonValue = point[@"lon"];
                        NSString *point = [NSString stringWithFormat:@"{%@,%@}",latValue,lonValue];
                        [newPointsArray addObject:point];
                    }
                    
                    [self findCenter:newPointsArray];
                    [self addHistories:addresses];
                }
            }else{
                [ProgressHUD dismiss];
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [ProgressHUD dismiss];
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];

}

#pragma mark- 计算路径中点
- (void)findCenter:(NSArray*)points
{
    if (points.count == 0) {
        return;
    }
    
    
    //过滤掉距离小于500米的点 start
    NSString *firstPoint = [points firstObject];
    NSString *lastPoint  = [points lastObject];
    
    NSMutableArray *filtedArray = [NSMutableArray new];
    [filtedArray addObject:firstPoint];
    
    for (int i = 1;i < points.count-1;i++){
        NSString *endPoint = [filtedArray lastObject];
        NSString *newPoint = points[i];
        if ([self distanceBetweent:newPoint andAnotherPoint:endPoint] >= 500) {
            [filtedArray addObject:newPoint];
        }
    }
    
    [filtedArray addObject:lastPoint];
    //过滤掉距离小于500米的点 end
    
    self.validPoints = filtedArray;
    
    CGPoint minXPoint = CGPointFromString(filtedArray[0]);
    CGPoint maxXPoint = CGPointFromString(filtedArray[0]);
    CGPoint minYPoint = CGPointFromString(filtedArray[0]);
    CGPoint maxYPoint = CGPointFromString(filtedArray[0]);
    
    for (NSString *point in filtedArray){
        CGPoint p = CGPointFromString(point);
        if (p.x > maxXPoint.x) {
            maxXPoint = p;
        }
        
        if (p.x < minXPoint.x) {
            minXPoint = p;
        }
        
        if (p.y > maxYPoint.y) {
            maxYPoint = p;
        }
        
        if (p.y < minYPoint.y) {
            minYPoint = p;
        }
    }
    
    NSLog(@"最左边的点：%@",NSStringFromCGPoint(minXPoint));
    NSLog(@"最右边的点：%@",NSStringFromCGPoint(maxXPoint));
    NSLog(@"最上边的点：%@",NSStringFromCGPoint(minYPoint));
    NSLog(@"最下边的点：%@",NSStringFromCGPoint(maxYPoint));
    
    CGPoint midPoint = CGPointMake((maxXPoint.x - minXPoint.x)/2 + minXPoint.x, (maxYPoint.y - minYPoint.y)/2 + minYPoint.y);
    
     NSLog(@"中点：%@",NSStringFromCGPoint(midPoint));
    
    //最左边的点
    CLLocation *left = [[CLLocation alloc] initWithLatitude:minXPoint.x longitude:minXPoint.y];
    //最右边多点
    CLLocation *right = [[CLLocation alloc] initWithLatitude:maxXPoint.x longitude:maxXPoint.y];
    // 东西距离
    CLLocationDistance w2e=[left distanceFromLocation:right];
    
    //最上边的点
    CLLocation *top = [[CLLocation alloc] initWithLatitude:minYPoint.x longitude:minYPoint.y];
    //最下边的点
    CLLocation *bottom = [[CLLocation alloc] initWithLatitude:maxYPoint.x longitude:maxYPoint.y];
    //南北距离
    CLLocationDistance n2s=[top distanceFromLocation:bottom];
    
    NSLog(@"东西距离：%f ,南北距离:%f",w2e,n2s);
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(midPoint.x, midPoint.y), w2e, n2s) animated:YES];
}

#pragma mark- 添加大头针
- (void)addHistories:(NSArray*)points
{
    if (points.count == 0) {
        return;
    }
    NSArray *histories = [points sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"recvtime"] compare:obj1[@"recvtime"]];
    }];
    
    //过滤距离小于500米的点start
    
    NSDictionary *firstPoint = [histories firstObject];
    NSDictionary *lastPoint  = [histories lastObject];
    
    NSMutableArray *filtedArray = [NSMutableArray new];
    [filtedArray addObject:firstPoint];
    for (int i = 1; i < histories.count-1 ; i++) {
        NSDictionary *endPoint = [filtedArray lastObject];
        NSDictionary *newPoint = histories[i];
        
        NSString *latValueEnd = endPoint[@"lat"];
        NSString *lonValueEnd = endPoint[@"lon"];
        NSString *endPointStr = [NSString stringWithFormat:@"{%@,%@}",latValueEnd,lonValueEnd];
        
        NSString *latValueNew = newPoint[@"lat"];
        NSString *lonValueNew = newPoint[@"lon"];
        NSString *newPointStr = [NSString stringWithFormat:@"{%@,%@}",latValueNew,lonValueNew];
        
        if ([self distanceBetweent:newPointStr andAnotherPoint:endPointStr] >= 500) {
            [filtedArray addObject:newPoint];
        }
    }
    
    [filtedArray addObject:lastPoint];
    
    //过滤距离小于500米度点end
    
    
    
    NSMutableArray *annotations = [NSMutableArray new];
    for (NSDictionary *point in filtedArray){
        HistoryAnnotion *history = [[HistoryAnnotion alloc] init];
        history.title       =   [self formateDateString:point[@"recvtime"]];
        history.subtitle    =   point[@"address"];
        history.type        =   HistoryNormal;
        CGPoint place       =   CGPointFromString([NSString stringWithFormat:@"{%@,%@}",point[@"lat"],point[@"lon"]]);
        history.coordinate = CLLocationCoordinate2DMake(place.x, place.y);
        [annotations addObject:history];
    }
    HistoryAnnotion *startAnnotation = [annotations firstObject];
    HistoryAnnotion *endAnnotation   = [annotations lastObject];
    startAnnotation.type = HistoryStart;
    startAnnotation.title = [NSString stringWithFormat:@"%@%@",@"起点：",startAnnotation.title];
    endAnnotation.type  = HistoryEnd;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotations:annotations];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView selectAnnotation:startAnnotation animated:YES];
    });
}

- (NSString*)formateDateString:(NSString*)inputString
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[NSLocale currentLocale]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate* inputDate = [inputFormatter dateFromString:inputString];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [outputFormatter stringFromDate:inputDate];
}

- (CLLocationDistance)distanceBetweent:(NSString*)point andAnotherPoint:(NSString*)anotherPoint
{
    CGPoint p1 = CGPointFromString(point);
    CGPoint p2 = CGPointFromString(anotherPoint);
    
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:p1.x longitude:p1.y];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:p2.x longitude:p2.y];
    
    return [location1 distanceFromLocation:location2];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        [((DXAnnotationView *)view)hideCalloutView];
        view.layer.zPosition = -1;
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        [((DXAnnotationView *)view)showCalloutView];
        view.layer.zPosition = 0;
    }
}

@end
