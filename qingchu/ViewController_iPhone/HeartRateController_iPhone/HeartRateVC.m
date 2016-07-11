//
//  HeartRateVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/25.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "HeartRateVC.h"
#import "HttpManager.h"
#import "qingchu-swift.h"
#import "MBProgressHUD.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "UIViewController+CusomeBackButton.h"
#import "CommonConstants.h"
#import "DataManager.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width

@interface HeartRateVC ()<ChartViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *scopeLabel;

@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;

@property (weak, nonatomic) IBOutlet LineChartView *leftLineChart;
@property (weak, nonatomic) IBOutlet LineChartView *rightLineChart;
@property (weak, nonatomic) IBOutlet UILabel *hearRateLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bannerScrollView;

@property (weak, nonatomic) IBOutlet UIView *notNormalView;
@property (weak, nonatomic) IBOutlet UIView *normalView;

@property (weak, nonatomic) IBOutlet UIButton *displayByDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *displayByNumBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UIButton *mesureBtn;

@property (weak, nonatomic) IBOutlet UIImageView *redHeart;
@property (weak, nonatomic) IBOutlet UILabel *timeLB;


@property (nonatomic,strong) NSMutableArray *leftChartTimesArray;
@property (nonatomic,strong) NSMutableArray *leftChartPulseArray;

@property (nonatomic,strong) NSMutableArray *rightChartTimesArray;
@property (nonatomic,strong) NSMutableArray *rightChartPulseArray;

@property (nonatomic,strong) NSString* dateConditionString;
@property (nonatomic)        int pageNo;

@property (nonatomic,strong) NSTimer *countDownTimer;
@property (nonatomic)        int secondsCountDown;
@property (nonatomic)        BOOL shouldRedHeartAnimationContinue;

@property (nonatomic)        BOOL showBannerOnRight;

@property (strong,nonatomic) DataManager *dataManager;

@property (nonatomic,assign) int highRate;
@property (nonatomic,assign) int lowRate;


@property (nonatomic,assign) int leftMax;
@property (nonatomic,assign) int rightMax;

@end

@implementation HeartRateVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    NSLog(@"心率页面初始化");
    if (self.imei.length == 0) {
        self.imei = [[NSPublic shareInstance] getImei];
    }
    
    self.lowRate = [[[NSPublic shareInstance]getpulsemin] intValue];
    if (self.lowRate == 0) {
        self.lowRate = 55;
    }
    self.highRate = [[[NSPublic shareInstance]getpulsemax] intValue];
    if (self.highRate == 0) {
        self.highRate = 110;
    }
    
    self.scopeLabel.text = [NSString stringWithFormat:@"安全范围:%d~%d次/分",self.lowRate,self.highRate];
    
    [self setUpBackButton];
    self.leftChartPulseArray = [NSMutableArray new];
    self.leftChartTimesArray = [NSMutableArray new];
    self.rightChartPulseArray = [NSMutableArray new];
    self.rightChartTimesArray = [NSMutableArray new];
    
    self.notNormalView.layer.borderColor = [UIColor grayColor].CGColor;
    self.notNormalView.layer.borderWidth = 1;
    self.normalView.layer.borderColor = [UIColor grayColor].CGColor;
    self.normalView.layer.borderWidth = 1;
    
    self.mesureBtn.clipsToBounds = YES;
    self.mesureBtn.layer.cornerRadius = 10.0;
    
    self.dateBtn.clipsToBounds = YES;
    self.dateBtn.layer.cornerRadius = 10.0;
    
    [self initChartView:self.leftLineChart];
    [self initChartView:self.rightLineChart];
    
    self.scrollView.delegate = self;
    
    self.dateConditionString = [self currentDateString];
    self.pageNo = 1;
    
    if (self.mesuredPulse[@"pulse"]) {
        
        self.hearRateLabel.text = [self.mesuredPulse objectForKey:@"pulse"];
        NSString *orignalDateString = [self.mesuredPulse objectForKey:@"receivetime"];
        NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
        
        NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
        
        self.timeLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];
        ToUserDefaults(@"leftSeconds", @(0));
    }else{
        int leftSeconds = [FromUserDefaults(@"leftSeconds") intValue];
        
        NSLog(@"剩余秒数＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝》%d",leftSeconds);
        if (leftSeconds > 0) {
            
            NSDate *startTime = FromUserDefaults(@"mesureStart");
            
            int secondsFromStart = [[NSDate date] timeIntervalSinceDate:startTime];
            
            if (secondsFromStart > 110) {
                return;
            }
            
            
            NSDate *stopDate = FromUserDefaults(@"quitTime");
            
            int  psssedSeconds = [[NSDate date] timeIntervalSinceDate:stopDate];
            
            NSLog(@"已经过去＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝》%d",psssedSeconds);
            
            int continueSeconds = leftSeconds - psssedSeconds;
            
            if (continueSeconds > 0) {
                NSLog(@"还需测量＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝》%d",continueSeconds);
                [self.mesureBtn setTitle:@"测量中..." forState:UIControlStateNormal];
                self.mesureBtn.enabled = NO;
                self.shouldRedHeartAnimationContinue = YES;
                
                self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
                self.secondsCountDown = continueSeconds;
                CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                k.values = @[@(0.5),@(1.0),@(1.2)];
                k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
                k.calculationMode = kCAAnimationLinear;
                k.autoreverses = YES;
                k.fillMode = kCAFillModeForwards;
                k.repeatCount = MAXFLOAT;
                k.duration = 0.6;
                [self.redHeart.layer addAnimation:k forKey:@"SHOW"];
            }
            
        }
        
    }
    
    self.dataManager = [[DataManager alloc] init];
    [self configureRateBtn];
}

