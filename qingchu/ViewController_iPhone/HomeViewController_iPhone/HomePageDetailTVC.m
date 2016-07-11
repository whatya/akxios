//
//  HomePageDetailTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/27.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "HomePageDetailTVC.h"
#import "NSPublic.h"
#import "UIViewController+CusomeBackButton.h"
#import "DataPublic.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface HomePageDetailTVC ()
@property (weak, nonatomic) IBOutlet UIView *roundBottomView;
@property (weak, nonatomic) IBOutlet UIView *roundBottomView2;
@property (weak, nonatomic) IBOutlet UIView *roundBottomView3;
@property (weak, nonatomic) IBOutlet UIImageView *topIconIMV;

@property (weak, nonatomic) IBOutlet UILabel *positionLB;
@property (weak, nonatomic) IBOutlet UILabel *rateLB;
@property (weak, nonatomic) IBOutlet UILabel *sportLB;

@property (weak, nonatomic) IBOutlet UILabel *positionResultLB;
@property (weak, nonatomic) IBOutlet UILabel *rateResultLB;
@property (weak, nonatomic) IBOutlet UILabel *sportResultLB;


@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *dataLables;


@end

@implementation HomePageDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roundBottomView.clipsToBounds = YES;
    self.roundBottomView.layer.cornerRadius = 20;
    
    self.roundBottomView2.clipsToBounds = YES;
    self.roundBottomView2.layer.cornerRadius = 20;
    
    self.roundBottomView3.clipsToBounds = YES;
    self.roundBottomView3.layer.cornerRadius = 20;
    
    self.title = [[NSPublic shareInstance] getname];
    [self setUpBackButton];
    [self getInitData];
}

- (void)initUIWithData:(NSArray*)data
{
    NSString *currentImei = [[NSPublic shareInstance] getImei];
    if ([currentImei hasPrefix:@"8888"]) {
        self.sportLB.text = @"今日活动量";
    }else{
        self.sportLB.text = @"昨日活动量";
    }
    
    NSArray *dataArray = data; //[[NSPublic shareInstance] getCommArray];
    NSString *s0 = [dataArray objectAtIndexedSubscript:2];
    NSString *s1 = [dataArray objectAtIndexedSubscript:6];
    if ([s0 isEqualToString:@"0"]) {
        self.positionResultLB.text = @"位置正常";
    }else
    {
        self.positionResultLB.text = @"位置异常";
    }
    
    if ([s1 isEqualToString:@"0"]) {
        self.rateResultLB.text = @"心率正常";
    }else
    {
        self.rateResultLB.text = @"心率异常";
    }
    
    for (int i=0; i<[dataArray count]; i++) {
        UILabel *dataLabel = self.dataLables[i];
        dataLabel.text = [dataArray objectAtIndexedSubscript:i];
    }
}


