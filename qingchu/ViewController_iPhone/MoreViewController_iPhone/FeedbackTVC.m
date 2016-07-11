//
//  FeedbackTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/14.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "FeedbackTVC.h"
#import "NSPublic.h" 
#import "UIView+Toast.h"
#import "MBProgressHUD.h"

@interface FeedbackTVC ()
<UITextFieldDelegate,
UITextViewDelegate,
UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UITextField *phone;

@end

@implementation FeedbackTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";
    self.content.delegate = self;
    self.phone.delegate = self;

}


- (IBAction)postContent:(id)sender {
    NSString __block *status = nil;
    if (self.content.text.length == 0) {
        [self.view makeToast:@"内容不能为空" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    
    NSString *content = self.content.text;
    NSString *phoneNumber = self.phone.text;
    if (phoneNumber.length == 0) {
        phoneNumber = @"";
    }
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        //获取所有的设置信息
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getUserName],content,phoneNumber,[[NSPublic shareInstance]getJSESSION],nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


@end