- (void)configureRateBtn
{
    UIButton *rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rateBtn.frame = CGRectMake(0, 0, 24, 24);
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],2)) {
        [rateBtn setImage:[UIImage imageNamed:@"rated"] forState:UIControlStateNormal];
    }else{
        [rateBtn setImage:[UIImage imageNamed:@"rate"] forState:UIControlStateNormal];
    }
    
    [rateBtn addTarget:self action:@selector(rate) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rateBtn];
}


- (void)rate
{
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],2)) {
        [ProgressHUD showError:@"您今天已点过赞！" Interaction:YES];
        return;
    }
    
    
    
    [self.dataManager zanWithUser:[[NSPublic shareInstance]getUserName]  imei:[[NSPublic shareInstance]getImei] andType:3 result:^(BOOL status, NSString *error) {
        
        if (status) {
            [ProgressHUD showSuccess:@"点赞成功！" Interaction:YES];
            rate([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],2);
            [self configureRateBtn];
        }else{
            [ProgressHUD showError:error Interaction:YES];
        }
        
    }];
    
}

- (void)setSecondsCountDown:(int)secondsCountDown
{
    _secondsCountDown = secondsCountDown;
    self.countDownLabel.text = [NSString stringWithFormat:@"%d",secondsCountDown - 20];
    if (secondsCountDown != 20) {
        self.countDownLabel.hidden = YES;
    }else{
        self.countDownLabel.hidden = YES;
    }
}

- (void)timerFireMethod
{
    NSLog(@"%d",120 - self.secondsCountDown);
    self.secondsCountDown--;

    if (self.secondsCountDown == 0) {
        NSLog(@"time out");
        ToUserDefaults(@"leftSeconds", @(0));
        self.shouldRedHeartAnimationContinue = NO;
        [ProgressHUD showError:@"测量超时，请稍候再试！" Interaction:YES];
        self.mesureBtn.enabled = YES;
        [self.mesureBtn setTitle:@"测量" forState:UIControlStateNormal];
        [self.redHeart.layer removeAllAnimations];
        [self.countDownTimer invalidate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [NSPublic shareInstance].vcIndex = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartSendAction:)
                                                 name:@"heartSendNotice" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueAnimation)
                                                 name:@"appReactive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation) name:@"watch offline" object:nil];

    if (self.shouldRedHeartAnimationContinue) {
        CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        k.values = @[@(0.5),@(1.0),@(1.2)];
        k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
        k.calculationMode = kCAAnimationLinear;
        k.autoreverses = YES;
        k.fillMode = kCAFillModeForwards;
        k.repeatCount = MAXFLOAT;
        k.duration = 0.6;
        [self.redHeart.layer addAnimation:k forKey:@"SHOW"];
    }
}

