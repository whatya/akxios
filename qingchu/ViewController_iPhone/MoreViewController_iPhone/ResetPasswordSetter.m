//
//  ResetPasswordSetter.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "ResetPasswordSetter.h"
#import "Alert.h"
#import "ProgressHUD.h"
#import "DataPublic.h"
#import "NSPublic.h"
#import "CanHideTF.h"
#import "UIView+Toast.h"
#import "MyMD5.h"
#import "MBProgressHUD.h"

@interface ResetPasswordSetter ()
@property (weak, nonatomic) IBOutlet CanHideTF *orignalTF;
@property (weak, nonatomic) IBOutlet CanHideTF *nowTF1;
@property (weak, nonatomic) IBOutlet CanHideTF *nowTF2;

@end

@implementation ResetPasswordSetter

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)save:(UIBarButtonItem *)sender {
    [self fillToServer];
}

- (void)fillToServer
{
    if ( ![self.orignalTF.text isEqualToString:[[NSPublic shareInstance]getPwd]]  )
    {
        [self.view makeToast:@"原密码错误，请重新输入！" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    if ( ![self.nowTF1.text isEqualToString:self.nowTF2.text]  )
    {
        [self.view makeToast:@"二次密码不相同，请重新输入！" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    
    if ( self.nowTF1.text.length<6 ||  self.nowTF1.text.length>16 )
    {
        [self.view makeToast:@"密码长度应为6~16位之间!" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    
    if ( self.nowTF2.text.length<6 ||  self.nowTF2.text.length>16 )
    {
        [self.view makeToast:@"密码长度应为6~16位之间!" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    
    __block NSString *status = nil;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        NSArray *array0 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getUserName],[MyMD5 md5:self.nowTF1.text],[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"updatePwd.do"] with:array0 with:@"updatePwd.do"];
        
        status  = [NSString stringWithFormat:  @"%@",[dictionary objectForKey:@"status"]];
        
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
