//
//  SportVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/16.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "SportVC.h"
#import "RingView.h"
#import "CommonConstants.h"
#import "qingchu-swift.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "DataManager.h"

@interface SportVC ()<ChartViewDelegate>

@property (weak, nonatomic) IBOutlet RingView *ringView;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (strong,nonatomic) NSDate  *uiDate;
@property (weak, nonatomic) IBOutlet UILabel *stepsLB;
@property (weak, nonatomic) IBOutlet UILabel *totalStepsLB;
@property (weak, nonatomic) IBOutlet LineChartView *stepChart;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *sportResultLB;
@property (weak, nonatomic) IBOutlet UILabel *kmLB;
@property (weak, nonatomic) IBOutlet UILabel *kcalLB;
@property (strong,nonatomic) DataManager *dataManager;
@end

@implementation SportVC

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#pragma mark- 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    if (self.imei.length == 0) {
        self.imei = [[NSPublic shareInstance] getImei];
    }
    
    self.ringView.percent = 0.5;
    AddCornerBorder(self.timeBtn, 10, 0, nil);
    [self initChartView];
    self.uiDate = [NSDate date];
    self.totalStepsLB.text = [NSString stringWithFormat:@"%d",[[[NSPublic shareInstance] getstepmax] intValue]];
    double rads = DEGREES_TO_RADIANS(-90);
    self.ringView.layer.transform = CATransform3DMakeRotation(rads, 0, 0, 1);
    self.dataManager = [[DataManager alloc] init];
    [self configureRateBtn];

}

- (void)configureRateBtn
{
    UIButton *rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rateBtn.frame = CGRectMake(0, 0, 24, 24);
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],1)) {
        [rateBtn setImage:[UIImage imageNamed:@"rated"] forState:UIControlStateNormal];
    }else{
        [rateBtn setImage:[UIImage imageNamed:@"rate"] forState:UIControlStateNormal];
    }
    
    [rateBtn addTarget:self action:@selector(rate) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rateBtn];
}


- (void)rate
{
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],1)) {
        [ProgressHUD showError:@"您今天已点过赞！" Interaction:YES];
        return;
    }
    
    
    
    [self.dataManager zanWithUser:[[NSPublic shareInstance]getUserName]  imei:[[NSPublic shareInstance]getImei] andType:1 result:^(BOOL status, NSString *error) {
        
        if (status) {
            [ProgressHUD showSuccess:@"点赞成功！" Interaction:YES];
            rate([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],1);
            [self configureRateBtn];
        }else{
            [ProgressHUD showError:error Interaction:YES];
        }
        
    }];
    
}


#pragma mark- 按钮触发方法
- (IBAction)nextOrPre:(UIButton *)sender
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

#pragma mark- 属性设置方法
- (void)setUiDate:(NSDate *)uiDate
{
    _uiDate = uiDate;
    NSDateFormatter *uiFormater = [[NSDateFormatter alloc] init];
    [uiFormater setDateFormat:@"MM月dd日"];
    [self.timeBtn setTitle:[uiFormater stringFromDate:uiDate] forState:UIControlStateNormal];
    
    if ([[uiFormater stringFromDate:uiDate] isEqualToString:[uiFormater stringFromDate:[NSDate date]]]) {
        self.nextBtn.enabled    = NO;
        self.nextBtn.alpha      = 0.5;
    }else{
        self.nextBtn.enabled    = YES;
        self.nextBtn.alpha      = 1;
    }
    
    NSDateFormatter *apiFormatter = [[NSDateFormatter alloc] init];
    [apiFormatter setDateFormat:@"yyyyMMdd"];
    [self fetchStepsWithImei:self.imei dateString:[apiFormatter stringFromDate:uiDate]];
    
}

