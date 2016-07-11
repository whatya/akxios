//
//  StepSettingTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/14.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "StepSettingTVC.h"
#import "NSPublic.h"
#import "DataPublic.h"
#import "UIView+Toast.h"
#import "ProgressHUD.h"
#import "MBProgressHUD.h"

@interface StepSettingTVC ()
<UIPickerViewDataSource,
UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *stepValue;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic,strong) NSArray *stepsArray;

@property (nonatomic,strong) NSString *initialStepValue;

@end

@implementation StepSettingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"运动设置";
    self.pickerView.delegate = self;
    self.stepsArray = @[@"3000",@"4000",@"5000",
                        @"6000",@"7000",@"8000",
                        @"9000",@"10000",@"11000",
                        @"12000",@"13000",@"14000",
                        @"15000",@"16000",@"17000",
                        @"18000",@"19000",@"20000"];
    [self.pickerView reloadAllComponents];
    
    NSString *formerSelectedString = [NSString stringWithFormat:@"%@",[[NSPublic shareInstance] getstepmax]];
    [self.pickerView selectRow:[self.stepsArray indexOfObject:formerSelectedString] inComponent:0 animated:YES];
    self.stepValue.text = formerSelectedString;
    self.initialStepValue = self.stepValue.text;
}
- (IBAction)save:(UIBarButtonItem *)sender {
    
    [self postStepSetting];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.stepsArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.stepsArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *stepValue = self.stepsArray[row];
    self.stepValue.text = [stepValue stringByReplacingOccurrencesOfString:@"步" withString:@""];
}

- (void)postStepSetting
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    NSString __block *status = nil;
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],self.stepValue.text,@"1",[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updateStepSetting.do"] with:array0 with:@"updateStepSetting.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        NSLog(@"%@",status);
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
