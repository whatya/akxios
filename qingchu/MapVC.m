//
//  MapVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/11.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "MapVC.h"
#import <MapKit/MapKit.h>
#import "CommonConstants.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "DXAnnotationView.h"
#import "DXAnnotationSettings.h"
#import "CallOutView.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "UIView+Toast.h"
#import "NSUserDefaults+Util.h"
#import "Tracker.h"

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *imei;
@property(nonatomic, strong) NSString *localType;
@property(nonatomic, assign) CGPoint endPoint;

@end

@implementation PlaceAnnotation

@end

@interface HomeAnnotation: NSObject<MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@end

@implementation HomeAnnotation

@end

@interface HospitalAnnotation: NSObject<MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@end

@implementation HospitalAnnotation
@end

@interface MedicineAnnotation: NSObject<MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@end

@implementation MedicineAnnotation
@end


@interface MapVC ()<MKMapViewDelegate,UIActionSheetDelegate>

@property (weak,  nonatomic)    IBOutlet MKMapView *mapView;
@property (weak,  nonatomic)    IBOutlet UIButton  *userIMVBtn;
@property (weak,  nonatomic)    IBOutlet NSLayoutConstraint *bottomDistanceCST;
@property (strong,nonatomic)    UILongPressGestureRecognizer *longPressGesture;
@property (strong,nonatomic)    HomeAnnotation *homeAnnotation;
@property (strong,nonatomic)    PlaceAnnotation *currentAnnotation;
@property (strong,nonatomic)    MKCircle *circle;

@property (weak, nonatomic)     IBOutlet UISlider *slider;
@property (weak, nonatomic)     IBOutlet UILabel *radiValueLB;

@property (nonatomic,strong) NSMutableArray *hospitalArray;
@property (nonatomic,strong) NSMutableArray *medicineArray;
@property(nonatomic, strong) NSMutableArray *availableMaps;

@property(nonatomic, assign) CLLocationCoordinate2D targetCoordinate;

@end

@implementation MapVC


