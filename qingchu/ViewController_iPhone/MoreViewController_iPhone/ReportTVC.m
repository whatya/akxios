//
//  ReportTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/10.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "ReportTVC.h"
#import "CommonConstants.h"
#import "UIView+Toast.h"
#import "NSPublic.h"
#import "MBProgressHUD.h"

@interface ReportTVC ()
@property (weak, nonatomic) IBOutlet UITextView *contentTV;

@end

@implementation ReportTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"举报";
}

- (IBAction)post:(UIBarButtonItem *)sender
{
    NSString __block *status = nil;
    if (self.contentTV.text.length == 0) {
        [self.view makeToast:@"内容不能为空" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    
    NSString *content = self.contentTV.text;

    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getUserName],content,@"13800138000",[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"addFeedBack.do"] with:array0 with:@"addFeedBack.do"];
        status  =  [NSString stringWithFormat:  @"%@",[dictionary0 objectForKey:@"status"]];
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        [HUD removeFromSuperview];
        NSLog(@"%@",status);
        if ([status isEqualToString:@"0" ])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交成功"message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        else
        {
            [self.view makeToast:@"提交失败" duration:1.0  position:CSToastPositionCenter ];
            return;
        }
    }];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
