//
//  ServeCashVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ServeCashVC.h"
#import "Util/DataSigner.h"
#import "CommonConstants.h"
#import "ServeOrderDataService.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"

#import "AlipayOrder.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ServeCashVC ()

@property (weak, nonatomic) IBOutlet UILabel                *targetNameLB;
@property (weak, nonatomic) IBOutlet UILabel                *doctorNameLB;

@property (weak, nonatomic) IBOutlet UIImageView            *skillIMV;
@property (weak, nonatomic) IBOutlet UILabel                *skillTtileLB;
@property (weak, nonatomic) IBOutlet UILabel                *skillPriceLB;
@property (weak, nonatomic) IBOutlet UILabel                *skillTotalPriceLB;

@property (strong, nonatomic) IBOutlet UIButton             *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton             *payBtn;

@property (nonatomic,strong) ServeOrderDataService          *dataService;
@property (nonatomic,strong) NSMutableArray                 *cellHeights;
@property (nonatomic,assign) CGFloat                        dicountCellHeight;

//按次服务属性
@property (weak, nonatomic) IBOutlet UILabel                *nameLB;
@property (weak, nonatomic) IBOutlet UILabel                *phoneLB;
@property (weak, nonatomic) IBOutlet UILabel                *timeTermLB;
@property (weak, nonatomic) IBOutlet UILabel                *addresLB;

@property (weak, nonatomic) IBOutlet UILabel                *alipayOrPointLB;

@end

#define ServePayResultSegue @"To ServePayResultVC"

#define disCountOnImage  @"mallDiscountOn"
#define disCountOffImage @"mallDiscountOff"

@implementation ServeCashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AddCornerBorder(self.cancelBtn, 4, 0, nil);
    AddCornerBorder(self.payBtn, 4, 0, nil);
    self.dataService = [[ServeOrderDataService alloc] init];

    [self updateGoodsToUI];
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:YES];
    [ProgressHUD dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 123;
    }else{
        if ([self.inputServeOrder.orderType isEqualToString:@"按次服务"]) {
            
            if (indexPath.section == 0 &&
                (indexPath.row == 0 ||
                 indexPath.row == 1 ||
                 indexPath.row == 2)) {
                    return 0;
                }else{
                    return 44;
                }
            
        }else{
            
            if (indexPath.section == 0 &&
                (indexPath.row == 3 ||
                 indexPath.row == 4 ||
                 indexPath.row == 5 ||
                 indexPath.row == 6 ||
                 indexPath.row == 7)) {
                    return 0;
                }else{
                    return 44;
                }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (IBAction)cancelBtn:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)payBtn:(UIButton *)sender {
    
    //1 生成订单提交到自己服务器
    [ProgressHUD show:@"提交订单中..."];
    self.inputServeOrder.username = [[NSPublic shareInstance] getUserName];
    self.inputServeOrder.version = @"v2";
    if (self.inputServeOrder.goods.salePrice == 0) {
        self.inputServeOrder.payPaltform = 0;
    }
    
    [self.dataService initServeOrder:self.inputServeOrder withCallback:^(NSString *errorString, NSString *serveOrderId) {
        if (self.inputServeOrder.goods.salePrice == 0) {
            self.inputServeOrder.oId = serveOrderId;
            [ProgressHUD showSuccess:@"使用积分购买成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                PUSH(@"Service", @"ServePayResultVC", @"支付成功", (@{@"paySucceed":@(YES),@"serveOrder":self.inputServeOrder}), YES);
            });
        }else{
            [ProgressHUD showSuccess:@"订单本地添加成功！"];
            self.inputServeOrder.oId = serveOrderId;
            [self toAlipay];
        }
    }];
}


- (void)setInputServeOrder:(Order *)inputServeOrder{

    _inputServeOrder = inputServeOrder;
    [self updateGoodsToUI];
}