#pragma mark- 控制器生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hospitalArray = [NSMutableArray new];
    self.medicineArray = [NSMutableArray new];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPlace:)
                                                 name:@"positionNotice"
                                               object:nil];
    self.mapView.delegate = self;
    
    [self.userIMVBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[[NSPublic shareInstance] getimage]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
    
    AddCornerBorder(self.userIMVBtn, 30, 0, nil);
    
    if (self.alertLocation) {
        NSString *imei          =   self.alertLocation[@"imei"];
        NSString *rowAddress    =   self.alertLocation[@"lbsaddress"];
        NSString *lbslat        =   self.alertLocation[@"lbslat"];
        NSString *lbslon        =   self.alertLocation[@"lbslon"];
        NSString *time          =   self.alertLocation[@"receivetime"];
        
        if (imei.length > 0 && rowAddress.length > 0 && lbslat.length > 0 && lbslon.length > 0 && time.length > 0) {
            
            NSString *firstAddress = [[rowAddress componentsSeparatedByString:@";"] firstObject];
            firstAddress = firstAddress.length > 0 ? firstAddress : @"";
            NSString *point = [NSString stringWithFormat:@"{%@,%@}",lbslat,lbslon];
            NSDictionary *placeData = @{@"imei"         : imei,
                                        @"addressText"  : firstAddress,
                                        @"place"        : point,
                                        @"receivetime"  : time};
            
            [self now:placeData save:NO];
        }else{
            NSLog(@"数据有空值！");
        }
        
    }else{
        NSDictionary *lastPlace = [NSUserDefaults placeForImei:[[NSPublic shareInstance] getImei]];
        
        if ([lastPlace isKindOfClass:[NSDictionary class]]) {
            [self now:lastPlace save:YES];
        }else{
            [self sendLocatingCommond];
        }

    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSPublic shareInstance].vcIndex = 0;
    [ProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [NSPublic shareInstance].vcIndex = 2;
}

#pragma mark- Target Actions
- (IBAction)find:(id)sender {
    [self sendLocatingCommond];
}
- (IBAction)changeRadiValue:(UISlider *)sender
{
    int value = (int)sender.value;
    self.radiValueLB.text = [NSString stringWithFormat:@"%d",value];
    
    [self addCircleOverlayWithCenter:self.homeAnnotation.coordinate radius:value * 1000];
    
}
- (IBAction)sure:(id)sender
{
    //数据验证
    if (!self.homeAnnotation) {
        [self.view makeToast:@"请长按选择围栏中心点！" duration:1 position:CSToastPositionCenter];
        return;
    }
    
    int radius = [self.radiValueLB.text intValue] * 1000;
    if (radius == 0) {
        [self.view makeToast:@"半径必须大于0！" duration:1 position:CSToastPositionCenter];
        return;
    }
    
    
    //添加圆
    [self addCircleOverlayWithCenter:self.homeAnnotation.coordinate radius:radius];
    
    [self showMenu];
    
    //保存到本地（保存服务器成功后）
    NSDictionary *secure = @{@"center" : NSStringFromCGPoint(CGPointMake(self.homeAnnotation.coordinate.latitude,
                                                                         self.homeAnnotation.coordinate.longitude)),
                             @"radius" : @(radius)};
    
    [NSUserDefaults saveSecurePlace:secure forIme:[[NSPublic shareInstance] getImei]];
    //保存到服务器
    NSDictionary *serverParam = @{@"lat" : [NSString stringWithFormat:@"%f",self.homeAnnotation.coordinate.latitude],
                                  @"lon" : [NSString stringWithFormat:@"%f",self.homeAnnotation.coordinate.longitude],
                                  @"radius" : self.radiValueLB.text};
    [self submitSecureData:serverParam];
    
}
- (IBAction)cancel:(id)sender
{
    [self showMenu];
}

- (IBAction)backToCurrentLocation:(UIButton *)sender
{
    if (self.currentAnnotation) {
        CLLocationDegrees latDelta = 0.008;
        //对角线长度
        MKCoordinateSpan span = MKCoordinateSpanMake(fabs(latDelta), 0.0);
        MKCoordinateRegion region = MKCoordinateRegionMake(self.currentAnnotation.coordinate, span);
        [self.mapView setRegion:region animated:YES];
        [self.mapView selectAnnotation:self.currentAnnotation animated:YES];
    }else{
        [self sendLocatingCommond];
    }
}

#pragma mark- 发送定位指令
- (void)sendLocatingCommond
{
    [ProgressHUD show:@"定位中..." Interaction:YES];
    NSArray *keys = @[@"sid",@"imei"];
    NSArray *values = @[[[NSPublic shareInstance] getsid],[[NSPublic shareInstance] getImei]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/data@sendLocOrder.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                //do nothing...
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

#pragma mark- 显示当前位置

- (void)newPlace:(NSNotification*)place
{ShowLog
    NSLog(@"%@",place);
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD dismiss];
        
        NSDictionary *placeDictionary = [place object];
        if (![placeDictionary isKindOfClass:[NSDictionary class]]) {
            NSLog(@"数据不是字典！");
            return;
        };
        NSString *imei          =   placeDictionary[@"imei"];
        NSString *rowAddress    =   placeDictionary[@"lbsaddress"];
        NSString *lbslat        =   placeDictionary[@"lbslat"];
        NSString *lbslon        =   placeDictionary[@"lbslon"];
        NSString *time          =   placeDictionary[@"receivetime"];
        NSString *type          =   placeDictionary[@"loctype"];
        
        if (imei.length > 0 && rowAddress.length > 0 && lbslat.length > 0 && lbslon.length > 0 && time.length > 0) {
            
            NSString *firstAddress = [[rowAddress componentsSeparatedByString:@";"] firstObject];
            firstAddress = firstAddress.length > 0 ? firstAddress : @"";
            NSString *point = [NSString stringWithFormat:@"{%@,%@}",lbslat,lbslon];
            NSDictionary *placeData = @{@"imei"         : imei,
                                        @"addressText"  : firstAddress,
                                        @"place"        : point,
                                        @"receivetime"  : time,
                                        @"loctype"      : type};
            
            [self now:placeData save:YES];
        }else{
            NSLog(@"数据有空值！");
        }

        
    });
    
   }

