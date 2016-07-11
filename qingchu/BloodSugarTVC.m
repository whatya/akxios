//
//  BloodSugarTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/30.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "BloodSugarTVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "InputPanle.h"
#import "ProgressHUD.h"

@interface BloodSugarTVC ()

@property (weak, nonatomic) IBOutlet UITextField *breakfastTF;
@property (weak, nonatomic) IBOutlet UITextField *launchTF;
@property (weak, nonatomic) IBOutlet UITextField *dinnerTF;

@end

@implementation BloodSugarTVC
- (IBAction)save:(id)sender {
    
    //验证
    if (self.breakfastTF.text.length == 0 || self.launchTF.text.length == 0 || self.dinnerTF.text.length == 0) {
        [ProgressHUD showError:@"请输入完整信息！"];
        return;
    }
    //去掉冒号
    NSString *breakfastStr = [self.breakfastTF.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *launchStr = [self.launchTF.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *dinnerStr = [self.dinnerTF.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    //参数拼接
    NSString *paramValue = [NSString stringWithFormat:@"%@;%@;%@",breakfastStr,launchStr,dinnerStr];
    
    NSString *imei = [[NSPublic shareInstance] getImei];
    if (imei.length > 0) {
        [self updateSetWith:imei andMealStr:paramValue];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    
    InputPanle *bView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    bView.dismisKeyboardAction = ^{ [self.view endEditing:YES]; };
    bView.okBtnClickedAction = ^{
        UITextField *tf = self.breakfastTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        [self.view endEditing:YES];
    };
    
    self.breakfastTF.inputAccessoryView = bView;
    self.breakfastTF.inputView = datePicker;
    
    InputPanle *lView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    lView.okBtnClickedAction = ^{
        UITextField *tf = self.launchTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        [self.view endEditing:YES];
    };
    
    self.launchTF.inputAccessoryView = lView;
    self.launchTF.inputView = datePicker;
    
    InputPanle *dView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    dView.okBtnClickedAction = ^{
        UITextField *tf = self.dinnerTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        [self.view endEditing:YES];
    };
    self.dinnerTF.inputAccessoryView = dView;
    self.dinnerTF.inputView = datePicker;
}

- (void)updateSetWith:(NSString*)imei andMealStr:(NSString*)mealStr
{
    [ProgressHUD show:@"保存中..."];
    NSArray *keys = @[@"imei",@"mealtime"];
    NSArray *values = @[imei,mealStr];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/terminal@updateBloodSugarSetting.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍后再试喔！"];
        }
    }];
    

}

@end
