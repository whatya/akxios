//
//  PhoneBillChargerTVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "PhoneBillChargerTVC.h"
#import "CommonConstants.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Util/DataSigner.h"
#import "AlipayOrder.h"

@interface PhoneBillChargerTVC ()<
UICollectionViewDelegate,
UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectiionView;
@property (nonatomic,strong) NSString *targetPhoneNumber;
@property (nonatomic,strong) NSMutableArray *bills;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (nonatomic,strong) Bill *choosedBill;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation PhoneBillChargerTVC

#define BillCell @"BillCell"
- (void)viewDidLoad {
    [super viewDidLoad];
    AddCornerBorder(self.submitBtn, 4, 0, nil);
    self.bills = [NSMutableArray new];
    self.phoneTF.text = self.user.phone;
    [self getAllBills];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bills.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BillCell forIndexPath:indexPath];
    AddCornerBorder(cell, 4, 0.5, [UIColor darkGrayColor].CGColor);
    
    UIImageView *checkImv = [cell viewWithTag:1973];
    UILabel *label = [cell viewWithTag:1974];
    
    
    Bill *bill = self.bills[indexPath.row];
    checkImv.hidden = !bill.checked;
    label.text = [NSString stringWithFormat:@"%d元",(int)bill.salePrice];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Bill *model = self.bills[indexPath.row];
    model.checked = !model.checked;
    
    //清除其它选项
    for (Bill *otherModel in self.bills){
        if (![otherModel isEqual:model]) {
            otherModel.checked = NO;
        }
    }
    
    BOOL hasUserChecked = NO;
    for (Bill *tempModel in self.bills){
        if (tempModel.checked) {
            hasUserChecked = YES;
            break;
        }
    }
    [self.collectiionView reloadData];
    
}
- (IBAction)checkFirst:(UIButton *)sender
{
    
    if (self.phoneTF.text.length == 0) {
        [ProgressHUD showError:@"请输入手机号码！"];
        return;
    }
    
    //面值检测
    Bill *targetBill = nil;
    for (Bill *bill in self.bills){
        if (bill.checked) {
            targetBill = bill;
        }
    }
    
    if (targetBill) {
        self.choosedBill = targetBill;
        [self checkSim:self.phoneTF.text];
    }else{
        [ProgressHUD showError:@"请选择充值金额！"];
    }
    
    
    
}

#define checkSimUrl @"chunhui/m/sim@checkSim.do"
- (void)checkSim:(NSString*)phoneNumber
{
    NSArray *keys = @[@"simCode"];
    NSArray *values = @[phoneNumber];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:checkSimUrl portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:[error localizedDescription]];
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            [ProgressHUD showError:ErrorString(jsonData)];
        }else{
            
            BOOL passed = [jsonData[@"data"][@"isActive"] boolValue];
            
            if (passed) {
                [self submitOrder];
            }else{
                [ProgressHUD showError:@"号码未激活"];
            }
        }
        
    }];
 
}

#define allBillsUrl @"chunhui/m/product@getAllCharge.do"
- (void)getAllBills
{
    
    Bill *bill30 = [[Bill alloc] init];
    bill30.bid = @"201605181723217793";
    bill30.salePrice = 30;
    
    Bill *bill50 = [[Bill alloc] init];
    bill50.bid = @"201605181723217794";
    bill50.salePrice = 50;
    
    Bill *bill100 = [[Bill alloc] init];
    bill100.bid = @"201605181723217795";
    bill100.salePrice = 100;
    
    [self.bills addObjectsFromArray:@[bill30,bill50,bill100]];
    [self.collectiionView reloadData];
    
    /*
    //配置端口
    NSString *urlPlusPort = [NSString stringWithFormat:@"%@%d/",HttpServerUrl,80];
    
    // 1、配置session configuration
    NSString* url = [NSString stringWithFormat:@"%@%@",urlPlusPort,allBillsUrl];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithqueryString:url callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:[error localizedDescription]];
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            [ProgressHUD showError:ErrorString(jsonData)];
        }else{
            NSArray *bills = jsonData[@"data"];
            for (NSDictionary* dictionary in bills){
                Bill *bill = [[Bill alloc] initFromDictionary:dictionary];
                [self.bills addObject:bill];
            }
            [self.collectiionView reloadData];
        }
        
    }];
     */
}

#define initServerOrderUrl @"chunhui/m/order@submitRechargeOrder.do"
- (void)submitOrder
{
    [ProgressHUD show:@"处理中..."];
    NSString *user = [[NSPublic shareInstance] getUserName] ?: @"";
    NSString *productId = self.choosedBill.bid ?: @"";
    NSString *mobile = self.phoneTF.text ?: @"";
    NSString *realname = self.user.name ?: @"";
    NSString *idCard = @"";
    NSString *payNmu = [NSString stringWithFormat:@"%d",(int)self.choosedBill.salePrice];
    NSString *payPaltform = @"1";
    
    NSArray *keys = @[@"user",@"productId",@"mobile",@"realname",@"idcard",@"payNum",@"payPaltform"];
    NSArray *vals = @[user,productId,mobile,realname,idCard,payNmu,payPaltform];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:vals];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:initServerOrderUrl portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:[error localizedDescription]];
            return ;
        }
        
        if (IsSuccessful(jsonData)) {
            [ProgressHUD dismiss];
            NSString *gotId = jsonData[@"data"][@"orderId"];
            [self toAlipayWithOid:gotId];
            
        }else{
            [ProgressHUD showError:ErrorString(jsonData)];
        }
        
        
    }];
    
}


- (void)toAlipayWithOid:(NSString*)oId
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
    order.tradeNO = oId; //订单ID（由商家自行制定）
    order.productName = @"话费充值"; //商品标题
    
    NSString *bodyTemp = [NSString stringWithFormat:@"号码：%@",self.phoneTF.text];
    if (bodyTemp.length > 15) {
        bodyTemp = [bodyTemp substringToIndex:14];
    }
    
    order.productDescription = bodyTemp; //商品描述
    order.amount =  [NSString stringWithFormat:@"%.2f",self.choosedBill.salePrice]; //商品价格
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
                [ProgressHUD showSuccess:@"充值成功"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    PUSH(@"More", @"BillRecordsVC", @"充值纪录", @{}, YES);
                });
                
            }else{
                [ProgressHUD showError:@"充值失败！"];
            }
        }];
    }
}



@end

@implementation Bill

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _bid = dictionary[K_bill_id];
        _salePrice = [dictionary[K_bill_salePrice] doubleValue];
        _marketPrice = [dictionary[K_bill_marketPrice] doubleValue];
    }
    return self;
}

@end
