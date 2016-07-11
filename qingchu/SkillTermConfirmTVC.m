//
//  SkillTermConfirmTVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/9.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillTermConfirmTVC.h"
#import "InputPanle.h"
#import "CanHideTV.h"
#import "CommonConstants.h"
#import "ProgressHUD.h"
#import "Address.h"
#import "OrderDataService.h"
#import "NSPublic.h"

@interface SkillTermConfirmTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *dayTF;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTF;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTF;
@property (weak, nonatomic) IBOutlet CanHideTV *addressTV;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (nonatomic,strong) OrderDataService *dataService;

@end

@implementation SkillTermConfirmTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataService = [[OrderDataService alloc] init];
    self.title = @"确认订单";
    NSTimeInterval secondsPerHour = 60 * 60;
    //day 选择器
    UIDatePicker *dayPicker = [[UIDatePicker alloc] init];
    dayPicker.datePickerMode = UIDatePickerModeDate;
    InputPanle *dayView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    dayView.dismisKeyboardAction = ^{ [self.view endEditing:YES]; };
    dayView.okBtnClickedAction = ^{
        UITextField *tf = self.dayTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        [tf resignFirstResponder];
    };
    self.dayTF.inputView = dayPicker;
    self.dayTF.inputAccessoryView = dayView;
    self.dayTF.text = dateStirng(@"yyyy/MM/dd", [NSDate date]);
   
    //start 选择器
    UIDatePicker *startPicker = [[UIDatePicker alloc] init];
    startPicker.datePickerMode = UIDatePickerModeTime;
    InputPanle *startView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    startView.dismisKeyboardAction = ^{[self.view endEditing:YES];};
    startView.okBtnClickedAction = ^{
        UITextField *tf = self.startTimeTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        [tf resignFirstResponder];
    };
    self.startTimeTF.inputView = startPicker;
    self.startTimeTF.inputAccessoryView = startView;
    self.startTimeTF.text = dateStirng(@"HH:mm:ss", [[NSDate date] dateByAddingTimeInterval:-secondsPerHour]);
    
    //end 选择器
    UIDatePicker *endPicker = [[UIDatePicker alloc] init];
    endPicker.datePickerMode = UIDatePickerModeTime;
    InputPanle *endView = [[[NSBundle mainBundle] loadNibNamed:@"InputPanle" owner:self options:nil] lastObject];
    endView.dismisKeyboardAction = ^{[self.view endEditing:YES];};
    endView.okBtnClickedAction = ^{
        UITextField *tf = self.endTimeTF;
        UIDatePicker *datePicker = (UIDatePicker*)tf.inputView;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *selctedDateString = [dateFormatter stringFromDate:datePicker.date];
        tf.text = selctedDateString;
        [tf resignFirstResponder];
    };
    self.endTimeTF.inputView = startPicker;
    self.endTimeTF.inputAccessoryView = endView;
    self.endTimeTF.text = dateStirng(@"HH:mm:ss", [[NSDate date] dateByAddingTimeInterval:secondsPerHour]);
    
    //地址输入框
    AddCornerBorder(self.addressTV, 4, 0.5, [UIColor lightGrayColor].CGColor);
    //提交按钮
    AddCornerBorder(self.submitBtn, 4, 0, nil);
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


NSString *dateStirng(NSString *outputStyle, NSDate* date)
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = outputStyle;
    return [outputFormatter stringFromDate:date];
    
}

- (IBAction)next:(id)sender
{
    if (self.nameTF.text.length == 0) {
        [ProgressHUD showError:@"请输入联系人!"];
        return;
    }
    if (self.phoneTF.text.length == 0) {
        [ProgressHUD showError:@"请输电话号码!"];
        return;
    }
    if (self.addressTV.text.length == 0) {
        [ProgressHUD showError:@"请输入地址!"];
        return;
    }
    if (self.dayTF.text.length == 0 ||
        self.startTimeTF.text.length == 0 ||
        self.endTimeTF.text.length == 0) {
        [ProgressHUD showError:@"请选择服务时间!"];
        return;
    }
    
    Address *address = [[Address alloc] init];
    address.realname = self.nameTF.text;
    address.phone = self.phoneTF.text;
    address.address = self.addressTV.text;
    address.recvDate = self.dayTF.text;
    address.recvTime = [NSString stringWithFormat:@"%@~%@",self.startTimeTF.text,self.endTimeTF.text];
    
    [self saveAddress:address];
    
}

- (void)saveAddress:(Address*)address
{
    __weak SkillTermConfirmTVC *weak_self = self;
    [ProgressHUD show:@"保存地址中..."];
    address.user = [[NSPublic shareInstance] getUserName];
    [self.dataService setAddress:address withCallback:^(NSString *errorString) {
       
        if (errorString) {
            [ProgressHUD showError:errorString];
        }else{
            [ProgressHUD showSuccess:@"地址保存成功！"];
            [weak_self addressWithUsername:[[NSPublic shareInstance] getUserName] andOldAddress:address];
        }
        
    }];
    
    
}

- (void)addressWithUsername:(NSString*)username andOldAddress:(Address*)oldAddress
{
    __weak SkillTermConfirmTVC *weak_self = self;
    self.inputOrder.orderType = @"按次服务";
   
    [self.dataService addressByUsername:username withCallback:^(NSString *errorString, Address *address) {

        if (errorString) {
            [ProgressHUD showError:errorString];
        }else{ //有地址，将地址更新到界面
            
            oldAddress.aId = address.aId;
            weak_self.inputOrder.address = oldAddress;
            
            PUSH(@"Service", @"ServeCashVC", @"确认支付", @{@"inputServeOrder":self.inputOrder}, YES);
        }
        
    }];
}

@end
