//
//  CashTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "CashTVC.h"
#import "OrderDataService.h"
#import "NSPublic.h"
#import "UIImageView+WebCache.h"
#import "ProgressHUD.h"
#import "AlipayOrder.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Util/DataSigner.h"

@interface CashTVC ()

//heights
@property (nonatomic,strong) NSMutableArray *cellHeights;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *phoneLB;
@property (weak, nonatomic) IBOutlet UILabel *addressLB;

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;


@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (nonatomic,strong) OrderDataService *dataService;

@property (nonatomic,strong) Address *address;

//Goods related
@property (weak, nonatomic) IBOutlet UIImageView *goodsCoverIMV;
@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLB;
@property (weak, nonatomic) IBOutlet UILabel *goodsSalePriceLB;
@property (weak, nonatomic) IBOutlet UILabel *goodsMarketPriceLB;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLB;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLB;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;


@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (nonatomic,assign) CGFloat dicountCellHeight;
@property (weak, nonatomic) IBOutlet UILabel *alipayOrPointLB;

@end

#define PayResultSegue @"To PayResultVC"
#define SaveBtnBorderColor [UIColor colorWithRed:149/255.0 green:150/255.0 blue:152/255.0 alpha:1]

#define DiscountOnImage @"mallDiscountOn"
#define DiscountOffImage @"mallDiscountOff"

@implementation CashTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    AddCornerBorder(self.saveBtn, 2, 1, SaveBtnBorderColor.CGColor);
    AddCornerBorder(self.cancelBtn, 4, 0, nil);
    AddCornerBorder(self.payBtn, 4, 0, nil);
    [self updateGoodsToUI];
    
    self.dataService = [[OrderDataService alloc] init];
    [self hideAddressEdit:NO animated:NO showKeyboard:NO];
    NSString *username = [[NSPublic shareInstance] getUserName];
    [self addressWithUsername:username];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [ProgressHUD dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellHeights[indexPath.section][indexPath.row] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        [self toogleAddressEdit:nil];
    }
    
    
}


- (IBAction)cancelOrder:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)toogleAddressEdit:(UIButton *)sender
{
    int height = [self.cellHeights[0][1] intValue];
    if (height == 44) {
        [self hideAddressEdit:YES animated:YES showKeyboard:YES];
    }else{
        [self hideAddressEdit:NO animated:YES showKeyboard:YES];
    }
}

- (IBAction)pay:(UIButton *)sender
{
    if (self.address.address.length == 0) {
        [ProgressHUD showError:@"请收入正确的地址信息！"];
        return;
    }
    
    //1 生成订单提交到自己服务器
    [ProgressHUD show:@"提交订单中..."];
    
    self.inputOrder.address = self.address;
    self.inputOrder.version = @"v2";
    if (self.inputOrder.goods.salePrice == 0) {
        self.inputOrder.payPaltform = 0;
    }
    [self.dataService initOrder:self.inputOrder withCallback:^(NSString *errorString,NSString* orderId) {
       
        if (errorString) {
            [ProgressHUD showError:errorString];
        }else{
            if (self.inputOrder.goods.salePrice == 0) {
                self.inputOrder.oId = orderId;
                [ProgressHUD showSuccess:@"使用积分购买成功"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:PayResultSegue sender:@(YES)];
                });
            }else{
                [ProgressHUD showSuccess:@"订单本地添加成功！"];
                self.inputOrder.oId = orderId;
                [self toAlipay];
            }
            
        }
        
    }];
    
    
    //2 完成后生成支付宝订单提交到支付宝
}


- (IBAction)saveAddress:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (self.address) {//修改地址
        
        if (self.nameTF.text.length == 0 || self.phoneTF.text.length == 0 || self.addressTF.text.length == 0) {
            [ProgressHUD showError:@"请输入完整的地址信息！"];
            return;
        }
        
        self.address.realname = self.nameTF.text;
        self.address.phone = self.phoneTF.text;
        self.address.address = self.addressTF.text;
        self.address.user = [[NSPublic shareInstance] getUserName];
        __block CashTVC *weak_self = self;
        
        [ProgressHUD show:@"修改地址中..."];
        
        [self.dataService setAddress:self.address withCallback:^(NSString *errorString) {
            
            if (errorString) {
                [ProgressHUD showError:errorString];
            }else{
                
                [ProgressHUD showSuccess:@"修改地址成功！"];
                [weak_self addressWithUsername:[[NSPublic shareInstance] getUserName]];
            }
            
        }];

        
        
    }else{//新增地址
        
        if (self.nameTF.text.length == 0 || self.phoneTF.text.length == 0 || self.addressTF.text.length == 0) {
            [ProgressHUD showError:@"请输入完整的地址信息！"];
            return;
        }
        
        Address *parma = [[Address alloc] init];
        parma.realname = self.nameTF.text;
        parma.phone = self.phoneTF.text;
        parma.address = self.addressTF.text;
        parma.user = [[NSPublic shareInstance] getUserName];
        
        __block CashTVC *weak_self = self;
        
        [ProgressHUD show:@"新增地址中..."];
        
        [self.dataService setAddress:parma withCallback:^(NSString *errorString) {
           
            if (errorString) {
                [ProgressHUD showError:errorString];
            }else{
                [ProgressHUD showSuccess:@"新增地址成功！"];
                [weak_self addressWithUsername:[[NSPublic shareInstance] getUserName]];
            }
            
        }];
        
    }
}


