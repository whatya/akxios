//
//  DetailRegistionVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/15.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "DetailRegistionVC.h"
#import "NSPublic.h"
#import "UIView+Toast.h"
#import "InputPanle.h"
#import "DataPublic.h"
#import "FocusePersonListVC.h"
#import "UIViewController+CusomeBackButton.h"
#import "CommonConstants.h"
#import "MBProgressHUD.h"
#import "GlobalDefine.h"



@interface DetailRegistionVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *birthdayTF;
@property (weak, nonatomic) IBOutlet UITextField *heightTF;
@property (weak, nonatomic) IBOutlet UITextField *weightTF;
@property (weak, nonatomic) IBOutlet UITextField *medicalHistoryTF;
@property (weak, nonatomic) IBOutlet UITextField *dailyMedicineTF;
@property (weak, nonatomic) IBOutlet UITextField *allergicHistoryTF;

@property (nonatomic,strong) UIView *topTipView;
@property (nonatomic,strong) UIImageView *topImageView;

@end

@implementation DetailRegistionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    self.topTipView = [self tipView];
    self.topImageView = [self doctorImage];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.topTipView];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.topImageView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    InputPanle *aaView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    aaView.dismisKeyboardAction = ^{ [self.view endEditing:YES]; };
    aaView.okBtnClickedAction = ^{
        UITextField *tf = self.birthdayTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        UITextField *nextOne = [self nextTextFiledWithCurrenIndex:tf.tag];
        [nextOne becomeFirstResponder];
    };
 
    
    self.birthdayTF.inputView = datePicker;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    button.backgroundColor = [UIColor redColor];
    
    self.birthdayTF.inputAccessoryView = aaView;
    
    
    if ([self.title isEqualToString:@"编辑健康档案"]) {
        
        if (self.model.birthday.length > 0) {
            NSString *year = [self.model.birthday substringWithRange:NSMakeRange(0, 4)];
            NSString *month = [self.model.birthday substringWithRange:NSMakeRange(4, 2)];
            NSString *day = [self.model.birthday substringWithRange:NSMakeRange(6, 2)];
            
            self.birthdayTF.text = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
        }
        self.heightTF.text = self.model.height;
        self.weightTF.text = self.model.weight;
        self.medicalHistoryTF.text = self.model.medicalHistory;
        self.dailyMedicineTF.text = self.model.dailyMedicine;
        self.allergicHistoryTF.text = self.model.allergicHistory;
        
    }
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == 1974) {
        if (![self isValidHeight:textField.text] && textField.text.length != 0) {
            [self.view makeToast:@"请输入有效身高！" duration:1 position:CSToastPositionTop];
            return NO;
        }
    }
    
    if (textField.tag == 1975) {
        if (![self isValidWeight:textField.text] && textField.text.length != 0) {
            [self.view makeToast:@"请输入有效体重！" duration:1 position:CSToastPositionTop];
            return NO;
        }
    }
    return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1974) {
        if (![self isValidHeight:textField.text] && textField.text.length != 0) {
            [self.view makeToast:@"请输入有效身高！" duration:1 position:CSToastPositionTop];
            return NO;
        }
    }
    
    if (textField.tag == 1975) {
        if (![self isValidWeight:textField.text] && textField.text.length != 0) {
            [self.view makeToast:@"请输入有效体重！" duration:1 position:CSToastPositionTop];
            return NO;
        }
    }
    
    UITextField *nextOne = [self nextTextFiledWithCurrenIndex:textField.tag];
    if (nextOne) {
        [nextOne becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
    }
    
    return YES;
}


- (BOOL)isValidHeight:(NSString*)height
{

    if ([self isPureInt:height]) {
        int heightValue = [height intValue];
        
        if (heightValue > 0 && heightValue < 300) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

- (BOOL)isValidWeight:(NSString*)weight
{
    if ([self isPureInt:weight]) {
        int heightValue = [weight intValue];
        
        if (heightValue > 0 && heightValue < 200) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }

}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (UITextField*)nextTextFiledWithCurrenIndex:(NSInteger)index
{
    if (index == 1978) {
        return nil;
    }
    NSInteger realIndex = index - 1973 + 1;
    
    return @[self.birthdayTF,self.heightTF,self.weightTF,self.medicalHistoryTF,self.dailyMedicineTF,self.allergicHistoryTF][realIndex];
}


- (IBAction)submit:(id)sender {
    [self postDataToServer];
}

- (void)postDataToServer
{
    self.model.birthday = self.birthdayTF.text;
    self.model.height = self.heightTF.text;
    self.model.weight = self.weightTF.text;
    self.model.medicalHistory = self.medicalHistoryTF.text;
    
    self.model.dailyMedicine = self.dailyMedicineTF.text;
    self.model.allergicHistory = self.allergicHistoryTF.text;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    NSString __block *status = nil;
    
    NSString *apiName= @"bind.do";
    
    if ([self.title isEqualToString:@"编辑健康档案"]) {
        apiName = @"updateBind.do";
    }
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        
        NSArray *array9 = [[NSArray alloc] initWithObjects:
                           [[NSPublic shareInstance]getUserName],
                           self.model.sim,
                           self.model.imei,
                           self.model.name,
                           @"",
                           self.model.gender,
                           self.model.iconBase64String,
                           self.model.phone,
                           [self.model.birthday stringByReplacingOccurrencesOfString:@"-" withString:@""],
                           self.model.medicalHistory,
                           self.model.dailyMedicine,
                           self.model.allergicHistory,
                           self.model.height,
                           self.model.weight,
                           self.model.mcard, nil];
        
        NSDictionary *dictionary  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:apiName] with:array9 with:apiName];
        status = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"status"]];
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        NSString *successTitle = @"关注成功";
        NSString *failedTitle = @"关注失败";
        if ([self.title isEqualToString:@"编辑健康档案"]) {
            successTitle = @"提交成功";
            failedTitle = @"提交失败";
        }

        [HUD removeFromSuperview];
        if ([status isEqualToString:@"0" ])
        {
            [[DataPublic shareInstance] getRelativesInfo];
            [self.view.window makeToast:successTitle duration:1 position:CSToastPositionCenter];
//            for (id temp in self.navigationController.viewControllers){
//                if ([temp isKindOfClass:[FocusePersonListVC class]]) {
//                    [self.navigationController popToViewController:temp animated:YES];
//                    return ;
//                }
//            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"More", @"FocusListNav");
            });
            
        }else
            if ([status isEqualToString:@"-21" ]){
                [self.view makeToast:@"imei号未登记" duration:1.0  position:CSToastPositionCenter ];
                return;
            }
            else
            {
                [self.view makeToast:failedTitle duration:1.0  position:CSToastPositionCenter ];
                return;
            }
    }];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


- (UIView*)tipView
{
    UIView *tipView =[[UIView alloc] initWithFrame:self.view.bounds];
    tipView.backgroundColor = [UIColor blackColor];
    tipView.alpha = 0.7;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmiss)];
    [tipView addGestureRecognizer:dismissTap];
    return tipView;
}

- (void)dissmiss
{
    [self.topImageView removeFromSuperview];
    [self.topTipView removeFromSuperview];
}

- (UIImageView*)doctorImage
{
    CGFloat screenHeight = self.view.bounds.size.height;
    UIImageView *doctorImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight-309, 320, 309)];
    doctorImage.image = [UIImage imageNamed:@"ktyd"];
    return doctorImage;
}

@end
