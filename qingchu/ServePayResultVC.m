//
//  ServePayResultVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/18.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ServePayResultVC.h"
#import "CommonConstants.h"


#define ListBtnTag  1973
#define BackBtnTag  1974
#define ReBuyBtnTag 1975

#define SuccessImage [UIImage imageNamed:@"skillPayOK"]
#define FailImage    [UIImage imageNamed:@"skillPayFailed"]

#define BorderColor  [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]

#define SussessStr @"已通知医生，请等待医生的专属服务！"
#define FailStr    @"出现意外导致支付失败，请重新购买！"

#define ServeOrderDetailSegue @"PaySuccess to ServeOrderDetailVC"

@interface ServePayResultVC ()

@end

@implementation ServePayResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AddCornerBorder(self.listBtn, 2, 1, BorderColor.CGColor);
    AddCornerBorder(self.backBtn, 2, 1, BorderColor.CGColor);
    AddCornerBorder(self.rePayBtn, 2, 1, BorderColor.CGColor);
    
    self.resultImageV.image = self.paySucceed ? SuccessImage : FailImage;
    self.resultLB.text = self.paySucceed ? SussessStr : FailStr;
    self.rePayBtn.hidden = self.paySucceed;
    self.listBtn.hidden = !self.paySucceed;
    self.backBtn.hidden = !self.paySucceed;
    
    self.title = self.paySucceed ? @"支付成功" : @"支付失败";

}
- (IBAction)action:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    if (tag == ListBtnTag) {
        //订单详情
        PUSH(@"Mall", @"OrderDetailVC", @"订单详情", @{@"inputOrderId":self.serveOrder.oId}, YES);
        
    }else if (tag == BackBtnTag){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        NSArray *vcs = self.navigationController.viewControllers;
        [self.navigationController popToViewController:vcs[2] animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ServeOrderDetailSegue]) {
        [segue.destinationViewController setValue:sender forKey:@"inputServeOrder"];
    }
}

@end
