//
//  SendResetPWDVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.


#import "SendResetPWDVC.h"
#import "UIViewController+CusomeBackButton.h"
#import "UIViewController+DataValidation.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "CommonConstants.h"

@interface SendResetPWDVC ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *checkCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *countBTN;
@property (weak, nonatomic) IBOutlet UILabel *countDownLB;
@property (weak, nonatomic) IBOutlet UIButton *checkBTN;

@property (nonatomic) int secondsCountDown;
@property (nonatomic,strong) NSTimer *countDownTimer;

@property (nonatomic,strong) NSString *rand;

@end

@implementation SendResetPWDVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpBackButton];
    AddCornerBorder(self.checkBTN, 5, 0, nil);
    self.phoneTF.text = self.phone;
}

#pragma mark- Target Actions
- (IBAction)sendSMS:(UIButton *)sender
{
    //数据验证
    if (![self isValidPhone:self.phoneTF.text]) {
        [self shakeAnimationForView:self.phoneTF];
        return;
    }
    //发短信 http 请求
    [self sendSmsToServer];
}
- (IBAction)checkCode:(UIButton *)sender
{
    //数据验证
    if (![self isValidCode:self.checkCodeTF.text]) {
        [self shakeAnimationForView:self.checkCodeTF];
        return;
    }
    //验证码验证 http请求
    [self checkSMSCode];
}


- (IBAction)textChanged:(UITextField *)sender
{
    if ([sender isEqual:self.phoneTF]) {
        if ([self isValidPhone:sender.text]) {
            if (self.checkCodeTF.text == 0) {
                [self.checkCodeTF becomeFirstResponder];
            }
        }
    }else{
        if (sender.text.length == 4) {
            [self.view endEditing:YES];
        }
    }
}

- (void)initTimer
{
    //初始化定时器
    self.secondsCountDown = 60;
    self.countBTN.enabled = NO;
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [self.countDownTimer fire];
}

- (void)countDown
{
    self.secondsCountDown--;
    self.countDownLB.hidden = NO;
    self.countDownLB.text = StringFromNumber(self.secondsCountDown);
    if (self.secondsCountDown == 0) {
        self.countDownLB.hidden = YES;
        self.countBTN.enabled = YES;
        [self.countDownTimer invalidate];
    }
}

#pragma mark- 数据验证方法：电话验证、验证码验证


- (BOOL)isValidCode:(NSString*)codeString
{
    if (codeString.length == 0) {
        return NO;
    }
    
    if (codeString.length != 4) {
        [[Alert sharedAlert] showMessage:@"验证码为4位数字！"];
        return NO;
    }
    return YES;
    
}

#pragma mark- TableView 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 70;
    }
    return 44;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setValue:self.rand forKey:@"rand"];
    [segue.destinationViewController setValue:self.phoneTF.text forKey:@"phone"];
}

#pragma mark 抖动动画

- (void)shakeAnimationForView:(UIView *) view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:.06];
    [animation setRepeatCount:3];
    [viewLayer addAnimation:animation forKey:nil];
    
}

#pragma mark- 服务器交互：短信发送、验证码验证
- (void)sendSmsToServer
{
    NSString *apiString = @"chunhui/m/tools@sendShortMessage.do";
    NSArray *keys = @[@"user",@"type"];
    NSArray *values = @[self.phoneTF.text,@"pwdback"];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"短信已发送" Interaction:YES];
                //计算时开始
                [self initTimer];
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
            
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}

- (void)checkSMSCode
{
    [ProgressHUD show:@"验证中..." Interaction:YES];
    NSString *apiString = @"chunhui/m/tools@checkMCode.do";
    NSArray *keys = @[@"user",@"code"];
    NSArray *values = @[self.phoneTF.text,self.checkCodeTF.text];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"验证成功！" Interaction:YES];
                self.rand = DataDictionary(jsonData)[@"rand"];
                [self performSegueWithIdentifier:@"new password" sender:nil];
            }else{
                [ProgressHUD dismiss];
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
            
        }else{
            [ProgressHUD dismiss];
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}

@end
