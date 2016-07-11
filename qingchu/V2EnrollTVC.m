//
//  V2EnrollTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "V2EnrollTVC.h"
#import "UIViewController+CusomeBackButton.h"
#import "UIViewController+DataValidation.h"
#import "CommonConstants.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Base64.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "MyMD5.h"


#define GloRedCG    [UIColor colorWithRed:232/255.0 green:51/255.0 blue:52/255.0 alpha:1].CGColor

@interface V2EnrollTVC ()<
UITextFieldDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

#pragma mark- 界面outlets

@property (nonatomic, strong) NSMutableArray *rowHeights;
@property (weak, nonatomic) IBOutlet UIButton *iconBTN;

@property (weak, nonatomic) IBOutlet UITextField *nicknameTF;
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIImageView *usernameWarnIMV;
@property (weak, nonatomic) IBOutlet UIImageView *passwordWarnIMV;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *checkCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *countBTN;
@property (weak, nonatomic) IBOutlet UIView *coverLineView;
@property (weak, nonatomic) IBOutlet UILabel *countDownLB;
@property (weak, nonatomic) IBOutlet UIButton *enrollBTN;
@property (weak, nonatomic) IBOutlet UIButton *eulaBtn;
@property (weak, nonatomic) IBOutlet UITextField *refereeTF;

@property (nonatomic) int secondsCountDown;
@property (nonatomic,strong) NSTimer *countDownTimer;

@end

@implementation V2EnrollTVC

#pragma mark- 视图生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self setUpBackButton];
    AddCornerBorder(self.enrollBTN, 5, 0, nil);
    
    BOOL isAgree = [FromUserDefaults(@"EULA") boolValue];
    if (isAgree) {
        [self.eulaBtn setTitle:@"我已同意用户隐私协议(EULA)" forState:UIControlStateNormal];
    }else{
        [self.eulaBtn setTitle:@"请阅读用户隐私协议(EULA)" forState:UIControlStateNormal];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rowHeights = [NSMutableArray arrayWithArray:@[@175,@45,@45,@45,@20,@0,@45,@32,@45]];
    self.usernameTF.delegate = self;
    self.passwordTF.delegate = self;
    self.iconBTN.layer.cornerRadius = 50;
    self.iconBTN.clipsToBounds = YES;
}


#pragma mark- Target actions
- (IBAction)textFieldValueChanged:(UITextField *)sender
{
    if ([sender isEqual:self.usernameTF]) {
        if ([self isValidPhone:sender.text]) {
            [self toogleView:self.usernameView show:NO];
            [self.view endEditing:YES];
            //self.rowHeights[5] = @45;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }else{
            [self toogleView:self.usernameView show:YES];
            if ([self.rowHeights[5] intValue] == 45) {
                //self.rowHeights[5] = @(0);
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }
        }

    }else if([sender isEqual:self.passwordTF]){
        if ([self isValidPassword:sender.text]) {
            [self toogleView:self.passwordView show:NO];
        }else{
            [self toogleView:self.passwordView show:YES];
        }

    }else{
        if (sender.text.length == 4) {
            [self.view endEditing:YES];
        }
    }
    
    if (self.usernameView.layer.borderWidth == 0) {
        self.coverLineView.hidden = YES;
    }else{
        self.coverLineView.hidden = NO;
    }
}

- (IBAction)enroll:(UIButton *)sender
{
    BOOL isAgree = [FromUserDefaults(@"EULA") boolValue];
    if (!isAgree) {
        [self performSegueWithIdentifier:@"EULA segue" sender:nil];
        return;
    }
    
    if (self.nicknameTF.text.length == 0) {
        [self shakeAnimationForView:self.nicknameTF];
        return;
    }
    
    if (self.usernameTF.text.length == 0) {
        [self.usernameTF becomeFirstResponder];
        return;
    }
    
    if (self.usernameView.layer.borderWidth == 1) {
        [self shakeAnimationForView:self.usernameView];
        return;
    }
    
    if (self.passwordTF.text.length == 0) {
        [self.passwordTF becomeFirstResponder];
        return;
    }
    
    if (self.passwordView.layer.borderWidth == 1) {
        [self shakeAnimationForView:self.passwordView];
        return;
    }
    
//    if (![self isValidCode:self.checkCodeTF.text]) {
//        [self shakeAnimationForView:self.checkCodeTF];
//        return;
//    }
    
   // [self checkSMSCode];
    [self enrollToServer];
}