- (void)stopAnimation
{
    ToUserDefaults(@"leftSeconds", @(0));
    self.secondsCountDown = 0;
    [self.mesureBtn setTitle:@"测量" forState:UIControlStateNormal];
    self.mesureBtn.enabled = YES;
    [self.redHeart.layer removeAllAnimations];
    [self.countDownTimer invalidate];

}

- (void)continueAnimation
{
    if (self.secondsCountDown != 0) {
        [self.countDownTimer invalidate];
        CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        k.values = @[@(0.5),@(1.0),@(1.2)];
        k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
        k.calculationMode = kCAAnimationLinear;
        k.autoreverses = YES;
        k.fillMode = kCAFillModeForwards;
        k.repeatCount = MAXFLOAT;
        k.duration = 0.6;
        [self.redHeart.layer addAnimation:k forKey:@"SHOW"];
       self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.countDownTimer invalidate];
    [NSPublic shareInstance].vcIndex = 0;
    
    if (self.secondsCountDown != 0) {
        ToUserDefaults(@"leftSeconds", @(self.secondsCountDown));
        ToUserDefaults(@"quitTime", [NSDate date]);
    }else{
        ToUserDefaults(@"leftSeconds", @(0));
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)heartSendAction:(NSNotification *)notification
{
    NSLog(@"通知被调用！");
    ToUserDefaults(@"leftSeconds", @(0));
    NSDictionary *userInfo = [notification object];
    self.secondsCountDown = 0;
    
    if (userInfo[@"pulse"]) {
        self.mesuredPulse = userInfo;
        [self.countDownTimer invalidate];
        self.countDownLabel.text = @"0";
        self.countDownLabel.hidden = YES;
        self.shouldRedHeartAnimationContinue = NO;
        NSLog(@"成功获取心率数据!");
        [ProgressHUD showSuccess:@"心率获取成功！" Interaction:YES];
        self.hearRateLabel.text = [userInfo objectForKey:@"pulse"];
        self.imei = [userInfo objectForKey:@"imei"];

        
        NSString *orignalDateString = [userInfo objectForKey:@"receivetime"];
        NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
        
        NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
        
        self.timeLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];

        self.dateConditionString = [self currentDateString];
        self.pageNo = 1;
        self.mesureBtn.enabled = YES;
        [self.mesureBtn setTitle:@"测量" forState:UIControlStateNormal];
        [self.redHeart.layer removeAllAnimations];
        [self.countDownTimer invalidate];
    }
}


#pragma mark- 布局
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.showBannerOnRight) {
        [self.bannerScrollView setContentOffset:CGPointMake(self.view.bounds.size.width/2, 0)];
    }
    
}

#pragma mark- 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollView]) {
        if (scrollView.contentOffset.x == 0) {
             [self.bannerScrollView setContentOffset:CGPointMake(Screen_Width/2, 0) animated:YES];
            self.showBannerOnRight = NO;
        }
        
        if (scrollView.contentOffset.x == Screen_Width) {
           [self.bannerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            self.showBannerOnRight = YES;
        }
    }
}

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight;
{
    
    if ([chartView isEqual:self.leftLineChart]) {
        
        self.hearRateLabel.text = [NSString stringWithFormat:@"%@",self.leftChartPulseArray[entry.xIndex]];
        NSString *orignalDateString = self.leftChartTimesArray[entry.xIndex];
        
        NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
        
        NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
        
        self.timeLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];
        
    }else{
        
        self.hearRateLabel.text = [NSString stringWithFormat:@"%@",self.rightChartPulseArray[entry.xIndex]];
        NSString *orignalDateString = self.rightChartTimesArray[entry.xIndex];
        
        NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
        
        NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
        
        self.timeLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];

    }
 
}


#pragma mark- 时间转换方法
- (NSString*)currentDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

- (NSString*)preDateString
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[[dateFormatter dateFromString:self.dateConditionString] dateByAddingTimeInterval:-secondsPerDay]];
    return currentDateStr;
}

- (NSString*)nexDateString
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *nextDateStr = [dateFormatter stringFromDate:[[dateFormatter dateFromString:self.dateConditionString] dateByAddingTimeInterval:secondsPerDay]];
    
    return nextDateStr;
}


