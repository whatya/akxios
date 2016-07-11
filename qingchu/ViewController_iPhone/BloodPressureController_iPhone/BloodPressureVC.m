//
//  BloodPressureVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/26.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "BloodPressureVC.h"
#import "HttpManager.h"
#import "qingchu-swift.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "UIViewController+CusomeBackButton.h"
#import "DataManager.h"
#import "CHTermUser.h"

@interface BloodPressureVC ()<ChartViewDelegate>
@property (nonatomic) int pageNo;

@property (nonatomic, strong) NSMutableArray *bloodDataArray;
@property (weak, nonatomic) IBOutlet LineChartView *chartView;

@property (weak, nonatomic) IBOutlet UILabel *pulseLB;
@property (weak, nonatomic) IBOutlet UILabel *highPressureLB;
@property (weak, nonatomic) IBOutlet UILabel *lowPressureLB;
@property (weak, nonatomic) IBOutlet UILabel *dateLB;

//参考值
@property (weak, nonatomic) IBOutlet UILabel *boyAgeLB;
@property (weak, nonatomic) IBOutlet UILabel *girlAgeLB;

@property (weak, nonatomic) IBOutlet UILabel *boyShrinkLB;
@property (weak, nonatomic) IBOutlet UILabel *boyDiastoleLB;
@property (weak, nonatomic) IBOutlet UILabel *girlShrinkLB;
@property (weak, nonatomic) IBOutlet UILabel *girlDiastoleLB;




@property (strong,nonatomic) DataManager *dataManager;

@property (nonatomic,assign) int lowStart;
@property (nonatomic,assign) int lowEnd;
@property (nonatomic,assign) int highStart;
@property (nonatomic,assign) int highEnd;


@end

@implementation BloodPressureVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
}

- (void)initUI
{
    self.lowStart = [[[NSPublic shareInstance] getdbpmin] intValue];
    
    if (self.lowStart == 0) {
        self.lowStart = 60;
    }
    
    self.lowEnd   = [[[NSPublic shareInstance] getdbpmax] intValue];
    
    if (self.lowEnd == 0) {
        self.lowEnd = 90;
    }
    
    self.highStart = [[[NSPublic shareInstance] getsbpmin] intValue];
    
    if (self.highStart == 0) {
        self.highStart = 90;
    }
    
    self.highEnd = [[[NSPublic shareInstance] getsbpmax] intValue];
    
    if (self.highEnd == 0) {
        self.highEnd = 140;
    }
    
    [self setUpBackButton];
    self.bloodDataArray = [NSMutableArray new];

    self.pageNo = 1;
    [self initChart];
    self.dataManager = [[DataManager alloc] init];
    [self configureRateBtn];
    
    //设置参考值
    [self makeRefrenceValues];
}

- (void)makeRefrenceValues
{
    NSString *currentImei = [[NSPublic shareInstance] getImei];
    NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];
    CHTermUser *model = nil;
    for (CHTermUser *user in termUsers){
        if ([user.imei isEqualToString:currentImei]) {
            model = user;
            break;
        }
    }
    
    if (model) {
        NSString *birthdayString = model.birthday;
        if (birthdayString.length > 0) {
            NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
            inputFormatter.dateFormat = @"yyyyMMdd";
            NSDate *birthdayDate = [inputFormatter dateFromString:birthdayString];
            if (!birthdayDate) {
                [self makeRefrenceValuesWithAge:53];
                return;
            }
            int age = (int)[self ageWithDateOfBirth:birthdayDate];
            if (age > 0) {
                [self makeRefrenceValuesWithAge:age];
            }else{
                [self makeRefrenceValuesWithAge:53];
            }
            
            
        }else{
            
            [self makeRefrenceValuesWithAge:53];
            
        }
    }
}

- (void)makeRefrenceValuesWithAge:(int)age
{
    self.boyAgeLB.text = [NSString stringWithFormat:@"%@ 男性",[self ageRangeString:age]];
    self.girlAgeLB.text = [NSString stringWithFormat:@"%@ 女性",[self ageRangeString:age]];
    
    self.boyShrinkLB.text = [NSString stringWithFormat:@"收缩压:%d",[self shrinkValueOfGender:YES atAge:age]];
    self.boyDiastoleLB.text = [NSString stringWithFormat:@"舒张压:%d",[self diastoleValueOfGender:YES atAge:age]];
    
    self.girlShrinkLB.text = [NSString stringWithFormat:@"收缩压:%d",[self shrinkValueOfGender:NO atAge:age]];
    self.girlDiastoleLB.text = [NSString stringWithFormat:@"舒张压:%d",[self diastoleValueOfGender:NO atAge:age]];
}

