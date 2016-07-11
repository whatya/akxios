//
//  HeartBeatSetter.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "HeartBeatSetter.h"
#import "CanHideTF.h"
#import "Alert.h"
#import "NSPublic.h"
#import "DataPublic.h"
#import "ProgressHUD.h"
#import "MBProgressHUD.h"

@interface HeartBeatSetter ()
@property (weak, nonatomic) IBOutlet CanHideTF *startTF;
@property (weak, nonatomic) IBOutlet CanHideTF *endTF;
@property (weak, nonatomic) IBOutlet UISwitch *alert;

@end

@implementation HeartBeatSetter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillInitData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
- (IBAction)save:(UIBarButtonItem *)sender {
    if ([self validate]) {
        [self fillToServer];
    }
}

- (BOOL)validate
{
    int startValue = [self.startTF.text intValue];
    int endValue = [self.endTF.text intValue];
    if (startValue < 0 || endValue > 250 || startValue > endValue) {
        [[Alert sharedAlert] showMessage:@"请设置合理的心率安全范围!(0~255)"];
        return NO;
    }
    return YES;
}

- (void)fillInitData
{
    self.startTF.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getpulsemin]];
    self.endTF.text = [NSString stringWithFormat:@"%@",[[NSPublic shareInstance]getpulsemax]];
    self.alert.on = [[NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getpulsealarm]] isEqualToString:@"1"];
}
- (void)fillToServer
{
    __block NSString *status = nil;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    NSString *showSwitchValue = self.alert.isOn ? @"1" : @"0";
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],self.endTF.text,self.startTF.text,showSwitchValue,[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updatePulseSetting.do"] with:array0 with:@"updatePulseSetting.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        [[DataPublic shareInstance]getSettingInfo];
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        [HUD removeFromSuperview];
        if ([status isEqualToString:@"0" ])
        {
            [[DataPublic shareInstance]getSettingInfo];
            [ProgressHUD showSuccess:@"保存成功!" Interaction:YES];
            
            void (^temp)() = self.setCallbac;
            if (temp) {
                temp();
            }
            
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
