//
//  SleepVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/12/3.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "SleepVC.h"
#import "qingchu-swift.h"
#import "CommonConstants.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "NSPublic.h"

@interface SleepVC()<ChartViewDelegate>

@property (weak, nonatomic) IBOutlet BarChartView *chartView;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong,nonatomic) NSDate  *uiDate;

@property (strong,nonatomic) NSArray *originalArray;
@property (strong,nonatomic) NSMutableArray *daysArray;
@property (strong,nonatomic) NSMutableArray *xValuesArray;

@property (weak, nonatomic) IBOutlet UILabel *sleepTimeHourLB;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeMinuLB;
@property (weak, nonatomic) IBOutlet UILabel *deepTimeHourLB;
@property (weak, nonatomic) IBOutlet UILabel *deepTimeMinuLB;


@end

@implementation SleepVC

#pragma mark- 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self initData];
}

- (void)initUI
{
    
    AddCornerBorder(self.timeBtn, 10, 0, nil);
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.maxVisibleValueCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:8.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.customAxisMax = 8;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.maximumFractionDigits = 1;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    
    
    _chartView.rightAxis.enabled = NO;
    
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;
    _chartView.legend.form = ChartLegendFormSquare;
    _chartView.legend.formSize = 9.0;
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _chartView.legend.xEntrySpace = 4.0;
    
}

- (void)initData
{
    self.uiDate = [NSDate date];
}

- (void)updateTopUIWith:(NSDictionary*)dicionary
{
    //生成日期数组
    NSString *inputDateString = dicionary[@"sleepDate"];
    NSString *inputDeepTimeString = dicionary[@"deepTime"];
    NSString *inputTimeString = dicionary[@"sleepTime"];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *inputDate = [inputFormatter dateFromString:inputDateString];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"MM月dd日"];
    NSString *finalDateString = [outputFormatter stringFromDate:inputDate];
    
    [self.timeBtn setTitle:finalDateString forState:UIControlStateNormal];
    
    
    NSArray *deepStrs = [inputDeepTimeString componentsSeparatedByString:@":"];
    if (deepStrs.count == 2) {
        self.deepTimeHourLB.text = [NSString stringWithFormat:@"%d",[deepStrs[0] intValue]];
        self.deepTimeMinuLB.text = [NSString stringWithFormat:@"%d'",[deepStrs[1] intValue]];
    }else{
        self.deepTimeHourLB.text =  @"0";
        self.deepTimeMinuLB.text = @"0";
    }
    
    NSArray *sleepStrs = [inputTimeString componentsSeparatedByString:@":"];
    if (sleepStrs.count == 2) {
        self.sleepTimeHourLB.text = [NSString stringWithFormat:@"%d",[sleepStrs[0] intValue]];
        self.sleepTimeMinuLB.text = [NSString stringWithFormat:@"%d'",[sleepStrs[1] intValue]];
    }else{
        self.sleepTimeHourLB.text = @"0";
        self.sleepTimeMinuLB.text = @"0";
    }
    
    
}

#pragma mark- chartView 代理
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight;
{
    NSDictionary *model = self.originalArray[entry.xIndex];
    [self updateTopUIWith:model];
}

- (void)setDataX:(NSArray*)xs Y:(NSArray*)ys
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < xs.count; i++)
    {
        [xVals addObject:xs[i]];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < ys.count; i++)
    {
        double yValue = [ys[i] doubleValue];
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:yValue xIndex:i]];
    
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@"深度睡眠时长"];
    set1.barSpace = 0.35;
    [set1 setColor:[UIColor colorWithRed:66/255.0 green:164/255.0 blue:245/255.0 alpha:1]];
    [set1 setDrawValuesEnabled:NO];
    
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _chartView.data = data;
    [_chartView animateWithYAxisDuration:2 easingOption:ChartEasingOptionEaseInOutQuart];
    
}


#pragma mark- 按钮触发方法
- (IBAction)nextOrPre:(UIButton *)sender
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    if (sender.tag == 1973) {
        NSDate *preDate = [self.uiDate dateByAddingTimeInterval:-secondsPerDay * 6];
        self.uiDate = preDate;
        
    }else{
        NSDate *nexDate = [self.uiDate dateByAddingTimeInterval:secondsPerDay * 6];
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
    
     NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *fromDate = [uiDate dateByAddingTimeInterval:-secondsPerDay * 6];
    NSDate *toDate = uiDate;
    
    NSString *fromString = [apiFormatter stringFromDate:fromDate];
    NSString *endString = [apiFormatter stringFromDate:toDate];
    NSString *imei = [[NSPublic shareInstance] getImei];
    [self fetchSleepWithImei:imei fromDate:fromString toDate:endString];
    
}

#pragma mark-生成横坐标
- (void)generateXValuesFromEndDate:(NSDate*)date
{
     NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSMutableArray *days = [NSMutableArray new];
    NSDate *xDate = date;
    for (int i = 0; i< 7; i ++) {
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"MM.dd"];
        NSString *dateString = [formater stringFromDate:xDate];
        xDate = [xDate dateByAddingTimeInterval:- secondsPerDay];
        [days addObject:dateString];
    }
    
    NSLog(@"%@",days);
}

#pragma mark- 数据处理
- (void)makeData:(NSArray*)data
{ShowLog
    
    self.originalArray = data;
    self.daysArray = [NSMutableArray new];
    self.xValuesArray = [NSMutableArray new];
    
    for (NSDictionary *dicionary in data){
        
        //生成日期数组
        NSString *inputDateString = dicionary[@"sleepDate"];
        NSString *inputDeepTimeString = dicionary[@"deepTime"];
        
        NSDateFormatter *apiFormatter = [[NSDateFormatter alloc] init];
        [apiFormatter setDateFormat:@"yyyyMMdd"];
        NSDate *inputDate = [apiFormatter dateFromString:inputDateString];
        
        NSDateFormatter *xFormatter = [[NSDateFormatter alloc] init];
        [xFormatter setDateFormat:@"MM.dd"];
        NSString *xDateString = [xFormatter stringFromDate:inputDate];
        [self.daysArray addObject:xDateString];
        
        //生成日期对应的值
        NSArray *hourAndMinStrs = [inputDeepTimeString componentsSeparatedByString:@":"];
        if (hourAndMinStrs.count == 2) {
            int  hour = [hourAndMinStrs[0] intValue];
            int  minu = [hourAndMinStrs[1] intValue];
            double minuToHour = minu / 60.0;
            double finalTime = hour + minuToHour;
            [self.xValuesArray addObject:@(finalTime)];
        }else{
            [self.xValuesArray addObject:@(0)];
        }
    }
    

    if (self.daysArray.count > 0) {
        [self updateTopUIWith:[self.originalArray lastObject]];
        [self setDataX:self.daysArray Y:self.xValuesArray];
    }
    
}


#pragma mark- 获取服务端数据
- (void)fetchSleepWithImei:(NSString*)imei fromDate:(NSString*)startDate toDate:(NSString*)endDate
{
    [ProgressHUD show:@"获取中..." Interaction:YES];
    NSArray *keys = @[@"imei",@"startTime",@"endTime"];
    NSArray *values = @[imei,startDate,endDate];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/data@getSleepData.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            if (IsSuccessful(jsonData)) {
                [self makeData:DataDictionary(jsonData)];
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



@end