#pragma mark- Target Actions methods
- (IBAction)toggleDisplayMode:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"按条展示"]) {
        
        [self.scrollView setContentOffset:CGPointMake(Screen_Width, 0) animated:YES];
        [self.bannerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }else{
        
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.bannerScrollView setContentOffset:CGPointMake(Screen_Width/2, 0) animated:YES];
    }
}

- (IBAction)toogleCondition:(UIButton *)sender
{
    if (sender.tag == 1973) {
        self.dateConditionString = [self preDateString];
    }else if (sender.tag == 1974){
        self.dateConditionString = [self nexDateString];
    }else if (sender.tag == 1975){
        self.pageNo++;
    }else{
        self.pageNo--;
    }
}

- (IBAction)sendCommond:(UIButton *)sender
{
    [sender setTitle:@"测量中..." forState:UIControlStateNormal];
    ToUserDefaults(@"mesureStart", [NSDate date]);
    sender.enabled = NO;
    self.shouldRedHeartAnimationContinue = YES;
    
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
    self.secondsCountDown = 120;
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.5),@(1.0),@(1.2)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    k.autoreverses = YES;
    k.fillMode = kCAFillModeForwards;
    k.repeatCount = MAXFLOAT;
    k.duration = 0.6;
    [self.redHeart.layer addAnimation:k forKey:@"SHOW"];
    [self sendPulseMesureCommond];
   
}

#pragma mark- setter 方法
- (void)setDateConditionString:(NSString *)dateConditionString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    if ([dateConditionString compare:currentDateStr] == NSOrderedDescending) {
        [ProgressHUD showError:@"已是最新数据！" Interaction:YES];
        return;
    }
    
    _dateConditionString = dateConditionString;
    
    int month = [[dateConditionString substringWithRange:NSMakeRange(4, 2)] intValue];
    int day = [[dateConditionString substringWithRange:NSMakeRange(6, 2)] intValue];
    [self.dateBtn setTitle:[NSString stringWithFormat:@"%d月%d日",month,day] forState:UIControlStateNormal];
    
    [self fetchPulseDataWithType:0];
    
    
}

- (void)setMesuredPulse:(NSDictionary *)mesuredPulse
{
    _mesuredPulse = mesuredPulse;
    self.imei = [mesuredPulse objectForKey:@"imei"];
    NSString *vcTitle = [NSString stringWithFormat:@"%@的心率", mesuredPulse[@"name"]];
    if (!mesuredPulse[@"name"]) {
        vcTitle = @"心率";
    }
    
    if ([mesuredPulse[@"imei"] isEqualToString:[[NSPublic shareInstance] getImei]]) {
        vcTitle = [[NSPublic shareInstance] getname];
    }else{
        
    }
    self.title = vcTitle;
}

- (void)setPageNo:(int)pageNo
{
    if (pageNo < 0) {
        [ProgressHUD showError:@"已经是最新数据！" Interaction:YES];
        return;
    }
    _pageNo = pageNo;
    [self fetchPulseDataWithType:1];
}

