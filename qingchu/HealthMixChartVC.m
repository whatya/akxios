//
//  HealthMixChartVC.m
//  qingchu
//
//  Created by caoguochi on 16/4/16.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "HealthMixChartVC.h"
#import "CommonConstants.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "qingchu-swift.h"

@interface HealthMixChartVC ()<ChartViewDelegate>

//计步柱状图
@property (weak, nonatomic) IBOutlet BarChartView  *stepChartView;
//高低心率折线图
@property (weak, nonatomic) IBOutlet LineChartView *heartRateHighLowChartView;
//高低心率异常双折线图
@property (weak, nonatomic) IBOutlet LineChartView *heartRateExpChartView;
//高低心率按天显示双折线图
@property (weak, nonatomic) IBOutlet LineChartView *heartRateExpByDayChartView;
//血压折线图
@property (weak, nonatomic) IBOutlet LineChartView *bloodPressureChartView;
//睡眠柱状图
@property (weak, nonatomic) IBOutlet BarChartView  *sleepChartView;
//血糖折线图
@property (weak, nonatomic) IBOutlet LineChartView *sugarChartView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *charts;

@end

@implementation HealthMixChartVC

/**
 *  控制器加载
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *imei = [[NSPublic shareInstance] getImei];
    if (imei.length > 0) {
        [self fetchDataWithImei:imei];
    }
    
    [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    //为报表底图加圆角和阴影
    for (UIView *view in self.charts){
        CALayer *layer = [view layer];
        layer.cornerRadius = 2;
        layer.borderWidth = 0;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.2;
        layer.shadowOffset = CGSizeMake(0, 0);
        
    }
}
#pragma mark- 柱状图
/**
 *  设置柱状图
 *
 *  @param chartView 需要设置的柱状图
 *  @param xValues   横轴数据数组
 *  @param yValues   纵轴数据数组
 *  @param note      数据图例名称
 */
- (void)initBarChartView:(BarChartView*)chartView
             WithXValues:(NSArray*)xValues
              andYValues:(NSArray*)yValues
                 barNote:(NSString*)note
{
    //样式初始化
    chartView.delegate = self;
    
    chartView.descriptionText = @"";
    chartView.noDataTextDescription = @"";
    
    chartView.drawBarShadowEnabled = NO;
    chartView.drawValueAboveBarEnabled = YES;
    
    chartView.maxVisibleValueCount = 60;
    chartView.pinchZoomEnabled = NO;
    chartView.drawGridBackgroundEnabled = NO;
    
    //设置横轴
    ChartXAxis *xAxis = chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:8.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 2.0;
    
    //设置纵轴
    ChartYAxis *leftAxis = chartView.leftAxis;
    //设置最大纵坐标值
    int max = 0;
    for (int i = 0; i < yValues.count; i++){
        if ([yValues[i] intValue] > max) {
            max = [yValues[i] intValue];
        }
    }
    if (max > 0) {
        leftAxis.customAxisMax = max+(max/10);
    }
    
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    
    
    
    chartView.rightAxis.enabled = NO;
    
    chartView.legend.position = ChartLegendPositionBelowChartLeft;
    chartView.legend.form = ChartLegendFormSquare;
    chartView.legend.formSize = 9.0;
    chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    chartView.legend.xEntrySpace = 4.0;
    
    //横轴数据填充
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < xValues.count; i++)
    {
        [xVals addObject:xValues[i]];
    }
    
    //纵轴数据填充
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < yValues.count; i++)
    {
        int yValue = [yValues[i] intValue];
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:yValue xIndex:i]];
        
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:note];
    set1.barSpace = 0.35;
    [set1 setColor:[UIColor colorWithRed:66/255.0 green:164/255.0 blue:245/255.0 alpha:1]];
    [set1 setDrawValuesEnabled:YES];
    
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:8.f]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //数据精度设置
    formatter.allowsFloats = NO;
    [data setValueFormatter:formatter];
    [data setValueFont:[UIFont systemFontOfSize:9.f]];
    
    chartView.data = data;
    [chartView animateWithYAxisDuration:2 easingOption:ChartEasingOptionEaseInOutQuart];
}



#pragma mark- 折线图
/**
 *  设置折线图
 *
 *  @param chartView   需要设置的折线图
 *  @param xValues     横轴数据
 *  @param highYValues 第一条折线纵轴数据
 *  @param lowYValues  第二条折线纵轴数据
 *  @param addTwo      是否显示两条折线
 *  @param note1       第一条折线图例名称
 *  @param note2       第二条折线图例名称
 *  @param noDataNote  没有数据时的提示字符串
 *  @param drawFill    是否需要填充折线
 *  @param limits      纵轴取值区间（左轴max、左轴min、右轴max、右轴min）
 */
