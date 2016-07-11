//
//  V2LoginTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "V2LoginTVC.h"
#import "CommonConstants.h"
#import "MyMD5.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "CanHideTF.h"
#import "DataPublic.h"
#import "UIViewController+DataValidation.h"
#import "CHTermUser.h"
#import "WXApi.h"
#import "WXMediaMessage+messageConstruct.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#define BUFFER_SIZE 1024 * 100


#define GloRedCG    [UIColor colorWithRed:232/255.0 green:48/255.0 blue:52/255.0 alpha:1].CGColor
#define GrayColorCG [UIColor colorWithRed:117/255.0 green:117/255.0 blue:117/255.0 alpha:1].CGColor

#define AutoLogin   @"shouldAutoLogin"
#define SavePwd     @"shouldSavePassword"

@interface V2LoginTVC ()<WXApiDelegate>

#pragma mark- 界面 outlets 和 属性
@property (weak, nonatomic) IBOutlet CanHideTF *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordBTN;
@property (weak, nonatomic) IBOutlet UIButton *loginBTN;
@property (weak, nonatomic) IBOutlet UIButton *enrollBTN;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIImageView *omeLoginBGgImage;

@property (weak, nonatomic) IBOutlet UIButton *wxLoginBtn;


@end

@implementation V2LoginTVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    [self wxUI];
}

- (void)wxUI
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        self.wxLoginBtn.enabled = YES;
    }else{
        self.wxLoginBtn.enabled = NO;
    }
}
- (IBAction)toWXAuth:(UIButton *)sender
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}



#pragma mark- 初始化界面
- (void)makeUI
{
    AddCornerBorder(self.forgetPasswordBTN, 5, 1, GloRedCG);
    AddCornerBorder(self.enrollBTN, 5, 1, GloRedCG);
    AddCornerBorder(self.loginBTN, 5, 0, nil);
    AddCornerBorder(self.omeLoginBGgImage, 10, 0, nil);
    AddCornerBorder(self.wxLoginBtn, 5, 1, GrayColorCG);

    self.usernameTF.text = [[NSPublic shareInstance] getUserName];
    self.passwordTF.text = [[NSPublic shareInstance] getPwd];
    
    self.backBtn.hidden = !self.shouldShowBackBtn;
    
    
}
- (IBAction)close:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)login:(UIButton *)sender {
    if ([self validate]) {
        [[NSPublic shareInstance] setTermUserArray:[NSMutableArray arrayWithArray:@[]]];

        [self loginToServer];
    }
}

- (IBAction)textChanged:(UITextField *)sender
{
    if ([sender isEqual:self.usernameTF]) {
        if ([self isValidPhone:sender.text]) {
            if (![self isValidPassword:self.passwordTF.text]) {
                [self.passwordTF becomeFirstResponder];
            }
        }
    }
}

#pragma mark- 代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"To authcode page"] && [self isValidPhone:self.usernameTF.text]) {
        
        [segue.destinationViewController setValue:self.usernameTF.text forKey:@"phone"];
    }
}


#pragma mark- 数据验证
- (BOOL)validate
{
    if (self.usernameTF.text.length == 0) {
        [self.usernameTF becomeFirstResponder];
        return NO;
    }
    if (self.passwordTF.text.length == 0) {
        [self.passwordTF becomeFirstResponder];
        return NO;
    }
    
    if (![self isValidPhone:self.usernameTF.text]) {
        [self shakeAnimationForView:self.usernameTF];
        return NO;
    }
    
    if (![self isValidPassword:self.passwordTF.text]) {
        [self shakeAnimationForView:self.passwordTF];
        return NO;
    }
    return YES;
}


#pragma mark- 服务器交互
- (void)loginToServer
{
    [ProgressHUD show:@"登录中..." Interaction:YES];
    NSString *username = self.usernameTF.text;
    NSString *password = self.passwordTF.text;
    
    NSArray *keys = @[@"user",@"pwd",@"regid",@"apikey",@"secretkey",@"devicetype"];
    NSArray *values = @[username, [MyMD5 md5:password],[[NSPublic shareInstance] getUserTXId] ?: @"" ,@"9085bca5773959465f5c933c",@"2330451c7921a0e5c9ed1f92",@"4"];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@login.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                [self loginSucceed];

                [self fetchUserInformationWithUser:username];

            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
    
}
                //http://appservice.3chunhui.com/chunhui/m/user@login.do
#pragma mark- 获取用户信息
- (void)fetchUserInformationWithUser:(NSString*)user
{
    NSArray *keys = @[@"user"];
    NSArray *values = @[user];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@getUserInfo.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                NSString *iconString = jsonData[@"data"][@"oem"][@"oemLoginBgImage"];
                [[NSPublic shareInstance] setUserImage:iconString];
                
//                UIImageView *homgBgImg = (UIImageView*)[self.view viewWithTag:1];
//                
//                NSString *imgString = jsonData[@"data"][@"oem"][@"oemLoginBgImage"];
//                NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithString:imgString]];
//                homgBgImg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍后再试喔！"];
        }
    }];
}

- (void)loginSucceed
{
    
     //如果登录账户更改，就清楚已经关注到账号
    if (![[[NSPublic shareInstance] getUserName] isEqualToString:self.usernameTF.text]) {
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"focusedPersionImei"];
        [userDefaults synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AlertNoteKey"];
    
    //1.保存用户名和密码
    [[NSPublic shareInstance]saveUserNameAndPwd:self.usernameTF.text
                                         andPwd:self.passwordTF.text
                                           with:@"0"
                                           with:@"0"];
    ToUserDefaults(SavePwd, @(YES));
    ToUserDefaults(AutoLogin, @(YES));
    
    //2.获取亲人信息
    [ProgressHUD show:@"获取亲人中..." Interaction:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *relativesInfo = [[DataPublic shareInstance]getRelativesInfo];
        [[DataPublic shareInstance]getSettingInfo];
        [[DataPublic shareInstance] getUserInfo];
        //如果没有亲人信息，跳着到添加亲人绑定页面：
        if ([relativesInfo isEqualToString:@"1"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
                [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"Home", @"GridHomeNav");
                //                [[Alert sharedAlert] showMessage:@"还没有绑定亲人喔！" okTitle:@"去绑定亲人" action:^{
                //                    [self.navigationController pushViewController:VCFromStoryboard(@"More", @"AddFocusTVCForWX") animated:YES];
                //                }];
            });
        }else{//如果有亲人信息，存储亲人信息，并跳转到首页
            //如果之前关注过亲人，直接跳转到首页
            NSString *focusedImei = [[NSUserDefaults standardUserDefaults] objectForKey:@"focusedPersionImei"];
            
            if (focusedImei) {
                NSArray *relatives = [[NSPublic shareInstance] getTermUserArray];
                for (CHTermUser *termUser  in relatives){
                    if ([focusedImei isEqualToString:termUser.imei]) {
                        [[NSPublic shareInstance]setImei:termUser.imei];
                        [[NSPublic shareInstance]setname:termUser.name];
                        [[NSPublic shareInstance]setrelative:termUser.relative];
                        [[NSPublic shareInstance]setsim:termUser.sim];
                        [[NSPublic shareInstance]setsex:termUser.sex];
                        [[NSPublic shareInstance]setimage:termUser.image];
                        break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"Home", @"GridHomeNav");
                });
                
            }else{ //如果没有选择过亲人，跳转到亲人列表选择页面
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"More", @"FocusListNav");
                });
               
            }
        }
        
    });
}



@end