#pragma mark- 获取计步数据
- (void)fetchStepsWithImei:(NSString*)imei dateString:(NSString*)dateParam
{
    [ProgressHUD show:@"获取中..." Interaction:YES];
    NSArray *keys = @[@"imei",@"starttime",@"endtime"];
    NSArray *values = @[imei,dateParam,dateParam];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/data@getStepData.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            if (IsSuccessful(jsonData)) {
                [self dealData:[jsonData[@"data"] firstObject]];
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

- (void)dealData:(NSDictionary*)rowDictionary
{
    NSArray *totalsteps = [rowDictionary[@"totalsteps"] componentsSeparatedByString:@"|"];
    NSArray *totalDista = [rowDictionary[@"totaldis"] componentsSeparatedByString:@"|"];
    NSArray *calories   = [rowDictionary[@"calories"] componentsSeparatedByString:@"|"];
    
    NSMutableArray *stepsData = [NSMutableArray new];
    if (totalsteps.count > 48) {
        for (int index = 1; index <= 48; index += 2) {
            int firstData = [totalsteps[index -1] intValue];
            int secondData = [totalsteps[index] intValue];
            [stepsData addObject:@(firstData + secondData)];
        }
    }
    
    int totalDistance = 0;
//    for (int i = 0; i < totalDista.count; i ++) {
//        int temp  = [totalDista[i] intValue];
//        totalDistance += temp;
//    }
    
    totalDistance = [[totalDista lastObject] intValue];
    
    int totalCalories = 0;
//    for (int i = 0; i < calories.count; i++) {
//        int temp = [calories[i] intValue];
//        totalCalories += temp;
//    }
    
    totalCalories = [[calories lastObject] intValue];
    
    self.sportResultLB.text = [NSString stringWithFormat:@"行走%.1fkm,消耗%d卡路里",totalDistance*1.0/1000,totalCalories];
    self.kmLB.text = [NSString stringWithFormat:@"%.1fkm",totalDistance*1.0/1000];
    self.kcalLB.text = [NSString stringWithFormat:@"%dKcal",totalCalories];
    [self dispalyData:stepsData];
    
}

#pragma mark- 初始化报表
- (void)initChartView
{
    self.stepChart.delegate = self;
    self.stepChart.descriptionText = @"  ";
    self.stepChart.noDataTextDescription = @"没有计步数据！";
    self.stepChart.dragEnabled = YES;
    [self.stepChart setScaleEnabled:YES];
    self.stepChart.pinchZoomEnabled = YES;
    self.stepChart.drawGridBackgroundEnabled = NO;

    
    self.stepChart.xAxis.drawGridLinesEnabled = NO;
    
    ChartYAxis *leftAxis = self.stepChart.leftAxis;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    leftAxis.valueFormatter = numberFormatter;
    
    leftAxis.customAxisMin = 0;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.labelCount = 6;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    self.stepChart.rightAxis.enabled = NO;
}

#pragma mark- 显示数据
- (void)dispalyData:(NSArray*)dataArray
{
    [self.stepChart clear];
    
    //x轴数据
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i++)
    {
        
        [xVals addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //y轴数据
     NSMutableArray *yVals = [[NSMutableArray alloc] init];
    int maxStep = 0;
    int totalSteps = 0;
    for (int i = 0; i < dataArray.count; i ++) {
        int step = [dataArray[i] intValue];
        if (step > maxStep) {
            maxStep = step;
        }
        totalSteps += step;
        
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:step xIndex:i]];
    }
    self.stepChart.leftAxis.customAxisMax = maxStep+200;
    self.stepsLB.text = [NSString stringWithFormat:@"%d",totalSteps];
    self.ringView.percent = totalSteps * 1.0 / [[[NSPublic shareInstance] getstepmax] floatValue];
    
    //组合数据
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"步数"];
    
    
    [set1 setColor:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:207/255.0 alpha:1]];
    
    set1.lineWidth = 2.0;
    set1.circleRadius = 2.0;
    set1.drawCircleHoleEnabled = NO;
    set1.drawCubicEnabled = NO;
    set1.valueFont = [UIFont systemFontOfSize:6.f];
    set1.drawFilledEnabled = YES;
    set1.fillAlpha = 0.4;
    set1.fillColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:207/255.0 alpha:1];
    
    NSMutableArray *circleColors = [NSMutableArray new];
    for (int i = 0; i < dataArray.count; i++) {
        [circleColors addObject:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:207/255.0 alpha:1]];
    }
    
    [set1 setCircleColors:circleColors];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    [data setValueFormatter:numberFormatter];
    
    self.stepChart.data = data;
    [self.stepChart animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
}

@end