- (int)shrinkValueOfGender:(BOOL)isBoy atAge:(int)age
{
    if (age>= 16 && age <=20) {
        return isBoy ? 115 : 110;
    }else if (age >20 && age <=25){
        return isBoy ? 115 : 110;
    }else if (age >25 && age <=30){
        return isBoy ? 115 : 112;
    }else if (age >30 && age <=35){
        return isBoy ? 117 : 114;
    }else if (age >35 && age <=40){
        return isBoy ? 120 : 116;
    }else if (age >40 && age <=45){
        return isBoy ? 124 : 122;
    }else if (age >45 && age <=50){
        return isBoy ? 128 : 128;
    }else if (age >50 && age <=55){
        return isBoy ? 134 : 134;
    }else if (age >55 && age <=60){
        return isBoy ? 137 : 139;
    }else if (age >60 && age <=65){
        return isBoy ? 148 : 145;
    }else{
        return isBoy ? 137 : 139;//默认
    }
}

- (int)diastoleValueOfGender:(BOOL)isBoy atAge:(int)age
{
    if (age>= 16 && age <=20) {
        return isBoy ? 73 : 70;
    }else if (age >20 && age <=25){
        return isBoy ? 73 : 71;
    }else if (age >25 && age <=30){
        return isBoy ? 75 : 73;
    }else if (age >30 && age <=35){
        return isBoy ? 76 : 74;
    }else if (age >35 && age <=40){
        return isBoy ? 80 : 77;
    }else if (age >40 && age <=45){
        return isBoy ? 81 : 78;
    }else if (age >45 && age <=50){
        return isBoy ? 82 : 79;
    }else if (age >50 && age <=55){
        return isBoy ? 84 : 80;
    }else if (age >55 && age <=60){
        return isBoy ? 84 : 82;
    }else if (age >60 && age <=65){
        return isBoy ? 86 : 83;
    }else{
        return isBoy ? 86 : 83;//默认
    }
}

- (NSString*)ageRangeString:(int)age
{
    if (age>= 16 && age <=20) {
        return @"16~20岁";
    }else if (age >20 && age <=25){
        return @"21~25岁";
    }else if (age >25 && age <=30){
        return @"26~30岁";
    }else if (age >30 && age <=35){
        return @"31~35岁";
    }else if (age >35 && age <=40){
        return @"36~40岁";
    }else if (age >40 && age <=45){
        return @"41~45岁";
    }else if (age >45 && age <=50){
        return @"46~50岁";
    }else if (age >50 && age <=55){
        return @"51~55岁";
    }else if (age >55 && age <=60){
        return @"56~60岁";
    }else if (age >60 && age <=65){
        return @"61~65岁";
    }else{
        return @">65岁";//默认
    }

}

- (NSInteger)ageWithDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
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
- (void)setPageNo:(int)pageNo
{
    if (pageNo < 0) {
        [ProgressHUD showError:@"已是最新数据！" Interaction:YES];
        return;
    }
    _pageNo  = pageNo;
    [self fetchBloodPressure];
}

#pragma mark- target actions
- (IBAction)pageAction:(UIButton *)sender
{
    if (sender.tag == 1973) {
        self.pageNo ++;
    }else{
        self.pageNo --;
    }
}

#pragma mark- 初始化报表属性
- (void)initChart
{
    self.chartView.delegate = self;
    self.chartView.descriptionText = @"";
    self.chartView.noDataTextDescription = @"没有血压数据！";
    self.chartView.dragEnabled = YES;
    [self.chartView setScaleEnabled:YES];
    self.chartView.pinchZoomEnabled = YES;
    self.chartView.drawGridBackgroundEnabled = YES;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    leftAxis.valueFormatter = numberFormatter;
    
    [leftAxis removeAllLimitLines];
    
    
    ChartLimitLine *topLine = [[ChartLimitLine alloc] initWithLimit:self.highEnd label:[NSString stringWithFormat:@"高压范围(%d~%d)",self.highStart,self.highEnd]];
    topLine.lineWidth = 0.5;
    topLine.lineColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    [topLine setLabelPosition:ChartLimitLabelPositionRightTop];
    topLine.valueTextColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    topLine.valueFont = [UIFont fontWithName:@"HelveticaNeue" size:8];
    [leftAxis addLimitLine:topLine];
    
    ChartLimitLine *middleLine = [[ChartLimitLine alloc] initWithLimit:self.highStart label:[NSString stringWithFormat:@"低压范围(%d~%d)",self.lowStart,self.highStart]];
    middleLine.lineWidth = 0.5;
    middleLine.lineColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    [middleLine setLabelPosition:ChartLimitLabelPositionRightTop];
    middleLine.valueTextColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    middleLine.valueFont = [UIFont fontWithName:@"HelveticaNeue" size:8];
    [leftAxis addLimitLine:middleLine];
    
    ChartLimitLine *bottomLine = [[ChartLimitLine alloc] initWithLimit:self.lowStart label:[NSString stringWithFormat:@"%d",self.lowStart]];
    bottomLine.lineWidth = 0.5;
    bottomLine.lineColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    [bottomLine setLabelPosition:ChartLimitLabelPositionRightBottom];
    bottomLine.valueTextColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    bottomLine.valueFont = [UIFont fontWithName:@"HelveticaNeue" size:8];
    [leftAxis addLimitLine:bottomLine];

    
    leftAxis.customAxisMax = 160;
    leftAxis.customAxisMin = 40;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.labelCount = 5;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.labelTextColor = UIColor.redColor;
    rightAxis.customAxisMax = 160.0;
    rightAxis.startAtZeroEnabled = NO;
    rightAxis.customAxisMin = 40.0;
    rightAxis.drawGridLinesEnabled = NO;
    
    self.chartView.rightAxis.enabled = NO;
    
    self.chartView.legend.form = ChartLegendFormLine;
}