#pragma mark- 显示报表
- (void)updateChart:(LineChartView*)chartView withXVals:(NSArray*)xDatas andYVals:(NSArray*)yDatas
{
    
    if ([chartView isEqual:self.leftLineChart]) {
        if (self.leftMax == 0) {
            self.leftMax = 140;
        }
        
        if (self.rightMax == 140) {
            self.rightMax = 140;
        }
        
        chartView.leftAxis.customAxisMax = self.leftMax;
        
    }else{
        chartView.leftAxis.customAxisMax = self.rightMax;
    }
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    if (xDatas.count == 0) {
        [chartView clear];
        return;
    }
    
    for (int i = 0; i < xDatas.count; i++)
    {
        NSString *timeTemp = xDatas[i];
        NSString *timeValue = [timeTemp substringWithRange:NSMakeRange(8, 4)];
        NSString *finalValue = [NSString stringWithFormat:@"%@:%@",[timeValue substringToIndex:2],[timeValue substringFromIndex:2]];
        [xVals addObject:finalValue];
    }
    
//    [xVals sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
//        return [obj1 compare:obj2];
//    }];
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < yDatas.count; i++)
    {
        int pulse = [yDatas[i] doubleValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:pulse xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"心率"];
    
    
    [set1 setColor:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:207/255.0 alpha:1]];
    set1.lineWidth = 2.0;
    set1.circleRadius = 4.0;
    set1.drawCircleHoleEnabled = YES;
    set1.drawCubicEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:6.f];
   // set1.drawFilledEnabled = YES;
    set1.fillAlpha = 0.4;
    set1.fillColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:207/255.0 alpha:1];
    set1.highlightColor = [UIColor redColor];
    set1.highlightLineWidth = 1.0;
    
    NSMutableArray *circleColors = [NSMutableArray new];
    for (int i = 0; i < yDatas.count; i++) {
        
        int value = [yDatas[i] intValue];
        if (value > self.highRate || value < self.lowRate) {
            [circleColors addObject:[UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1]];
        }else{
            [circleColors addObject:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:207/255.0 alpha:1]];
        }
    }
    
    [set1 setCircleColors:circleColors];
    
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    [data setValueFormatter:numberFormatter];
    
    chartView.data = data;
    [chartView animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
    
    
    //显示最后一跳数据
    NSString *temp = [NSString stringWithFormat:@"%d",[[self.leftChartPulseArray lastObject] intValue]];
    if (temp.length > 0 && [temp isKindOfClass:[NSString class]] && self.mesuredPulse == nil) {
        self.hearRateLabel.text = temp;
    }
    
    NSString *orignalDateString = [self.leftChartTimesArray lastObject];
    
    NSString *year = [orignalDateString substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [orignalDateString substringWithRange:NSMakeRange(4, 2)];
    NSString *day = [orignalDateString substringWithRange:NSMakeRange(6, 2)];
    
    NSString *hour = [orignalDateString substringWithRange:NSMakeRange(8, 2)];
    NSString *min = [orignalDateString substringWithRange:NSMakeRange(10, 2)];
    
    if (year.length > 0 && self.mesuredPulse == nil) {
         self.timeLB.text = [NSString stringWithFormat:@"%@年%@月%@日%@时%@分",year,month,day,hour,min];
    }
    
   
}

#pragma mark- 初始化报表
- (void)initChartView:(LineChartView*)lineChartView
{
    lineChartView.delegate = self;
    lineChartView.descriptionText = @"  ";
    lineChartView.noDataTextDescription = @"没有心率数据！";
    lineChartView.dragEnabled = YES;
    [lineChartView setScaleEnabled:YES];
    lineChartView.pinchZoomEnabled = YES;
    lineChartView.drawGridBackgroundEnabled = NO;
    
    
    ChartYAxis *leftAxis = lineChartView.leftAxis;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    leftAxis.valueFormatter = numberFormatter;
    
    
    [leftAxis removeAllLimitLines];
    
    
       
    ChartLimitLine *bottomLine = [[ChartLimitLine alloc] initWithLimit:self.lowRate label:[NSString stringWithFormat:@"低心率%d",self.lowRate]];
    bottomLine.lineWidth = 0.5;
    bottomLine.lineColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    [bottomLine setLabelPosition:ChartLimitLabelPositionRightBottom];
    bottomLine.valueTextColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    bottomLine.valueFont = [UIFont fontWithName:@"HelveticaNeue" size:8];;
    [leftAxis addLimitLine:bottomLine];
    
    ChartLimitLine *topLine = [[ChartLimitLine alloc] initWithLimit:self.highRate label:[NSString stringWithFormat:@"高心率%d",self.highRate]];
    topLine.lineWidth = 0.5;
    topLine.lineColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    [topLine setLabelPosition:ChartLimitLabelPositionRightTop];
    topLine.valueTextColor = [UIColor colorWithRed:231/255.0 green:14/255.0 blue:25/255.0 alpha:1];
    topLine.valueFont = [UIFont fontWithName:@"HelveticaNeue" size:8];;
    [leftAxis addLimitLine:topLine];
    
    leftAxis.customAxisMax = 140;
    leftAxis.customAxisMin = 30;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.labelCount = 6;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    
    lineChartView.rightAxis.enabled = NO;
    BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    lineChartView.marker = marker;

}

#pragma mark- 服务器交互 获取心率数据
- (void)fetchPulseDataWithType:(int)type
{
    [ProgressHUD show:@"获取数据中..." Interaction:YES];
    NSString *url = @"chunhui/m/data@getPulseData.do";
    NSString *paramString = [NSString stringWithFormat:@"imei=%@&starttime=%@&endtime=%@",self.imei,self.dateConditionString,self.dateConditionString];
    if (type == 1) {
        paramString = [NSString stringWithFormat:@"imei=%@&pagenum=%d&pagesize=20",self.imei,self.pageNo];
        url = @"chunhui/m/data@getPulseDataAsNum.do";
    }
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              [ProgressHUD dismiss];
                                                              [self formatData:jsonData withType:type];
                                                          }];
    
}