#pragma mark- 格式化数据
- (void)now:(NSDictionary*)place save:(BOOL)flag
{
    if (flag) {
        [NSUserDefaults saveLastPlace:place forImei:place[@"imei"]];
    }
    PlaceAnnotation *nowAnnotation = [[PlaceAnnotation alloc] init];
    CGPoint point               =   CGPointFromString(place[@"place"]);
    nowAnnotation.coordinate    =   CLLocationCoordinate2DMake(point.x, point.y);
    nowAnnotation.time          =   place[@"receivetime"];
    nowAnnotation.address       =   place[@"addressText"];
    nowAnnotation.imei          =   place[@"imei"];
    nowAnnotation.localType     =   place[@"loctype"];
    
    if (self.currentAnnotation) {
        [self.mapView removeAnnotation:self.currentAnnotation];
    }
    
    self.currentAnnotation = nowAnnotation;
    
    [self.mapView addAnnotation:nowAnnotation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //放大至定位区域
        CLLocationDegrees latDelta = 0.008;
        //对角线长度
        MKCoordinateSpan span = MKCoordinateSpanMake(fabs(latDelta), 0.0);
        MKCoordinateRegion region = MKCoordinateRegionMake(nowAnnotation.coordinate, span);
        [self.mapView setRegion:region animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mapView selectAnnotation:nowAnnotation animated:YES];
        });
    });
    
}

#pragma mark- 地图代理方法
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
        
        PlaceAnnotation *anno = (PlaceAnnotation*)annotation;
        
        UIImageView *pinView = nil;
        
        CallOutView *calloutView = nil;
        
        pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinner"]];
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 30, 30)];
        imv.image = [UIImage imageNamed:@"ThinkingBoy"];
        [imv sd_setImageWithURL:[NSURL URLWithString:[[NSPublic shareInstance] getimage]] placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
        
        AddCornerBorder(imv, 15, 0, nil);
        [pinView addSubview:imv];
        calloutView = [[[NSBundle mainBundle] loadNibNamed:@"CallOutView" owner:self options:nil] firstObject];
        calloutView.timeLB.text = [self formateDateString:anno.time];
        
        if (anno.localType) {
            calloutView.placeTypeLB.text = [NSString stringWithFormat:@"%@定位",anno.localType];
        }else{
            calloutView.placeTypeLB.text = @"";
        }
        
        
        
        calloutView.addressLB.text = anno.address;
        calloutView.secureBtn.enabled = self.isMaster;
        if (!self.isMaster) {
            [calloutView.secureBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        //calloutView.circleWidthCST.constant = self.isMaster ? 44 : 0;
            
        calloutView.routeAction = ^{ PUSH(@"Main", @"RouteVC", @"轨迹", (@{@"imei":anno.imei}), YES); };
        NSDictionary *lastPlace = [NSUserDefaults placeForImei:[[NSPublic shareInstance] getImei]];
        NSString *latAndLon = lastPlace[@"place"];
        CGPoint point = CGPointFromString(latAndLon);
        NSString *queryPoint = [NSString stringWithFormat:@"%f,%f",point.y,point.x];
        
        __weak MapVC* weak_self = self;
        calloutView.circleAction = ^{ [self showMenu]; };
        
        calloutView.hospitalAction = ^{
            [weak_self fetchPOIAround:queryPoint withKeyords:@"医院"];
                };
        
        calloutView.medicineAction = ^{
            //[weak_self fetchStations];
            [weak_self fetchPOIAround:queryPoint withKeyords:@"药店"];
        };
        
        calloutView.navigateAction = ^{
            
            weak_self.targetCoordinate = anno.coordinate;
            [weak_self showSheet];
            
        };
        
        DXAnnotationView *annotationView =  annotationView = [[DXAnnotationView alloc] initWithAnnotation:anno
                                                          reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                                  pinView:pinView
                                                              calloutView:calloutView
                                                                 settings:[DXAnnotationSettings defaultSettings]];

        
        return annotationView;
    }else if ([annotation isKindOfClass:[HomeAnnotation class]]){
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Home"];
        annotationView.image = [UIImage imageNamed:@"setHome"];
        annotationView.canShowCallout = YES;
        return annotationView;
    }else if ([annotation isKindOfClass:[HospitalAnnotation class]]){
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"yiyuan"];
        annotationView.image = [UIImage imageNamed:@"yiyuan"];
        annotationView.canShowCallout = YES;
        return annotationView;
        
    }else if ([annotation isKindOfClass:[MedicineAnnotation class]]){
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"yaodian"];
        annotationView.image = [UIImage imageNamed:@"yaodian"];
        annotationView.canShowCallout = YES;
        return annotationView;
        
    }
    return nil;
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        [circleView setStrokeColor:[UIColor colorWithRed:76/255.0 green:119/255.0 blue:135/255.0 alpha:0.8]];
        [circleView setFillColor:[UIColor colorWithRed:122/255.0 green:168/255.0 blue:188/255.0 alpha:0.3]];
        [circleView setLineWidth:2];
        return circleView;
    }
    
    return nil;
}

