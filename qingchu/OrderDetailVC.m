//
//  OrderDetailVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/16.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "OrderDetailVC.h"
#import "NSPublic.h"
#import "CommonConstants.h"
#import "OrderDataService.h"
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface OrderDetailVC ()

//receiver related outlets
@property (weak, nonatomic) IBOutlet UILabel *receiverTitleLB;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *phoneLB;
@property (weak, nonatomic) IBOutlet UILabel *addressLB;
@property (weak, nonatomic) IBOutlet UILabel *receiverNameLB;
@property (weak, nonatomic) IBOutlet UILabel *cylcleDoctorNameLB;

//order related outlets
@property (weak, nonatomic) IBOutlet UILabel *orderNumLB;
@property (weak, nonatomic) IBOutlet UILabel *payLB;
@property (weak, nonatomic) IBOutlet UILabel *statusLB;
@property (weak, nonatomic) IBOutlet UILabel *shipCompanyLB;
@property (weak, nonatomic) IBOutlet UILabel *shipNoLB;

//goods related outlets

@property (weak, nonatomic) IBOutlet UILabel *orderTitleLB;
@property (weak, nonatomic) IBOutlet UIImageView *goodsCoverIMV;
@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLB;
@property (weak, nonatomic) IBOutlet UILabel *goodsSalePriceLB;
@property (weak, nonatomic) IBOutlet UILabel *goodsMarketPriceLB;
@property (weak, nonatomic) IBOutlet UILabel *goodsCountLB;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLB;
@property (weak, nonatomic) IBOutlet UILabel *timeTermLB;
@property (weak, nonatomic) IBOutlet UILabel *leftTimesLB;
@property (weak, nonatomic) IBOutlet UILabel *termTitleLB;

@property (weak, nonatomic) IBOutlet UILabel *doctorNameTitleLB;
@property (weak, nonatomic) IBOutlet UILabel *doctorNameLB;

//data related
@property (nonatomic,strong) OrderDataService *dataService;

@property (nonatomic,strong) NSMutableArray *cellHeights;
@property (nonatomic,strong) Order *fetchdOrder;

//extra btns
@property (weak, nonatomic) IBOutlet UIButton *comentBtn;
@property (weak, nonatomic) IBOutlet UIButton *doctorRecordsBtn;

@end

@implementation OrderDetailVC

