//
//  PayResultVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/16.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "PayResultVC.h"
#import "CommonConstants.h"

@implementation PayResultVC

#define ListBtnTag  1973
#define BackBtnTag  1974
#define ReBuyBtnTag 1975

#define SuccessImage [UIImage imageNamed:@"mallPaySuccess"]
#define FailImage    [UIImage imageNamed:@"mallPayFail"]

#define BorderColor  [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]

#define SussessStr @"正在为您安排发货，请耐心等待！"
#define FailStr    @"出现意外导致支付失败，请重新购买！"

#define OrderDescSegue @"PaySuccess to OrderDescVC"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AddCornerBorder(self.listBtn, 2, 1, BorderColor.CGColor);
    AddCornerBorder(self.backBtn, 2, 1, BorderColor.CGColor);
    AddCornerBorder(self.reOrederBtn, 2, 1, BorderColor.CGColor);
    
    self.resultIMV.image = self.paySucceed ? SuccessImage : FailImage;
    self.resultLB.text = self.paySucceed ? SussessStr : FailStr;
    self.reOrederBtn.hidden = self.paySucceed;
    self.listBtn.hidden = !self.paySucceed;
    self.backBtn.hidden = !self.paySucceed;
    
    self.title = self.paySucceed ? @"支付成功" : @"支付失败";
    
}

- (IBAction)action:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    if (tag == ListBtnTag) {
        [self performSegueWithIdentifier:OrderDescSegue sender:self.order.oId];
    }else if (tag == BackBtnTag){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        NSArray *vcs = self.navigationController.viewControllers;
        [self.navigationController popToViewController:vcs[2] animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:OrderDescSegue]) {
        [segue.destinationViewController setValue:sender forKey:@"inputOrderId"];
    }
}


@end