#pragma mark- 工具方法
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

#pragma mark- 围栏相关
#pragma mark- -------显示／隐藏底部菜单
- (void)showMenu
{
    int value = self.bottomDistanceCST.constant == 0 ? -92 : 0;
    self.bottomDistanceCST.constant = value;
    if (value == 0) {
        [self.view makeToast:@"请长按地图选点！" duration:1 position:CSToastPositionCenter];
        [self addLongPressGuesture];
        
        NSDictionary *securePlace = [NSUserDefaults securePlaceForImei:[[NSPublic shareInstance] getImei]];
        if (securePlace) {
            int sliderValue = [securePlace[@"radius"] intValue] / 1000;
            self.slider.value = sliderValue;
            self.radiValueLB.text = [NSString stringWithFormat:@"%d",sliderValue];
            [self addHome:securePlace];
            CGPoint center = CGPointFromString(securePlace[@"center"]);
            [self addCircleOverlayWithCenter:CLLocationCoordinate2DMake(center.x, center.y) radius:[securePlace[@"radius"] intValue]];
        }
        
    }else{
        [self.mapView removeGestureRecognizer:self.longPressGesture];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark- -------添加选点长按手势
- (void)addLongPressGuesture
{
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.longPressGesture.minimumPressDuration = 0.3;//按0.5秒响应longPress方法
    self.longPressGesture.allowableMovement = 10.0;
    [self.mapView addGestureRecognizer:self.longPressGesture];//mapView是MKMapView的实例
}

#pragma mark- -------手势回调方法
- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){  //这个状态判断很重要
        //坐标转换
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        //这里的touchMapCoordinate.latitude和touchMapCoordinate.longitude就是你要的经纬度，
        NSLog(@"%f",touchMapCoordinate.latitude);
        NSLog(@"%f",touchMapCoordinate.longitude);
       
        
        CGPoint center = CGPointMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
        NSString *string = NSStringFromCGPoint(center);
        [self addHome:@{@"center":string}];
    }
}

#pragma mark- -------添加家的位置
- (void)addHome:(NSDictionary*)home
{
    CGPoint point               =   CGPointFromString(home[@"center"]);
    HomeAnnotation *homeAnnotation  = [[HomeAnnotation alloc] init];
    homeAnnotation.coordinate       = CLLocationCoordinate2DMake(point.x, point.y);
    homeAnnotation.title            = @"家";
    if (self.homeAnnotation) {
        [self.mapView removeAnnotation:self.homeAnnotation];
    }
    self.homeAnnotation = homeAnnotation;
    [self.mapView addAnnotation:homeAnnotation];
    [self.mapView selectAnnotation:self.homeAnnotation animated:YES];
}


#pragma mark- -------添加overlay围栏视图
- (void)addCircleOverlayWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius
{
    if (self.circle) {
        [self.mapView removeOverlay:self.circle];
    }
    self.circle = [MKCircle circleWithCenterCoordinate:center radius:radius];
    [self.mapView addOverlay:self.circle];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(center, radius * 2  + 300, radius * 2 + 300) animated:YES];
    });
    
}