#pragma mark- 生命周期
- (void)viewDidLoad
{
    NSString *username = [[NSPublic shareInstance] getUserName];
    AddCornerBorder(self.goodsCoverIMV, 1, 0.5, [UIColor colorWithRed:221/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor);
    
    self.cellHeights = [NSMutableArray arrayWithArray:@[@[@44,@86,@44,@44],@[@44,@35,@35,@35,@35,@35,@35,@35,@35,@1],@[@44,@122,@44]]];
    
    AddCornerBorder(self.comentBtn, 4, 0.5, [UIColor darkGrayColor].CGColor);
    AddCornerBorder(self.doctorRecordsBtn, 4, 0.5, [UIColor darkGrayColor].CGColor);
    
    [self orderDetailWith:username orderId:self.inputOrderId];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [ProgressHUD dismiss];
}

#pragma mark- 更新ui
- (void)updateUIWithOrder:(Order*)order
{
  
    self.nameLB.text = order.address.realname;
    self.phoneLB.text = order.address.phone;
    self.addressLB.text = order.address.address;
    
    self.orderNumLB.text = order.oId;
    self.payLB.text = order.payTime;
    self.statusLB.text = order.statusString;
    self.shipCompanyLB.text = order.logistics.expressName;
    self.shipNoLB.text = order.logistics.transactionId;
    
    self.goodsTitleLB.text = order.title;
    self.goodsSalePriceLB.text = [NSString stringWithFormat:@"¥%.1f",order.salePrice];
    self.goodsMarketPriceLB.text = [NSString stringWithFormat:@"原价 %.1f",order.marketPrice];
    self.goodsCountLB.text = [NSString stringWithFormat:@"x%d",order.orderNum];
    self.totalPriceLB.text = [NSString stringWithFormat:@"共%d件商品，总共¥%.2f元",order.orderNum,order.payNum];
    NSString *coverImgStr = order.imageList.firstObject;
    [self.goodsCoverIMV sd_setImageWithURL:[NSURL URLWithString:coverImgStr] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    self.timeTermLB.text = order.validDate;
    self.doctorNameLB.text = order.doctorName?:@"";
    self.receiverNameLB.text = order.receiverName;
    self.cylcleDoctorNameLB.text = order.doctorName;
    self.leftTimesLB.text = [NSString stringWithFormat:@"%d次",order.canUseTimes];

    
    if ([order.serverOrderType isEqualToString:@"once_service"]) {
        self.receiverTitleLB.text = @"联系人信息";
        self.orderTitleLB.text = @"服务信息";
        
        if (order.logistics.transactionId.length == 0) {
            
            self.cellHeights = [NSMutableArray arrayWithArray:@[
                                                                @[@44,@86,@0,@0],
                                                                @[@44,@35,@35,@35,@35,@35,@0,@0,@0,@1],
                                                                @[@44,@122,@44]]];
            self.comentBtn.hidden= NO;
            self.doctorRecordsBtn.hidden = NO;
            
        }else{
            
            self.cellHeights = [NSMutableArray arrayWithArray:@[
                                                                @[@44,@86,@0,@0],
                                                                @[@44,@35,@35,@35,@35,@35,@0,@35,@35,@1],
                                                                @[@44,@122,@44]]];
            
        }
        
    }else if([order.serverOrderType isEqualToString:@"cycle_service"]) {
        self.receiverTitleLB.text = @"联系人信息";
        self.orderTitleLB.text = @"服务信息";
        self.termTitleLB.text = @"有效期";
        
        if (order.logistics.transactionId.length == 0) {
            
            self.cellHeights = [NSMutableArray arrayWithArray:@[
                                                                @[@0,@0,@44,@44],
                                                                @[@44,@35,@35,@35,@35,@0,@35,@0,@0,@1],
                                                                @[@44,@122,@44]]];
            
        }else{
            
            self.cellHeights = [NSMutableArray arrayWithArray:@[
                                                                @[@0,@0,@44,@44],
                                                                @[@44,@35,@35,@35,@35,@0,@35,@35,@35,@1],
                                                                @[@44,@122,@44]]];
            
        }

        
    }else{
        self.receiverTitleLB.text = @"收货人信息";
        self.orderTitleLB.text = @"商品信息";
        
        if (order.logistics.transactionId.length == 0) {
            
            self.cellHeights = [NSMutableArray arrayWithArray:@[
                                                                @[@44,@86,@0,@0],
                                                                @[@44,@35,@35,@35,@0,@0,@0,@0,@0,@1],
                                                                @[@44,@122,@44]]];
            
        }else{
            
            self.cellHeights = [NSMutableArray arrayWithArray:@[
                                                                @[@44,@86,@0,@0],
                                                                @[@44,@35,@35,@35,@0,@0,@0,@35,@35,@1],
                                                                @[@44,@122,@44]]];
        }

        
    }
    

    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == 1) {
        
        if (self.fetchdOrder) {
            PUSH(@"Mall", @"ItemDetailVC", @"商品详情", @{@"inputGoodsId":self.fetchdOrder.gId}, YES)
        }
        
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellHeights[indexPath.section][indexPath.row] floatValue];
    
}

#pragma mark- 数据获取
- (void)orderDetailWith:(NSString*)username orderId:(NSString*)orderId
{
    [ProgressHUD show:@"获取订单中..."];
    [self.dataService orderDetailWithUsername:username andOrderId:orderId withCallback:^(NSString *errorString, Order *order) {
        if (errorString) {
            [ProgressHUD showError:errorString];
        }else{
            [ProgressHUD dismiss];
            self.fetchdOrder = order;
            [self updateUIWithOrder:order];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Go Comment VC"]) {
        [segue.destinationViewController setValue:self.fetchdOrder.oId forKey:@"targetID"];
    }else if ([segue.identifier isEqualToString:@"Show Skill Records"]){
        [segue.destinationViewController setValue:self.fetchdOrder.oId forKey:@"inputOrderID"];
    }
}


- (OrderDataService *)dataService
{
    if (!_dataService) {
        _dataService = [[OrderDataService alloc] init];
    }
    return _dataService;
}

@end
