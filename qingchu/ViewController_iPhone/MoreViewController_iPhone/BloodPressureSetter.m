//
//  BloodPressureSetter.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "BloodPressureSetter.h"
#import "CanHideTF.h"
#import "Alert.h"
#import "NSPublic.h"
#import "DataPublic.h"
#import "ProgressHUD.h"
#import "MBProgressHUD.h"

@interface BloodPressureSetter ()
@property (weak, nonatomic) IBOutlet CanHideTF *lowStartTF;
@property (weak, nonatomic) IBOutlet CanHideTF *lowEndTF;

@property (weak, nonatomic) IBOutlet CanHideTF *hightStartTF;
@property (weak, nonatomic) IBOutlet CanHideTF *hightEndTF;

@property (weak, nonatomic) IBOutlet UISwitch *alert;

@end

@implementation BloodPressureSetter

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
    int lowStart = [self.lowStartTF.text intValue];
    int lowEnd = [self.lowEndTF.text intValue];
    
    int highStart = [self.hightStartTF.text intValue];
    int highEnd = [self.hightEndTF.text intValue];
    
    if (lowStart < 0 || lowStart > 250 || lowEnd < lowStart || lowEnd < 0 || lowEnd > 250) {
        [[Alert sharedAlert] showMessage:@"请输入正确低压范围：0-250"];
        NO;
    }
    
    if (highStart < 0 || highStart > 250 || highEnd < highStart || highEnd < 0 || highEnd > 250) {
        [[Alert sharedAlert] showMessage:@"请输入正确低压范围：0-250"];
        NO;
    }
    
    if (lowEnd > highEnd) {
        [[Alert sharedAlert] showMessage:@"低压范围不能高于高压范围！"];
        NO;
    }
    return YES;
}

- (void)fillInitData
{
    self.hightStartTF.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance] getsbpmin]];
    self.hightEndTF.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance] getsbpmax]];
    
    self.lowStartTF.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance] getdbpmin]];
    self.lowEndTF.text = [NSString stringWithFormat:@"%@", [[NSPublic shareInstance] getdbpmax]];
    
    self.alert.on = [[NSString stringWithFormat:@"%@", [[NSPublic shareInstance]getbloodalarm]]
                     isEqualToString: @"1"];
}

- (void)fillToServer
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    __block NSString *status = nil;
    
    NSString *bloodPressSwitchValue = self.alert.isOn ? @"1" : @"0";
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],
                           self.lowStartTF.text,
                           self.lowEndTF.text,
                           self.hightStartTF.text,
                           self.hightEndTF.text,
                           bloodPressSwitchValue,
                           [[NSPublic shareInstance]getJSESSION],nil];
        
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updateBloodSetting.do"] with:array0 with:@"updateBloodSetting.do"];
        status  =  [NSString stringWithFormat:@"%@",[dictionary0 objectForKey:@"status"]];
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