- (void)initLineChartView:(LineChartView*)chartView
              WithXValues:(NSArray*)xValues
           andHighYValues:(NSArray*)highYValues
               lowYValues:(NSArray*)lowYValues
              addTwoLines:(BOOL)addTwo
                line1Note:(NSString*)note1
                line2Note:(NSString*)note2
               noDataNote:(NSString*)noDataNote
                     fill:(BOOL)drawFill
                  yLimits:(NSArray*)limits
              allowFloats:(BOOL)allow
{
    //报表初始化
    chartView.delegate = self;
    chartView.descriptionText = @"";
    chartView.noDataTextDescription = noDataNote;
    chartView.dragEnabled = YES;
    [chartView setScaleEnabled:YES];
    chartView.pinchZoomEnabled = YES;
    chartView.drawGridBackgroundEnabled = YES;
    
    //设置横轴
    ChartXAxis *xAxis = chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:7.f];
    xAxis.drawGridLinesEnabled = YES;
    xAxis.spaceBetweenLabels = 0.0;
    xAxis.gridLineDashLengths = @[@5.f, @5.f];
    xAxis.avoidFirstLastClippingEnabled = YES;
    
    //设置纵轴
    ChartYAxis *leftAxis = chartView.leftAxis;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = allow;
    leftAxis.valueFormatter = numberFormatter;
    
    leftAxis.customAxisMax = [limits.firstObject intValue];
    leftAxis.customAxisMin = [limits[1] intValue];
    leftAxis.startAtZeroEnabled = YES;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    
    
    ChartYAxis *rightAxis = chartView.rightAxis;
    rightAxis.enabled = addTwo;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.customAxisMax = [limits[2] intValue];
    rightAxis.customAxisMin = [limits[3] intValue];
    rightAxis.startAtZeroEnabled = YES;
    rightAxis.valueFormatter = numberFormatter;
    
    //数据填充
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    //横轴数据
    for (int i = 0; i < xValues.count; i++)
    {
        [xVals addObject:xValues[i]];
    }
    
    //第一条纵轴数据
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < highYValues.count; i++)
    {
        int highValue = [highYValues[i] intValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:highValue xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:note1];
    
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f]];
    set1.lineWidth = 2.0;
    set1.circleRadius = 4.0;
    [set1 setCircleColor:[UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f]];
    set1.fillColor = [UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f];
    set1.drawCubicEnabled = YES;
    set1.drawValuesEnabled = YES;
    //判断是否需要填充折线图
    set1.drawFilledEnabled = drawFill;
    set1.fillAlpha = 0.4;
    set1.highlightLineWidth = 1;
    set1.highlightColor = [UIColor redColor];
    
    //判断是否需要显示多条折线
    if (addTwo) {
        //第二条纵轴数据
        NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < lowYValues.count; i++)
        {
            int lowValue = [lowYValues[i] intValue];
            [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:lowValue xIndex:i]];
        }
        
        LineChartDataSet *set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:note2];
        set2.axisDependency = AxisDependencyRight;
        [set2 setColor:[UIColor colorWithRed:126/255.0 green:176/255.0 blue:18/255.0 alpha:1]];
        set2.lineWidth = 2.0;
        set2.circleRadius = 4.0;
        [set2 setCircleColor:[UIColor colorWithRed:126/255.0 green:176/255.0 blue:18/255.0 alpha:1]];
        set2.fillColor = [UIColor colorWithRed:126/255.0 green:176/255.0 blue:18/255.0 alpha:1];
        set2.drawCubicEnabled = YES;
        set2.drawValuesEnabled = YES;
        set2.drawFilledEnabled = drawFill;
        set2.highlightColor = [UIColor redColor];
        set2.highlightLineWidth = 1;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set2];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
        [data setValueTextColor:UIColor.blackColor];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.allowsFloats = allow;
        [data setValueFormatter:formatter];
        [data setValueFont:[UIFont systemFontOfSize:6.f]];
        
        chartView.data = data;
        [chartView animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
        
    }else{
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
        [data setValueTextColor:UIColor.blackColor];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.allowsFloats = allow;
        [data setValueFormatter:formatter];
        [data setValueFont:[UIFont systemFontOfSize:6.f]];
        
        chartView.data = data;
        [chartView animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
    }
    
}



#pragma mark- 获取报表数据
/**
 *  获取报表综合数据
 *
 *  @param imei imei号码
 */
- (void)fetchDataWithImei:(NSString*)imei
{
    [ProgressHUD show:@"获取数据中..." Interaction:YES];
    NSString *url = @"/chunhui/m/data@healthReport.do";
    
    NSString *paramString = [NSString stringWithFormat:@"imei=%@",imei];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              [ProgressHUD dismiss];
                                                              NSLog(@"%@",jsonData);
                                                              [self makeData:jsonData];
                                                          }];
}