//初始化数据
-(void)getInitData
{
    int watchType = 0;
    NSString *currentImei = [[NSPublic shareInstance] getImei];
    if ([currentImei hasPrefix:@"8888"]) {
        watchType = 0;
    }else{
        watchType = -1;
    }
    
    
    __block int bloodPressCount=0;
    __block int countRate=1;
    __block int hearRateK=1;
//    __block int sportK=1;
    __block float distance = 0;
    __block int disOKCount =0;
    __block int disNOCount =0;
    __block float highHeartRate=0;
    __block float lowHeartRate=0;
    __block int sportOKCount =0;
    __block int highValue=0;
    __block int heartNoValue=0;
    __block NSArray *totalstepsNSArray = [NSArray new];
    __block NSMutableArray *totalstepsArrayHome = [NSMutableArray new];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    __block CLLocationDistance meters;
    [self.view addSubview:HUD];
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //1、血压
        float sbpmax =  [[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getsbpmax]] floatValue];
        float sbpmin=  [[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getsbpmin]] floatValue];
        float dbmax =  [[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getdbpmax]] floatValue];
        float dbmin=  [[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getdbpmin]] floatValue];
        NSDictionary *dict = [[DataPublic shareInstance]getBloodInfo:@"1"];
        NSDictionary *smallDict = [dict objectForKey:@"data"];
        for (id key in smallDict)
        {
            float sbp =  [[NSString stringWithFormat:@"%@",[key objectForKey:@"sbp"]] floatValue]; //高压
            float dbp =  [[NSString stringWithFormat:@"%@",[key objectForKey:@"dbp"]] floatValue]; //低压
            if ( sbp>=sbpmin && sbp<=sbpmax && dbp>=dbmin && dbp<=dbmax) {
                bloodPressCount++;
            }
        }
        //2、心率
        float pulsemax =  [[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getpulsemax]] floatValue];
        float pulsemix =  [[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getpulsemin]] floatValue];
        dict = [[DataPublic shareInstance]getHeatRateInfo:0];
        smallDict = [dict objectForKey:@"data"];
        for (id key in smallDict)
        {
            float pulse =  [[NSString stringWithFormat:@"%@",[key objectForKey:@"pulse"]] floatValue]; //高压
            if (hearRateK==1) {
                lowHeartRate = pulse;
                highHeartRate= pulse;
            }
            if ( pulse>=pulsemix && pulse<=pulsemax) {
                countRate++;
            }else
            {
                heartNoValue++;
            }
            if (pulse>highHeartRate) {
                highHeartRate = pulse;
            }
            if (pulse<lowHeartRate) {
                lowHeartRate = pulse;
            }
            hearRateK++;
        }
        
        //3、运动
        //昨日的步数
        dict = [[DataPublic shareInstance]getSportInfo:watchType];
        NSDictionary *sportDict = [dict objectForKey:@"data"];
        for (id key in sportDict)
        {
            totalstepsNSArray = [[NSString stringWithFormat:@"%@" ,[key objectForKey:@"totalsteps"]] componentsSeparatedByString:@"|"];
        }
        if ([totalstepsNSArray count]==49)
        {
            for(int m=1 ;m<=48;m=m+2)
            {
                float fbegin = [[NSString stringWithFormat:@"%@",[totalstepsNSArray objectAtIndex:m-1]] floatValue  ];
                float fend = [[NSString stringWithFormat:@"%@",[totalstepsNSArray objectAtIndex:m]] floatValue];
                [totalstepsArrayHome addObject: [NSString stringWithFormat:@"%f",fbegin+fend]];
            }
        } else if ([totalstepsNSArray count]==13)
        {
            for(int m=1 ;m<=12;m++)
            {
                float fbegin = [[NSString stringWithFormat:@"%@",[totalstepsNSArray objectAtIndex:m-1]] floatValue];
                [totalstepsArrayHome addObject: [NSString stringWithFormat:@"%f",fbegin]];
            }
        }
        for (int n=0; n<[totalstepsArrayHome count]; n++) {
            if (totalstepsNSArray == nil)
            {
                break;
            }
            int fcount= [[NSString stringWithFormat:@"%@", [totalstepsArrayHome objectAtIndex:n]] intValue];
            
            if (fcount!=0) {
                sportOKCount++;
            }
            
            if (fcount>highValue) {
                highValue = fcount;
            }
        }
        
        //4、距离
        //获取所有的设置信息
        dict = [[DataPublic shareInstance]getLocationInfo:[[NSPublic shareInstance]getDate:0] with:[[NSPublic shareInstance]getDate:1]];
        
        smallDict = [dict objectForKey:@"data"];
        
        CLLocation *current=[[CLLocation alloc] initWithLatitude:[[NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getsafelat]] doubleValue] longitude:[[NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getsafelon]] doubleValue]];
        if (current!=nil && current.coordinate.longitude!=0.0) {
            for (id key in smallDict)
            {
                disOKCount++;
                //第二个坐标
                CLLocation *before=[[CLLocation alloc] initWithLatitude:[[NSString stringWithFormat:@"%@",  [key objectForKey:@"lbslat"]]  doubleValue] longitude:[[NSString stringWithFormat:@"%@",  [key objectForKey:@"lbslon"]]  doubleValue]];
                
                if ([[NSString stringWithFormat:@"%@",  [key objectForKey:@"lbslat"]] isEqualToString:@"0"])
                {
                    continue;
                }
                
                // 计算距离
                //  meters=[current distanceFromLocation:before];
                
                meters =  [[NSPublic shareInstance]distanceBetweenOrderBy:current.coordinate.latitude:before.coordinate.latitude:current.coordinate.longitude:before.coordinate.longitude];
                if (meters>distance) {
                    distance = meters;
                }
                if (distance/1000>[[[NSPublic shareInstance]getradius] floatValue])
                {
                    disNOCount++;
                }
            }
        }
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        //血压数据获取
        
        if (hearRateK>=1) {
            hearRateK--;
        }
        
        if (totalstepsNSArray.count > 0) {
            NSArray *contentArray = [[NSArray alloc] initWithObjects:
                                     [NSString stringWithFormat:@"%d",disOKCount],[NSString stringWithFormat:@"%.1f",distance/1000],[NSString stringWithFormat:@"%d",disNOCount],[NSString stringWithFormat:@"%d",hearRateK],[NSString stringWithFormat:@"%.0f",highHeartRate],[NSString stringWithFormat:@"%.0f",lowHeartRate],[NSString stringWithFormat:@"%d",heartNoValue],[NSString stringWithFormat:@"%d",sportOKCount],[NSString stringWithFormat:@"%d",highValue],[totalstepsNSArray objectAtIndex:48],nil];
            [self initUIWithData:contentArray];
        }
        
        [HUD removeFromSuperview];
    }];
    
}


@end
