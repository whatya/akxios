//
//  NewPasswordTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "NewPasswordTVC.h"
#import "CommonConstants.h"
#import "HttpManager.h"
#import "UIViewController+CusomeBackButton.h"
#import "ProgressHUD.h"
#import "MyMD5.h"

@interface NewPasswordTVC ()

@property (weak, nonatomic) IBOutlet UITextField *pwdTF1;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF2;
@property (weak, nonatomic) IBOutlet UIButton *submitBTN;

@end

@implementation NewPasswordTVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpBackButton];
    AddCornerBorder(self.submitBTN, 5, 0, nil);
}

#pragma mark- TargetActions
- (IBAction)confirm:(UIButton *)sender
{
    if (![self isValidPassword:self.pwdTF1.text]) {
        [self shakeAnimationForView:self.pwdTF1];
        return;
    }
    
    if (![self isValidPassword:self.pwdTF2.text]) {
        [self shakeAnimationForView:self.pwdTF2];
        return;
    }
    
    if (![self.pwdTF1.text isEqualToString:self.pwdTF2.text]) {
        [[Alert sharedAlert] showMessage:@"密码不一致！"];
        return;
    }
    [self updatePassword];
}

- (IBAction)textChanged:(UITextField *)sender
{
    if ([self.pwdTF1.text isEqualToString:self.pwdTF2.text]) {
        [self.view endEditing:YES];
    }
}


#pragma mark- TableView代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 70;
    }
    return 44;
}

#pragma mark- 数据验证
- (BOOL)isValidPassword:(NSString*)password
{
    if (password.length >= 6
        && password.length <= 16
        && [password rangeOfString:@" "].location == NSNotFound)
    {
        return YES;
    }
    return NO;
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

#pragma mark- 服务交互、密码修改
- (void)updatePassword
{
    [ProgressHUD show:@"修改密码中..." Interaction:YES];
    NSString *apiString = @"chunhui/m/user@resetPwd.do";
    NSArray *keys = @[@"user",@"pwd",@"rand"];
    NSArray *values = @[self.phone,
                        [MyMD5 md5:self.pwdTF1.text],
                        self.rand];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [[Alert sharedAlert] showMessage:@"密码修改成功！" okTitle:@"进入登陆页面" action:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
            
        }else{
            [ProgressHUD dismiss];
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}

@end
