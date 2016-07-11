//
//  ComentToSkillTVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ComentToSkillTVC.h"
#import "CommonConstants.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "HttpManager.h"

@interface ComentToSkillTVC ()

@property (weak, nonatomic) IBOutlet UIButton *tipBTN;
@property (weak, nonatomic) IBOutlet UITextView *boxTV;

@end

@implementation ComentToSkillTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    AddCornerBorder(self.tipBTN, 4, 0, nil);
    AddCornerBorder(self.boxTV, 4, 0.5, [UIColor darkGrayColor].CGColor);
}

#define tipUrl @"chunhui/m/comment@addUserComment.do"
- (IBAction)post:(UIButton *)sender
{
    if (self.boxTV.text.length == 0) {
        [ProgressHUD showError:@"请输入评论内容!"];
        return;
    }
    [ProgressHUD show:@"提交评论中..."];
    NSArray *keys = @[@"user",@"orderId",@"content"];
    NSString *user = [[NSPublic shareInstance] getUserName];
    NSString *content = self.boxTV.text;
    NSString *orderId = self.targetID;
    NSArray *values = @[user,orderId,content];

    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:tipUrl portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:[error localizedDescription]];
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            [ProgressHUD showError:ErrorString(jsonData)];
        }else{
            [ProgressHUD showSuccess:@"提交评论成功！"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        
    }];

    
}

@end