#define StepKey                 @"stepByDay"
#define HighRateKey             @"maxPulseByDay"
#define LowRateKey              @"minPulseByDay"
#define HighRateExpKey          @"hightPulseExpNumByHour"
#define LowRateExpKey           @"lowPulseExpNumByHour"
#define pulseExpNumByDayKey     @"pulseExpNumByDay"
#define sbpByDayKey             @"sbpByDay"
#define sbpByItemKey            @"sbpByItem"
#define dbpByItemKey            @"dbpByItem"
#define dbpByDayKey             @"dbpByDay"
#define sleepByDayKey           @"sleepByDay"
#define SugarKey                @"sugar"

#pragma mark- 原始数据分解
/**
 *  将原始服务端返回的json数据格式化成报表需要的格式
 *
 *  @param rowDictionary 原始字典
 */
- (void)makeData:(NSDictionary*)rowDictionary
{
    NSDictionary *dictionary = rowDictionary[@"data"];
    
    
    //计步数据
    NSDictionary *stepDic = dictionary[StepKey];
    if (!stepDic) {
        return;
    }
    NSArray *stepXsAndYs = [self buildXsAndYsWith:@[stepDic]
                                   shouldFormatXs:YES
                                     inputXsStyle:@"yyyyMMdd"
                                    outputXsStyle:@"MM月dd"];
    
    [self initBarChartView:self.stepChartView
               WithXValues:stepXsAndYs.firstObject
                andYValues:stepXsAndYs.lastObject
                   barNote:@"运动步数"];
    
    //高低心率数据
    NSDictionary *highRateDic = dictionary[HighRateKey];
    NSDictionary *lowRateDic  = dictionary[LowRateKey];
    NSArray *highLowRateXsAnd2Ys = [self buildXsAndYsWith:@[highRateDic,lowRateDic]
                                           shouldFormatXs:YES
                                             inputXsStyle:@"yyyyMMdd"
                                            outputXsStyle:@"MM月dd"];
    
    [self initLineChartView:self.heartRateHighLowChartView
                WithXValues:highLowRateXsAnd2Ys.firstObject
             andHighYValues:highLowRateXsAnd2Ys[1]
                 lowYValues:highLowRateXsAnd2Ys.lastObject
                addTwoLines:YES
                  line1Note:@"高心率"
                  line2Note:@"低心率"
                 noDataNote:@"没有心率数据"
                       fill:NO
                    yLimits:@[@180,@0,@400,@0]
                allowFloats:NO];
    //心率异常高低数据
    NSDictionary *highRateExpDic = dictionary[HighRateExpKey];
    NSDictionary *lowRateExpDic  = dictionary[LowRateExpKey];
    NSArray *highLowRateExpXsAnd2Ys = [self buildXsAndYsWith:@[highRateExpDic,lowRateExpDic]
                                              shouldFormatXs:NO
                                                inputXsStyle:nil
                                               outputXsStyle:nil];
    
    [self initLineChartView:self.heartRateExpChartView
                WithXValues:highLowRateExpXsAnd2Ys.firstObject
             andHighYValues:highLowRateExpXsAnd2Ys[1]
                 lowYValues:highLowRateExpXsAnd2Ys.lastObject
                addTwoLines:YES
                  line1Note:@"高心率"
                  line2Note:@"低心率"
                 noDataNote:@"没有心率数据"
                       fill:NO
                    yLimits:@[@180,@0,@400,@0]
                allowFloats:NO];
    
    //心率异常按天生成
    NSDictionary *heartRateExpDic = dictionary[pulseExpNumByDayKey];
    NSArray *rateExpXsAndYs = [self buildXsAndYsWith:@[heartRateExpDic]
                                      shouldFormatXs:YES
                                        inputXsStyle:@"yyyyMMdd"
                                       outputXsStyle:@"MM月dd"];
    
    [self initLineChartView:self.heartRateExpByDayChartView
                WithXValues:rateExpXsAndYs.firstObject
             andHighYValues:rateExpXsAndYs.lastObject
                 lowYValues:nil
                addTwoLines:NO
                  line1Note:@"心率异常次数"
                  line2Note:nil
                 noDataNote:@"没有心率数据"
                       fill:NO
                    yLimits:@[@180,@0,@400,@0]
                allowFloats:NO];
    
    //血压报表
    NSDictionary *sbpByDayDic = dictionary[sbpByItemKey];
    NSDictionary *dbpByDayDic = dictionary[dbpByItemKey];
    NSArray *bloodPresureXsAndYs = [self buildXsAndYsWith:@[sbpByDayDic,dbpByDayDic]
                                           shouldFormatXs:YES
                                             inputXsStyle:@"yyyyMMddHHmmss"
                                            outputXsStyle:@"MM月dd HH:mm"];
    [self initLineChartView:self.bloodPressureChartView
                WithXValues:bloodPresureXsAndYs.firstObject
             andHighYValues:bloodPresureXsAndYs[1]
                 lowYValues:bloodPresureXsAndYs[2]
                addTwoLines:YES
                  line1Note:@"收缩压"
                  line2Note:@"舒张压"
                 noDataNote:@"没有血压数据"
                       fill:YES
                    yLimits:@[@160,@40,@300,@40]
                allowFloats:NO];
    
    
    
    //睡眠报表
    NSDictionary *sleepDic = dictionary[sleepByDayKey];
    NSArray *sleepXsAndYs = [self buildXsAndYsWith:@[sleepDic]
                                    shouldFormatXs:YES
                                      inputXsStyle:@"yyyyMMdd"
                                     outputXsStyle:@"MM月dd"];
    [self initBarChartView:self.sleepChartView
               WithXValues:sleepXsAndYs.firstObject
                andYValues:sleepXsAndYs.lastObject
                   barNote:@"睡眠时长(分钟)"];
    
    //血糖报表
    NSDictionary *sugarDic = dictionary[SugarKey];
    if (!sugarDic) {
        return;
    }
    
    NSArray *sugarXsAndYs = [self buildXsAndYsWith:@[sugarDic]
                                    shouldFormatXs:YES
                                      inputXsStyle:@"yyyyMMddHHmmss"
                                     outputXsStyle:@"yyyy-MM-dd HH:mm:ss"];
    
    [self initLineChartView:self.sugarChartView
                WithXValues:sugarXsAndYs.firstObject
             andHighYValues:sugarXsAndYs.lastObject
                 lowYValues:nil
                addTwoLines:NO
                  line1Note:@"血糖"
                  line2Note:nil
                 noDataNote:@"没有血糖数据"
                       fill:NO
                    yLimits:@[@10,@0,@0,@0]
                allowFloats:YES];
    
    
}