#pragma mark- 提交半径数据到服务端
- (void)submitSecureData:(NSDictionary*)secure
{
    NSArray *keys =     @[@"imei",@"lat",@"lon",@"radius"];
    NSArray *values =   @[[[NSPublic shareInstance] getImei],secure[@"lat"],secure[@"lon"],secure[@"radius"]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/terminal@updateRangeSetting.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"设置成功！" Interaction:YES];
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

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#pragma mark- 根据关键字获取兴趣点
- (void)fetchPOIAround:(NSString*)gpsString withKeyords:(NSString*)keywords
{
    [ProgressHUD show:[NSString stringWithFormat:@"搜索%@中...",keywords]];
    
    NSString *url = @"http://restapi.amap.com/v3/place/around?key=12861a3f2d3b599cf7c03ae2653c3fe7&location=%@&output=json&radius=10000&keywords=%@";
    NSString *temp = [NSString stringWithFormat:url,gpsString,keywords];
    
   [[HttpManager sharedHttpManager] jsonDataFromServerWithqueryString:temp callBack:^(id jsonData, NSError *error) {
       if (error) {
           [ProgressHUD showError:@"网络出错，请稍候再试！"];
           return ;
       }
       
       int status = [jsonData[@"status"] intValue];
       if (status == 1) {
           [ProgressHUD dismiss];
           
           [self addPOIS:jsonData[@"pois"] withType:keywords];
           
       }else{
           [ProgressHUD showError:[NSString stringWithFormat:@"附近没有%@",keywords]];
       }
       
   }];

}

#pragma mark- 获取服务站
- (void)fetchStations
{
    [ProgressHUD show:@"查找服务站中..."];
    NSArray *keys =     @[@"imei",@"latitude",@"longitude"];
    NSString *latitude = [NSString stringWithFormat:@"%.4f",[Tracker shared].lat];
    NSString *longitude =[NSString stringWithFormat:@"%.4f",[Tracker shared].lon];
    NSArray *values =   @[[[NSPublic shareInstance] getImei],latitude,longitude];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/office@getLoc.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [self addPOIS:jsonData[@"data"] withType:@"服务站"];
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

#define KAnnoAddr @"address"
#define KAnnoLocation @"location"
#define KAnnoName   @"name"

#pragma mark-添加兴趣点
- (void)addPOIS:(NSArray*)poiArray withType:(NSString*)type
{
    
    if (self.hospitalArray.count > 0) {
        [self.mapView removeAnnotations:self.hospitalArray];
        [self.hospitalArray removeAllObjects];
    }
    
    if (self.medicineArray.count > 0) {
        [self.mapView removeAnnotations:self.medicineArray];
        [self.medicineArray removeAllObjects];
    }
    
    if ([type isEqualToString:@"医院"]) {
        
        for (NSDictionary *dic in poiArray){
            
            HospitalAnnotation *hosAnno = [[HospitalAnnotation alloc] init];
            
            NSString *nameTemp = dic[KAnnoName];
            if ([nameTemp isKindOfClass:[NSArray class]]) {
                NSArray *arrayTemp = (NSArray*)nameTemp;
                hosAnno.title = [arrayTemp firstObject];
            }else if ([nameTemp isKindOfClass:[NSString class]]){
                hosAnno.title =nameTemp;
            }else{
                hosAnno.title = @"";
            }
            
            NSString *subtileTemp = dic[KAnnoAddr];
            if ([subtileTemp isKindOfClass:[NSArray class]]) {
                NSArray *arrayTemp = (NSArray*)subtileTemp;
                hosAnno.subtitle = [arrayTemp firstObject];
            }else if ([subtileTemp isKindOfClass:[NSString class]]){
                hosAnno.subtitle = subtileTemp;
            }else{
                hosAnno.subtitle = @"";
            }
            
            
            NSArray *latAndLon = [dic[KAnnoLocation] componentsSeparatedByString:@","];
            double lat = [latAndLon[1] doubleValue];
            double lon = [latAndLon[0] doubleValue];
            hosAnno.coordinate       = CLLocationCoordinate2DMake(lat, lon);
            
            [self.hospitalArray addObject:hosAnno];
            
        }
        
        if (self.hospitalArray.count > 0) {
            [self.mapView addAnnotations:self.hospitalArray];
        }else{
            [ProgressHUD showError:@"附近没有医院！"];
        }
        
    }else if ([type isEqualToString:@"药店"]){
        
         
        for (NSDictionary *dic in poiArray){
            MedicineAnnotation *hosAnno = [[MedicineAnnotation alloc] init];
            
            NSString *nameTemp = dic[KAnnoName];
            if ([nameTemp isKindOfClass:[NSArray class]]) {
                NSArray *arrayTemp = (NSArray*)nameTemp;
                hosAnno.title = [arrayTemp firstObject];
            }else if ([nameTemp isKindOfClass:[NSString class]]){
                hosAnno.title =nameTemp;
            }else{
                hosAnno.title = @"";
            }
            
            NSString *subtileTemp = dic[KAnnoAddr];
            if ([subtileTemp isKindOfClass:[NSArray class]]) {
                NSArray *arrayTemp = (NSArray*)subtileTemp;
                hosAnno.subtitle = [arrayTemp firstObject];
            }else if ([subtileTemp isKindOfClass:[NSString class]]){
                hosAnno.subtitle = subtileTemp;
            }else{
                hosAnno.subtitle = @"";
            }
            NSArray *latAndLon = [dic[KAnnoLocation] componentsSeparatedByString:@","];
            double lat = [latAndLon[1] doubleValue];
            double lon = [latAndLon[0] doubleValue];
            hosAnno.coordinate       = CLLocationCoordinate2DMake(lat, lon);
            
            [self.medicineArray addObject:hosAnno];
            
        }
        
        if (self.medicineArray.count > 0) {
            [self.mapView addAnnotations:self.medicineArray];
        }else{
            [ProgressHUD showError:@"附近没有药店！"];
        }

        
    }else if([type isEqualToString:@"服务站"]){
        
        
        for (NSDictionary *dic in poiArray){
            MedicineAnnotation *hosAnno = [[MedicineAnnotation alloc] init];
            
            NSString *nameTemp = dic[@"officename"];
            hosAnno.title =nameTemp;
            
            NSString *subtileTemp = dic[@"address"];
            hosAnno.subtitle = subtileTemp;
            
            double lat = [dic[@"latitude"] doubleValue];
            double lon = [dic[@"longitude"] doubleValue];
            hosAnno.coordinate       = CLLocationCoordinate2DMake(lat, lon);
            
            [self.medicineArray addObject:hosAnno];
            
        }
        
        if (self.medicineArray.count > 0) {
            [self.mapView addAnnotations:self.medicineArray];
        }else{
            [ProgressHUD showError:@"附近没有服务站！"];
        }
        

        
    }
    
    //缩放视图显示所有搜索结果
    NSMutableArray *pointsStringArray = [NSMutableArray new];
    for (NSDictionary* tempPoint in poiArray){
        NSArray *latAndLon = [tempPoint[KAnnoLocation] componentsSeparatedByString:@","];
        NSString *tempPointStr = [NSString stringWithFormat:@"{%@,%@}",latAndLon[1],latAndLon[0]];
        [pointsStringArray addObject:tempPointStr];
    }
    
    if (pointsStringArray.count > 0) {
        [self findCenter:pointsStringArray];
    }
}

#pragma mark- 计算路径中点
- (void)findCenter:(NSArray*)points
{
    if (points.count == 0) {
        return;
    }
    
    CGPoint minXPoint = CGPointFromString(points[0]);
    CGPoint maxXPoint = CGPointFromString(points[0]);
    CGPoint minYPoint = CGPointFromString(points[0]);
    CGPoint maxYPoint = CGPointFromString(points[0]);
    
    for (NSString *point in points){
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

#pragma mark- 导航
- (void)availableMapsApps {
    self.availableMaps  = [NSMutableArray new];
    
    CLLocationCoordinate2D startCoor = CLLocationCoordinate2DMake([Tracker shared].lat, [Tracker shared].lon);
    CLLocationCoordinate2D endCoor = self.targetCoordinate;
    NSString *toName = @"目的地";
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=transit",
                               startCoor.latitude, startCoor.longitude, endCoor.latitude, endCoor.longitude, toName];
        
        NSDictionary *dic = @{@"name": @"百度地图",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
                               @"云华时代", endCoor.latitude, endCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"高德地图",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f¢er=%f,%f&directionsmode=transit", endCoor.latitude, endCoor.longitude, startCoor.latitude, startCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"Google Maps",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
}

#pragma mark- 显示action sheet
- (void)showSheet
{
    [self availableMapsApps];
    UIActionSheet *action = [[UIActionSheet alloc] init];
    
    [action addButtonWithTitle:@"使用系统自带地图导航"];
    for (NSDictionary *dic in self.availableMaps) {
        [action addButtonWithTitle:[NSString stringWithFormat:@"使用%@导航", dic[@"name"]]];
    }
    [action addButtonWithTitle:@"取消"];
    action.cancelButtonIndex = self.availableMaps.count + 1;
    action.delegate = self;
    [action showInView:self.view];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {

        CLLocationCoordinate2D startCoor = CLLocationCoordinate2DMake([Tracker shared].lat, [Tracker shared].lon);
        CLLocationCoordinate2D endCoor = self.targetCoordinate;
        
        MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startCoor addressDictionary:nil];
        MKMapItem *fromLocation = [[MKMapItem alloc] initWithPlacemark:startPlacemark];

        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = @"to name";
            
        [MKMapItem openMapsWithItems:@[fromLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
            
    }else if (buttonIndex < self.availableMaps.count+1) {
        NSDictionary *mapDic = self.availableMaps[buttonIndex-1];
        NSString *urlString = mapDic[@"url"];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];

        [[UIApplication sharedApplication] openURL:url];
    }
}


@end


