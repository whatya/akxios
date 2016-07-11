//
//  BloodSuarVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/30.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "BloodSuarVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "RingView.h"
#import "qingchu-swift.h"
#import "ProgressHUD.h"
#import "CHTermUser.h"
#import "DataManager.h"

@interface BloodSuarVC ()<ChartViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *bloodSugarValue;
@property (weak, nonatomic) IBOutlet RingView *ringView;
@property (weak, nonatomic) IBOutlet UILabel *dateLB;
@property (weak, nonatomic) IBOutlet UILabel *timeLB;
@property (weak, nonatomic) IBOutlet LineChartView *chartView;


@property (nonatomic) int pageNo;
@property (nonatomic,strong) NSMutableArray *sugarsArray;
@property (nonatomic, assign) float emptyStart;
@property (nonatomic, assign) float emptyEnd;
@property (nonatomic, assign) float afterMealStart;
@property (nonatomic, assign) float afterMealEnd;
@property (strong,nonatomic) DataManager *dataManager;

@end

@implementation BloodSuarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
  
    
}

- (void)initUI {
    self.emptyStart = [[[NSPublic shareInstance] getdbpmin] floatValue];
    if (self.emptyStart == 0) {
        self.emptyStart = 3.9;
    }
    self.emptyEnd = [[[NSPublic shareInstance] getdbpmax] floatValue];
    if (self.emptyEnd == 0) {
        self.emptyEnd = 6.2;
    }
    self.afterMealStart = [[[NSPublic shareInstance] getdbpmin] floatValue];
    if (self.afterMealStart == 0) {
        self.afterMealStart = 7.1;
    }
    self.afterMealEnd = [[[NSPublic shareInstance] getdbpmax] floatValue];
    if (self.afterMealEnd == 0) {
        self.afterMealEnd = 11.1;
    }
    self.sugarsArray = [NSMutableArray new];
    self.pageNo = 1;
    
    [self initChart];
    
    //右上角按钮
    [self configureRateBtn];
}



- (void)configureRateBtn
{
    UIButton *rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rateBtn.frame = CGRectMake(0, 0, 24, 24);
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],3)) {
        [rateBtn setImage:[UIImage imageNamed:@"rated"] forState:UIControlStateNormal];
    }else{
        [rateBtn setImage:[UIImage imageNamed:@"rate"] forState:UIControlStateNormal];
    }
    
    [rateBtn addTarget:self action:@selector(rate) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rateBtn];
}

- (void)rate
{
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],3)) {
        [ProgressHUD showError:@"您今天已点过赞！" Interaction:YES];
        return;
    }
    [self.dataManager zanWithUser:[[NSPublic shareInstance]getUserName]  imei:[[NSPublic shareInstance]getImei] andType:3 result:^(BOOL status, NSString *error) {
        
        if (status) {
            [ProgressHUD showSuccess:@"点赞成功！" Interaction:YES];
            rate([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],3);
            [self configureRateBtn];
        }else{
            [ProgressHUD showError:error Interaction:YES];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [NSPublic shareInstance].vcIndex = 3;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [NSPublic shareInstance].vcIndex = 0;
}

#pragma mark- setter 方法
- (void)setPageNo:(int)pageNo {
    if (pageNo < 0) {
        [ProgressHUD showError:@"已是最新数据！" Interaction:YES];
    }
    _pageNo = pageNo;
    [self fetchBloodSuagrValue];
}

#pragma mark- target actions
- (IBAction)pageAction:(UIButton *)sender {
    if (sender.tag == 101) {
        self.pageNo ++;
    }else{
        self.pageNo --;
    }
}


#pragma mark- 初始化报表属性
- (void)initChart {
    self.chartView.delegate = self;
    self.chartView.descriptionText = @"";
    self.chartView.noDataTextDescription = @"没有血糖数据！";
    self.chartView.dragEnabled = YES;
    [self.chartView setScaleEnabled:YES];
    self.chartView.pinchZoomEnabled = YES;
    self.chartView.drawGridBackgroundEnabled = NO;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    leftAxis.valueFormatter = numberFormatter;
    
    [leftAxis removeAllLimitLines];
    
    leftAxis.customAxisMax = 30;
    leftAxis.customAxisMin = 3;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.labelCount = 6;
    leftAxis.gridLineDashLengths = @[@2.f, @2.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.labelTextColor = UIColor.redColor;
    rightAxis.customAxisMax = 30.0;
    rightAxis.startAtZeroEnabled = NO;
    rightAxis.customAxisMin = 3.0;
    rightAxis.drawGridLinesEnabled = NO;
    
    self.chartView.rightAxis.enabled = NO;
    self.chartView.legend.form = ChartLegendFormLine;
    
}

#pragma mark- 获取报表数据
- (void)updateChartWith:(NSArray*)dataArray {
    
    if (dataArray.count == 0) {
        [self.chartView clear];
        return;
    }
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArray.count; i++)
    {
        NSDictionary *model = dataArray[i];
        NSString *timeTemp = model[@"receivetime"];
        
        //        NSTimeInterval time=[timeTemp doubleValue]+28800;
        //        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        //        NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
        
        NSString *timeValue = [timeTemp substringWithRange:NSMakeRange(8, 4)];
        NSString *finalValue = [NSString stringWithFormat:@"%@:%@",[timeValue substringToIndex:2],[timeValue substringFromIndex:2]];
        [xVals addObject:finalValue];
        
        
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < dataArray.count; i++)
    {
        NSDictionary *model = dataArray[i];
        int sugar = [model[@"sugar"] intValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:sugar xIndex:i]];
    }
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"血糖曲线"];
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f]];
    set1.lineWidth = 2.0;
    set1.circleRadius = 4.0;
    [set1 setCircleColor:[UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f]];
    set1.fillColor = [UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f];
    set1.drawCubicEnabled = YES;
    set1.drawValuesEnabled = NO;
    set1.drawFilledEnabled = YES;
    set1.fillAlpha = 0.4;
    set1.highlightLineWidth = 1;
    set1.highlightColor = [UIColor redColor];
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueTextColor:UIColor.blackColor];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    [data setValueFormatter:numberFormatter];
    
    [data setValueFont:[UIFont systemFontOfSize:9.f]];
    
    _chartView.data = data;
}