- (void)updateGoodsToUI
{
    if ([self.inputServeOrder.orderType isEqualToString:@"按次服务"]) {
        self.nameLB.text = self.inputServeOrder.address.realname;
        self.timeTermLB.text = self.inputServeOrder.address.deliverTerm;
        self.phoneLB.text = self.inputServeOrder.address.phone;
        self.addresLB.text = self.inputServeOrder.address.address;
        
        
    }else{
        
        self.targetNameLB.text= self.inputServeOrder.receiverName;
        self.doctorNameLB.text = self.inputServeOrder.doctorName;
        
    }
    
    //商品信息
   [self.skillIMV sd_setImageWithURL:[NSURL URLWithString:self.inputServeOrder.goods.imageList.firstObject] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    self.skillTtileLB.text = self.inputServeOrder.goods.title;
    self.skillPriceLB.text = [NSString stringWithFormat:@"¥%.2f + %d积分",self.inputServeOrder.goods.salePrice,(int)self.inputServeOrder.goods.needScore];
    self.skillTotalPriceLB.text = [NSString stringWithFormat:@"共%d件商品，总共¥%.2f元 + %d积分",self.inputServeOrder.orderNum,self.inputServeOrder.payNum,(int)self.inputServeOrder.goods.needScore * self.inputServeOrder.orderNum];
}

- (void)toAlipay{


    /*
     *点击获取prodcut实例并初始化订单信息
     */
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088221246444340";
    NSString *seller = @"zfb.ch@3chunhui.com";
    NSString *privateKey = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAOPSTYsRPQJMR28M4kIBNlpXK9cGpMNClFG5msvc1xndl7UdMZ0MuP6liaELsOXR+o/ifyi/5N2j2tWVS1K/XgFk8zEH/UDdCpzP3vmO8Hga402L4CULhVs+ePdY+WsC8G2A6HsTLDGFa+htdcQVwXrN6bkfTBGLZfN7OacmfsSzAgMBAAECgYAIx+xRNeLiGcqPDzIRVTahGMcJzKnBFOnelIbQ4LwxtQbJ5kwpP3pJ5lt9p5Oz5/n+Xb6E9ZB+sngWz2BN2i5nULm8jPgjZPhNtli9Xp1TH6uUBoUpvYRQbf7xrP6vSFOeYVMfss7yCNOblfC9QnUinESzPMsm+YQYhN3GOcj5MQJBAPp+ljnnxz80AJ2Lpxz0Am62KJFYqjGlYj+JiRZ5o2pcPuRclF8ac/Ykja1ANFGMEpjkr8NxZw+xZVCXz0khMA0CQQDo1CVf88qUv28iEHZjHonXR1KTCS0msIxSTh8DbOa1RQ+BB9hRssuRi2rPLO1J8gFMzfRUhIubN32mpmT7pde/AkEApEvs6pP8WpcYJD1Z4aKmCcmOeC6oiqGH/FaQRN6JcZSJZ6zVYD9weaxmBJGM/0OZWxD7u3wg9ekLo72+pp+O7QJBAIMYeJbnaUiJ5aRTiqVS26Aom5kI0LB5Nfld3V6LYfftE8a+SRHvT2n7Cz/t9wnsxsidKpawLv9NpmVASZncDncCQExSgQeqUB35bKRG6MuWgGQ32ZE7uEke6UYAh4XD73iXoXLk3xoiwZR2MouPhYIrsiw4eIRX/q/zvqauZ7gpB2A=";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    AlipayOrder *order = [[AlipayOrder alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = self.inputServeOrder.oId; //订单ID（由商家自行制定）
    order.productName = [[NSPublic shareInstance] getServerName]; //商品标题
    
    NSString *bodyTemp = @"FEATURE";// self.inputServeOrder.goods.feature;
    if (bodyTemp.length > 15) {
        bodyTemp = [bodyTemp substringToIndex:14];
    }
    
    order.productDescription = bodyTemp; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",self.inputServeOrder.payNum]; //商品价格
    order.notifyURL = @"http://appservice.3chunhui.com/chunhui/m/order@paybackNotify.do"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"akx4alipay";
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"%@",resultDic);
            if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]) {
                PUSH(@"Service", @"ServePayResultVC", @"支付成功", (@{@"paySucceed":@(YES),@"serveOrder":self.inputServeOrder}), YES);
            }else{
                PUSH(@"Service", @"ServePayResultVC", @"支付失败", (@{@"paySucceed":@(NO),@"serveOrder":self.inputServeOrder}), YES);
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:ServePayResultSegue]) {
        
        BOOL success = [sender boolValue];
        [segue.destinationViewController setValue:@(success) forKey:@"paySucceed"];
        [segue.destinationViewController setValue:self.inputServeOrder forKey:@"order"];
    }

}



@end