#pragma mark- 发送心率测量数据
- (void)sendPulseMesureCommond
{
    NSString *url = @"chunhui/m/data@sendPulseOrder.do";
    NSString *paramString = [NSString stringWithFormat:@"sid=%@&imei=%@&JSESSIONID=%@",[[NSPublic shareInstance] getsid],[[NSPublic shareInstance] getImei],[[NSPublic shareInstance]getJSESSION]];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              if (!error) {
                                                                  if (IsSuccessful(jsonData)) {
                                                                      [ProgressHUD showSuccess:@"测量指令发送成功！" Interaction:YES];
                                                                  }else{
                                                                      [self stopAnimation];
                                                                      [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
                                                                  }
                                                              }else{
                                                                  [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
                                                              }
                                                          }];
    
//    NSString *status = nil;
//    
//        NSArray *arrayTest = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getsid], [[NSPublic shareInstance] getImei],[[NSPublic shareInstance]getJSESSION],nil];
//        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"sendPulseOrder.do"] with:arrayTest with:@"sendPulseOrder.do"];
//        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
//        
//        if ([status isEqualToString:@"0" ])
//        {
//            [ProgressHUD showSuccess:@"测量指令发送成功！" Interaction:YES];
//        }
//        else
//        {
//            [self stopAnimation];
//            [ProgressHUD showSuccess:@"测量指令发送失败！" Interaction:YES];
//        }


}

#pragma mark- 格式化数据
- (void)formatData:(NSDictionary*)dictionary withType:(int)type
{
    if (type == 0) {
        [self.leftChartTimesArray removeAllObjects];
        [self.leftChartPulseArray removeAllObjects];
        NSArray *dataArray = dictionary[@"data"];
        if ([dataArray isKindOfClass:[NSString class]]) {
            return;
        }
        int maxTemp = 0;
        for (NSDictionary *pulseAndTime in dataArray){
            
            int temp = [pulseAndTime[@"pulse"] intValue];
            
            if (temp > maxTemp) {
                maxTemp = temp;
            }
            
            self.leftMax = maxTemp+20;
            
            NSString *timeString = pulseAndTime[@"receivetime"];
            [self.leftChartTimesArray addObject:timeString];
            [self.leftChartPulseArray addObject:pulseAndTime[@"pulse"]];
        }
        [self updateChart:self.leftLineChart withXVals:self.leftChartTimesArray andYVals:self.leftChartPulseArray];
    }else{
        [self.rightChartPulseArray removeAllObjects];
        [self.rightChartTimesArray removeAllObjects];
        NSArray *dataArray = dictionary[@"data"];
        if ([dataArray isKindOfClass:[NSString class]]) {
            return;
        }
        
        int maxTemp = 0;
        for (NSDictionary *pulseAndTime in dataArray){
            
            int temp = [pulseAndTime[@"pulse"] intValue];
            
            if (temp > maxTemp) {
                maxTemp = temp;
            }
            
            self.rightMax = maxTemp+20;
            
            NSString *timeString = pulseAndTime[@"receivetime"];
            [self.rightChartTimesArray addObject:timeString];
            [self.rightChartPulseArray addObject:pulseAndTime[@"pulse"]];
        }
        [self updateChart:self.rightLineChart withXVals:self.rightChartTimesArray andYVals:self.rightChartPulseArray];

    }
}

@end
