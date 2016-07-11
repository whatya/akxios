//
//  LocationSetter.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "LocationSetter.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "DataPublic.h"
#import "MBProgressHUD.h"

@interface LocationSetter ()

@property (weak, nonatomic) IBOutlet UISwitch *alert;

@end

@implementation LocationSetter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillInitData];
}
- (IBAction)save:(UIBarButtonItem *)sender {
    [self fillToServer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)fillInitData
{
    self.alert.on = [[NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getgpsalarm]] isEqualToString: @"1"];
}

- (void)fillToServer
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    NSString* positionSwitchValue = self.alert.isOn ? @"1" : @"0";
    __block NSString *status = nil;
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],positionSwitchValue,[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updateLocSetting.do"] with:array0 with:@"updateLocSetting.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        [[DataPublic shareInstance]getSettingInfo];
        
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