- (void)hideAddressEdit:(BOOL)flag animated:(BOOL)animate showKeyboard:(BOOL)shouldShow
{
    if (flag) {
        self.cellHeights = [NSMutableArray arrayWithArray:@[@[@44,@0,@0,@0,@80],
                                                            @[@44,@123,@44],
                                                            @[@44,@44,@(self.dicountCellHeight)]]];
        [self hideAddressInfor:NO];
        if (shouldShow) {
            [self.view endEditing:YES];
        }
        
        
    }else{
        self.cellHeights = [NSMutableArray arrayWithArray:@[@[@44,@44,@44,@44,@60],
                                                            @[@44,@123,@44],
                                                            @[@44,@44,@(self.dicountCellHeight)]]];
        [self hideAddressInfor:YES];
        
        if (shouldShow) {
            [self.addressTF becomeFirstResponder];
        }
        
    }
    
    if (animate) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }else{
        [self.tableView reloadData];
    }

}

- (void)hideAddressInfor:(BOOL)flag
{
    self.nameLB.hidden = flag;
    self.phoneLB.hidden = flag;
    self.addressLB.hidden = flag;
    self.saveBtn.hidden = !flag;
}

#pragma mark- 获取地址
- (void)addressWithUsername:(NSString*)username
{
    self.saveBtn.hidden = YES;
    [self.dataService addressByUsername:username withCallback:^(NSString *errorString, Address *address) {
        self.saveBtn.hidden = NO;
        [self.flower stopAnimating];
        
        if (errorString) {//没有地址，显示地址更新界面
            [self hideAddressEdit:NO animated:YES showKeyboard:NO];
        }else{ //有地址，将地址更新到界面
            self.address = address;
            
            
            [self hideAddressEdit:YES animated:YES showKeyboard:NO];
        }
        
    }];
}

- (void)setAddress:(Address *)address
{
    _address = address;
    if (address) {
        self.phoneLB.text = address.phone;
        self.nameLB.text = address.realname;
        self.addressLB.text = address.address;
        
        self.phoneTF.text = address.phone;
        self.nameTF.text = address.realname;
        self.addressTF.text = address.address;
    }
}

- (void)setInputOrder:(Order *)inputOrder
{
    _inputOrder = inputOrder;
    
    //是否显示积分抵扣选项
    if (inputOrder.isDeduction) {
        self.dicountCellHeight = 44;
    }else{
        self.dicountCellHeight = 0;
    }
    [self updateGoodsToUI];
}

- (void)updateGoodsToUI
{
    if (self.inputOrder) {
        [self.goodsCoverIMV sd_setImageWithURL:[NSURL URLWithString:self.inputOrder.goods.imageList.firstObject] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
        self.goodsTitleLB.text = self.inputOrder.goods.title;
        self.goodsSalePriceLB.text = [NSString stringWithFormat:@"%.1f + %d积分",self.inputOrder.goods.salePrice,(int)self.inputOrder.goods.needScore];
        self.goodsMarketPriceLB.text = [NSString stringWithFormat:@"原价:%.1f",self.inputOrder.goods.marketPrice];
        self.purchaseCountLB.text = [NSString stringWithFormat:@"x%d",self.inputOrder.orderNum];
        self.totalPriceLB.text = [NSString stringWithFormat:@"共%d件商品，总共¥%.2f元 + %d积分",self.inputOrder.orderNum,self.inputOrder.payNum,(int)self.inputOrder.goods.needScore * self.inputOrder.orderNum];
        
        if (self.inputOrder.goods.salePrice == 0) {
            self.totalPriceLB.text = [NSString stringWithFormat:@"共%d件商品，总共%d积分",self.inputOrder.orderNum,(int)self.inputOrder.goods.needScore * self.inputOrder.orderNum];
            self.alipayOrPointLB.text = @"使用积分支付";
        }
        
    }
}

- (void)toAlipay
{
    
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
    order.tradeNO = self.inputOrder.oId; //订单ID（由商家自行制定）
    order.productName = self.inputOrder.goods.title; //商品标题
    
    NSString *bodyTemp = self.inputOrder.goods.feature;
    if (bodyTemp.length > 15) {
        bodyTemp = [bodyTemp substringToIndex:14];
    }
    
    order.productDescription = bodyTemp; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",self.inputOrder.payNum]; //商品价格
    order.notifyURL =  @"http://appservice.3chunhui.com/chunhui/m/order@paybackNotify.do"; //回调URL
    
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
                [self performSegueWithIdentifier:PayResultSegue sender:@(YES)];
            }else{
                [self performSegueWithIdentifier:PayResultSegue sender:@(NO)];
            }
        }];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PayResultSegue]) {
        BOOL success = [sender boolValue];
        [segue.destinationViewController setValue:@(success) forKey:@"paySucceed"];
        [segue.destinationViewController setValue:self.inputOrder forKey:@"order"];
    }
}


@end