- (IBAction)addPic:(UIButton *)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [actionSheet showInView:self.view.window];
}

- (IBAction)sendSMS:(UIButton *)sender
{
    
    //发短信 http 请求
    [self sendSmsToServer];
    
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



#pragma mark- 代理方法
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTF]) {
        if (![self isValidPhone:textField.text]) {
            [self toogleView:self.usernameView show:YES];
        }else{
            [self toogleView:self.usernameView show:NO];
        }
        
    }else{
        if (![self isValidPassword:textField.text]) {
            [self toogleView:self.passwordView show:YES];
        }else{
            [self toogleView:self.passwordView show:NO];
        }
        
    }
    
    if (self.usernameView.layer.borderWidth == 0) {
        self.coverLineView.hidden = YES;
    }else{
        self.coverLineView.hidden = NO;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.rowHeights[indexPath.row] floatValue];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark- 工具方法
- (void)toogleView:(UIView*)view show:(BOOL)shouldShow
{
    if (shouldShow) {
        AddCornerBorder(view, 0, 1, GloRedCG);
        if ([view isEqual:self.usernameView]) {
            self.usernameWarnIMV.hidden = NO;
        }else{
            self.passwordWarnIMV.hidden = NO;
        }
    }else{
        AddCornerBorder(view, 0, 0, nil);
        if ([view isEqual:self.usernameView]) {
            self.usernameWarnIMV.hidden = YES;
        }else{
            self.passwordWarnIMV.hidden = YES;
        }

    }
}


#pragma mark- 数据验证方法：电话验证、密码验证、验证码验证


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

#pragma mark- 服务器交互：短信发送、验证码验证、注册提交
- (void)sendSmsToServer
{
    NSString *apiString = @"chunhui/m/tools@sendShortMessage.do";
    NSArray *keys = @[@"user",@"type"];
    NSArray *values = @[self.usernameTF.text,@"register"];
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
    [ProgressHUD show:@"注册中..." Interaction:YES];
    NSString *apiString = @"chunhui/m/tools@checkMCode.do";
    NSArray *keys = @[@"user",@"code"];
    NSArray *values = @[self.usernameTF.text,self.checkCodeTF.text];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"验证成功！" Interaction:YES];
                [self enrollToServer];
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

- (void)enrollToServer
{
   NSString *referee = @"";
    NSString *apiString = @"chunhui/m/user@register.do";
    NSArray *keys = @[@"user",@"pwd",@"real",@"sign",@"idcard",@"sex",@"image",@"nickname",@"referee"];
    NSString *iconString = @"";
    if (self.iconBTN.imageView.image) {
        iconString = [Base64 stringByEncodingData:UIImageJPEGRepresentation(self.iconBTN.imageView.image, 0.5)];
    }
    if (self.refereeTF.text.length > 0) {
        referee = self.refereeTF.text;
    }
    NSArray *values = @[self.usernameTF.text,
                        [MyMD5 md5:self.passwordTF.text],
                        @"",
                        @"",
                        @"",
                        @"",
                        iconString,
                        self.nicknameTF.text,
                        referee];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"注册成功！" Interaction:YES];
                [self performSegueWithIdentifier:@"Regist Successful VC" sender:nil];
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




#pragma mark - 拍照、选择图片
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.iconBTN setImage:editImage forState:UIControlStateNormal];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