#pragma mark- 横轴纵轴数据装配
/**
 *  报表数据组装
 *
 *  @param inputRowData 输入数据，(dictionary) or (dictionary1,dictionary2)
 *  @param format       是否需要格式化横轴数据
 *  @param inputStyle   输入横轴时间格式
 *  @param outputStyle  输出横轴时间格式
 *
 *  @return 返回两个或三个数组（xArray,yArray) or (xArray,y1Array,y2Array)
 */
- (NSArray*)buildXsAndYsWith:(NSArray*)inputRowData
              shouldFormatXs:(BOOL)format
                inputXsStyle:(NSString*)inputStyle
               outputXsStyle:(NSString*)outputStyle
{
    
    if (inputRowData.count > 2) {
        NSLog(@"最多只能初始化两组数据！");
        return nil;
    }
    
    if (inputRowData.count == 1) {
        NSDictionary *rowDictionary = inputRowData.firstObject;
        //key 排序
        NSArray *rowDateStrings = [[rowDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        NSMutableArray *values = [NSMutableArray new];
        
        //日期转换
        NSMutableArray *dateStrings = [NSMutableArray new];
        for (NSString* date in rowDateStrings){
            if (format) {
                NSString *formatedString = [self formatDateString:date inFormat:inputStyle toStyle:outputStyle];
                [dateStrings addObject:formatedString];
            }else{
                [dateStrings addObject:date];
            }
            [values addObject:rowDictionary[date]];
        }
        return @[dateStrings,values];
    }else{
        NSDictionary *highDictionary = inputRowData.firstObject;
        NSDictionary *lowDictionary  = inputRowData.lastObject;
        //key 排序
        NSArray *rowDateStrings = [[highDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSMutableArray *highValues = [NSMutableArray new];
        NSMutableArray *lowValues = [NSMutableArray new];
        
        NSMutableArray *dateStrings = [NSMutableArray new];
        for (NSString* date in rowDateStrings){
            if (format) {
                NSString *formatedString = [self formatDateString:date inFormat:inputStyle toStyle:outputStyle];
                [dateStrings addObject:formatedString];
            }else{
                [dateStrings addObject:date];
            }
            [highValues addObject:highDictionary[date]];
            [lowValues addObject:lowDictionary[date]];
        }
        
        return @[dateStrings,highValues,lowValues];
    }
}

#pragma mark- 日期转换
/**
 *  日期转换
 *
 *  @param inputDateString 输入的日期字符串
 *  @param inputStyle      输入的日期字符串的格式
 *  @param outputStyle     输出的日期字符串的格式
 *
 *  @return 转换后的字符串日期
 */
- (NSString*)formatDateString:(NSString*)inputDateString
                     inFormat:(NSString*)inputStyle
                      toStyle:(NSString*)outputStyle
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.dateFormat = inputStyle;
    NSDate *inputDate = [inputFormatter dateFromString:inputDateString];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = outputStyle;
    return [outputFormatter stringFromDate:inputDate];
}


@end