#pragma mark- 获取报表数据
- (void)updateChartWith:(NSArray*)dataArray
{
    if (dataArray.count == 0) {
        [self.chartView clear];
        return;
    }
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < dataArray.count; i++)
    {
        NSDictionary *model = dataArray[i];
        NSString *timeTemp = model[@"receivetime"];
        NSString *timeValue = [timeTemp substringWithRange:NSMakeRange(8, 4)];
        NSString *finalValue = [NSString stringWithFormat:@"%@:%@",[timeValue substringToIndex:2],[timeValue substringFromIndex:2]];
        [xVals addObject:finalValue];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < dataArray.count; i++)
    {
        NSDictionary *model = dataArray[i];
        int dbp = [model[@"dbp"] intValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:dbp xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"低压"];
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f]];
    set1.lineWidth = 2.0;
    set1.circleRadius = 4.0;
    [set1 setCircleColor:[UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f]];
    set1.fillColor = [UIColor colorWithRed:0/255.f green:157/255.f blue:132/255.f alpha:1.f];
    set1.drawCubicEnabled = YES;
    set1.drawValuesEnabled = YES;
    set1.drawFilledEnabled = YES;
    set1.fillAlpha = 0.4;
    set1.highlightLineWidth = 1;
    set1.highlightColor = [UIColor redColor];
    
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < dataArray.count; i++)
    {
        NSDictionary *model = dataArray[i];
        int sbp = [model[@"sbp"] intValue];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:sbp xIndex:i]];
    }
    
    LineChartDataSet *set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:@"高压"];
    set2.axisDependency = AxisDependencyRight;
    [set2 setColor:[UIColor colorWithRed:126/255.0 green:176/255.0 blue:18/255.0 alpha:1]];
    set2.lineWidth = 2.0;
    set2.circleRadius = 4.0;
    [set2 setCircleColor:[UIColor colorWithRed:126/255.0 green:176/255.0 blue:18/255.0 alpha:1]];
    set2.fillColor = [UIColor colorWithRed:126/255.0 green:176/255.0 blue:18/255.0 alpha:1];
    set2.drawCubicEnabled = YES;
    set2.drawValuesEnabled = YES;
    set2.drawFilledEnabled = YES;
    set2.highlightColor = [UIColor redColor];
    set2.highlightLineWidth = 1;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set2];
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
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight;
{
    
    
    
    NSDictionary *model = self.bloodDataArray[entry.xIndex];
    
    self.pulseLB.text = [NSString stringWithFormat:@"%@",model[@"pulse"]];
    self.highPressureLB.text = [NSString stringWithFormat:@"%@",model[@"sbp"]];
    self.lowPressureLB.text = [NSString stringWithFormat:@"%@",model[@"dbp"]];
    
    NSString *orignalDateString = model[@"receivetime"];
    NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
    NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
    
    NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
    NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
    
    self.dateLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];
    
}

#pragma mark- 获取血压数据
- (void)fetchBloodPressure
{
    [ProgressHUD show:@"获取数据中..." Interaction:YES];
    NSString *url = @"chunhui/m/data@getBloodData.do";

    NSString *paramString = [NSString stringWithFormat:@"imei=%@&pagenum=%d&pagesize=20",[[NSPublic shareInstance]getImei],self.pageNo];

    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              [ProgressHUD dismiss];
                                                              NSLog(@"%@",jsonData);
                                                              [self formatData:jsonData];
                                                          }];
}

#pragma mark- 格式化数据
- (void)formatData:(NSDictionary*)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self.bloodDataArray removeAllObjects];
    NSArray *data = dictionary[@"data"];
    if ([data isKindOfClass:[NSString class]]) {
        return;
    }
    for (NSDictionary *modelDic in data){
        [self.bloodDataArray addObject:modelDic];
    }
    [self updateChartWith:self.bloodDataArray];
    
    NSDictionary *model = [self.bloodDataArray lastObject];
    
    if ([model isKindOfClass:[NSDictionary class]]) {
        self.pulseLB.text = [NSString stringWithFormat:@"%@",model[@"pulse"]];
        self.highPressureLB.text = [NSString stringWithFormat:@"%@",model[@"sbp"]];
        self.lowPressureLB.text = [NSString stringWithFormat:@"%@",model[@"dbp"]];
        
        NSString *orignalDateString = model[@"receivetime"];
        NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
        
        NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
        
        self.dateLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];
    }
    
    
}

@end