#pragma mark- chartView 代理
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight; {
    NSDictionary *model = self.sugarsArray[entry.xIndex];
    self.bloodSugarValue.text = [NSString stringWithFormat:@"%@", model[@"sugar"]];
    NSString *orignalDateString = model[@"receivetime"];
    
//    NSTimeInterval time=[orignalDateString doubleValue]+28800;
//    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
    
    NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
    NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
    
    NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
    NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
    NSString *sec = [orignalDateString substringWithRange:NSMakeRange(12, 2)];
    
    self.timeLB.text = [NSString stringWithFormat:@"%@:%@:%@", hour, min, sec];
    self.dateLB.text = [NSString stringWithFormat:@"%@年%@月%@日", year, month, day];
    
}

#pragma mark- 获取血糖数据
- (void)fetchBloodSuagrValue {
    [ProgressHUD show:@"获取数据中..." Interaction:YES];
    NSString *url = @"chunhui/m/data@getBloodSugarData.do";
    
    NSString *paramString = [NSString stringWithFormat:@"imei=%@&pagenum=%d&pagesize=20",[[NSPublic shareInstance]getImei],self.pageNo];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              [ProgressHUD dismiss];
                                                              NSLog(@"1111111111111111%@",jsonData);
                                                              [self formatData:jsonData];
                                                          }];
    
}

#pragma mark- 格式化数据
- (void)formatData:(NSDictionary*)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self.sugarsArray removeAllObjects];
    NSArray *data = dictionary[@"data"];
    if ([data isKindOfClass:[NSString class]]) {
        return;
    }
    for (NSDictionary *modelDic in data){
        [self.sugarsArray addObject:modelDic];
    }
    [self updateChartWith:self.sugarsArray];
    NSDictionary *model = [self.sugarsArray lastObject];
    if ([model isKindOfClass:[NSDictionary class]]) {
        NSString *orignalDateString = model[@"receivetime"];
        self.bloodSugarValue.text = [NSString stringWithFormat:@"%@", model[@"sugar"]];
//        
//        NSTimeInterval time=[orignalDateString doubleValue]+28800;
//        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//        NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
        
        NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
        NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
        NSString *sec = [orignalDateString substringWithRange:NSMakeRange(12, 2)];
        
        self.dateLB.text = [NSString stringWithFormat:@"%@年%@月%@日", year, month, day];
        self.timeLB.text = [NSString stringWithFormat:@"%@:%@:%@", hour, min, sec];
        
    }
}








@end
