//
//  AddPersonTVCForWX.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/3.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "AddPersonTVCForWX.h"
#import "CJSONDeserializer.h"
#import "UIView+Toast.h"
#import "GlobalDefine.h"
#import "UIWindow+YzdHUD.h"
#import "GBPathImageView.h"
#import "MyMD5.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSPublic.h"
#import "Base64.h"
#import "CHTermUser.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+CusomeBackButton.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "AddPersonTVC.h"

@interface AddPersonTVCForWX ()<
AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UITextField *watchIMEITF;


@end

@implementation AddPersonTVCForWX

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.imei) {
        self.watchIMEITF.text = self.imei;
    }


}
- (IBAction)next:(UIButton *)sender {
    //1、判断是否为第一个绑定者 －－》 2、如果是跳转到常规信息填写界面 －－》 3、如果不是直接调用绑定接口
    if (self.watchIMEITF.text.length > 0) {
        [self amIMaster];
        
    }else{
        [[Alert sharedAlert] showMessage:@"请输入IMEI号码！"];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    if (textField.tag == 1973) {
        if (![self isValidImei:textField.text]) {
            [self.view.window makeToast:@"imei号不正确！" duration:1 position:CSToastPositionCenter];
            return NO;
        }       
    }
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    if (textField.tag == 1973) {
        if (![self isValidImei:textField.text]) {
            [self.view.window makeToast:@"imei号不正确！" duration:1 position:CSToastPositionCenter];
            return NO;
        }
    }
    
    return YES;
}




- (BOOL)isValidNameOrRelationShip:(NSString*)beValidatedString
{
    
    if (beValidatedString.length > 0 && beValidatedString.length < 3 && beValidatedString.length != 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isValidPhone:(NSString*)phone
{
    if (phone.length == 11 || phone.length == 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isValidImei:(NSString*)imei
{
    if (imei.length > 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (void)setBarCode:(NSString *)barCode
{
    _barCode = barCode;
    self.watchIMEITF.text = barCode;
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}



- (IBAction)getCode:(UIButton *)sender {
    
    UIViewController *scannerVC = [[UIStoryboard storyboardWithName:@"More" bundle:nil] instantiateViewControllerWithIdentifier:@"ScannerVC"];
    [scannerVC setValue:self forKey:@"delegate"];
    [self presentViewController:scannerVC animated:YES completion:NULL];
    
}

- (void)amIMaster
{
    [ProgressHUD show:@"提交数据中..."];
    NSArray *keys = @[@"imei"];
    NSArray *values = @[self.watchIMEITF.text];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@isMasterBind.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
               
                BOOL isMaster = [DataDictionary(jsonData)[@"masterBind"] boolValue];
                if (isMaster) {
                    //跳转到常规绑定页面
                    AddPersonTVC *addVC = VCFromStoryboard(@"More", @"AddFocusTVC");
                    addVC.incomingImei = self.watchIMEITF.text;
                    
                    [self.navigationController pushViewController:addVC animated:YES];
                }else{
                    //直接调用绑定接口
                    [self follow];
                }
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}

- (void)follow
{
    NSArray *keys = @[@"user",@"imei"];
    NSArray *values = @[[[NSPublic shareInstance] getUserName],
                        self.watchIMEITF.text];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@simpleBind.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                //跳转到亲人列表界面
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"More", @"FocusListNav");
                });
            }else{
                [[Alert sharedAlert] showMessage:@"您已绑定该终端！"];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];

}


@end
