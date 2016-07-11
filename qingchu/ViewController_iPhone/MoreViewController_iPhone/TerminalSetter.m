//
//  TerminalSetter.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "TerminalSetter.h"
#import "CanHideTF.h"
#import "Alert.h"
#import "NSPublic.h"
#import "DataPublic.h"
#import "ProgressHUD.h"
#import "MBProgressHUD.h"

@interface TerminalSetter ()
@property (weak, nonatomic) IBOutlet CanHideTF *gpsFrequency;
@property (weak, nonatomic) IBOutlet CanHideTF *heartReateFrequency;

@end

@implementation TerminalSetter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillInitData];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    if ([self validate]) {
        [self fillToServer];
    }
}


- (void)fillInitData
{
    self.gpsFrequency.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getgpsinterval]];
    self.heartReateFrequency.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getpulseinterval]];
}

- (BOOL)validate
{
    int gpsFrequency = [self.gpsFrequency.text intValue];
    int heartRateFrequency = [self.heartReateFrequency.text intValue];
    
    if (gpsFrequency <= 0 || heartRateFrequency<= 0) {
        [[Alert sharedAlert] showMessage:@"请输入有效的频率！"];
        return NO;
    }
    return YES;
}
- (void)fillToServer
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    __block NSString *status = nil;
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],@"gps",self.gpsFrequency.text ,[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updateCollectSetting.do"] with:array0 with:@"updateCollectSetting.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        if ([status isEqualToString:@"0" ])
        {
            [[NSPublic shareInstance]setgps:self.gpsFrequency.text];
        }
        
        sleep(1.5);
        array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],@"pulse",self.heartReateFrequency.text ,[[NSPublic shareInstance]getJSESSION],nil];
        dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updateCollectSetting.do"] with:array0 with:@"updateCollectSetting.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        if ([status isEqualToString:@"0" ])
        {
            [[NSPublic shareInstance]setpulse:self.heartReateFrequency.text];
        }
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        [HUD removeFromSuperview];
        if ([status isEqualToString:@"0" ])
        {
            [[DataPublic shareInstance]getSettingInfo];
            [ProgressHUD showSuccess:@"保存成功!" Interaction:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }
        else
        {
            [ProgressHUD showError:@"设置失败" Interaction:YES];
        }
    }];

}

@end
