//
//  PUSHSettingVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/14.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "PUSHSettingVC.h"
#import "NSPublic.h"
#import "UIView+Toast.h"
#import "ProgressHUD.h"
#import "DataPublic.H"
#import "MBProgressHUD.h"

@interface PUSHSettingVC ()

@property (weak, nonatomic) IBOutlet UISwitch *open;
@property (weak, nonatomic) IBOutlet UITextField *hourLB;
@property (weak, nonatomic) IBOutlet UITextField *minLB;

@property(nonatomic,strong) NSString *initialHourValue;
@property(nonatomic,strong) NSString *initialMinValue;
@property (nonatomic) BOOL initialOpenValue;

@end

@implementation PUSHSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hourLB.text = @"";
    self.minLB.text = @"";
    
    self.initialHourValue = self.hourLB.text;
    self.initialMinValue = self.minLB.text;
    self.initialOpenValue = self.open.isOn;
    self.title = @"推送设置";
    
    
}



- (IBAction)save:(UIBarButtonItem *)sender {
    [self postSetting];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)postSetting
{
    NSString __block *status = nil;
    if (self.hourLB.text.length == 0 || self.minLB.text.length == 0) {
        [self.view makeToast:@"请输入正确的时间" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    
    NSString *isPush = self.open.isOn ? @"1" : @"0";
    NSString *time = [NSString stringWithFormat:@"%@%@",self.hourLB.text,self.minLB.text];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],time,isPush,[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"updatePushSetting.do"] with:array0 with:@"updatePushSetting.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        
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
