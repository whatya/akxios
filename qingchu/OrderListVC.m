//
//  OrderListVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/15.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "OrderListVC.h"
#import "OrderCell.h"
#import "Order.h"
#import "UIImageView+WebCache.h"
#import "OrderDataService.h"
#import "ProgressHUD.h"
#import "MJRefresh.h"
#import "NSPublic.h"
#import "CommonConstants.h"
#import "ServeOrderDataService.h"


@interface OrderListVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *orders;
@property (nonatomic,assign) int currentPageNo;
@property (nonatomic,strong) OrderDataService *dataService;
@property (nonatomic,strong) ServeOrderDataService *skillDataService;

@property (weak, nonatomic) IBOutlet UIButton *proBtn;
@property (weak, nonatomic) IBOutlet UIButton *skiBtn;
@property (weak, nonatomic) IBOutlet UIView *proBanView;
@property (weak, nonatomic) IBOutlet UIView *skiBanView;

@end

@implementation OrderListVC

#define PageSize            10
#define OrderCellID         @"OrderCell"
#define RowHeights          236

#define OrderDescSegue      @"To OrderDescVC"


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataService = [[OrderDataService alloc] init];
    self.skillDataService = [[ServeOrderDataService alloc] init];
    self.orders = [NSMutableArray new];
    
    NSString *username = [[NSPublic shareInstance] getUserName];
    
    __weak OrderListVC *weak_self = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
       
        weak_self.currentPageNo ++;
        [weak_self fillOrdersWithUsername:username from:weak_self.currentPageNo to:PageSize];
        
    }];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weak_self.currentPageNo = 0;
        [self fillOrdersWithUsername:username from:weak_self.currentPageNo to:PageSize];
    }];
    
    [self.tableView.mj_header setState:MJRefreshStateRefreshing];
    
    UIColor *themColor = [UIColor colorWithRed:224/255.0 green:43/255.0 blue:30/255.0 alpha:1];
    //设置按钮选中样式
    [self.proBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [self.skiBtn setTitleColor:themColor forState:UIControlStateSelected];
    self.proBtn.tintColor = [UIColor clearColor];
    self.skiBtn.tintColor = [UIColor clearColor];
    [self toggleList:self.proBtn];

}


- (IBAction)toggleList:(UIButton *)sender {
    
    [self.orders removeAllObjects];
    [self.tableView reloadData];
    
    if ([sender isEqual:self.proBtn]) {
        self.proBtn.selected = YES;
        self.proBanView.hidden = NO;
        
        self.skiBtn.selected = NO;
        self.skiBanView.hidden = YES;
        
        self.orderType = @"商品";
        
    }else{
        
        self.proBtn.selected = NO;
        self.proBanView.hidden = YES;
        
        self.skiBtn.selected = YES;
        self.skiBanView.hidden = NO;
        
        self.orderType = @"服务";
        
    }
    
    [self.tableView.mj_header setState:MJRefreshStateRefreshing];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RowHeights;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OrderCellID];
    [self fillCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)fillCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    OrderCell *orderCell = (OrderCell*)cell;
    AddCornerBorder(orderCell.coverIMV, 1, 0.5, [UIColor colorWithRed:221/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor);
    Order *model = self.orders[indexPath.row];
    orderCell.timeLB.text = model.payTime;
    orderCell.titleLB.text = model.title;
    orderCell.salePrcieLB.text = [NSString stringWithFormat:@"¥%.1f",model.salePrice];
    orderCell.marketPriceLB.text = [NSString stringWithFormat:@"原价¥%.1f",model.marketPrice];
    orderCell.countLB.text = [NSString stringWithFormat:@"x%d",model.orderNum];
    NSString *url = model.imageList.firstObject;
    [orderCell.coverIMV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    
    if ([self.orderType isEqualToString:@"服务"]) {
        orderCell.statusLB.text = [NSString stringWithFormat:@"%@到期 剩余%d次",model.validDate,model.canUseTimes];
        
        if ([model.serverOrderType isEqualToString:@"once_service"]) {
            orderCell.statusLB.text = @"按次服务";
        }
        
    }else{
        orderCell.statusLB.text = model.statusString;
    }
    
    orderCell.totalPriceLB.text = [NSString stringWithFormat:@"共%d件商品，总共¥%.2f元",model.orderNum,model.payNum];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:OrderDescSegue]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            Order *model = self.orders[indexPath.row];
            [segue.destinationViewController setValue:model.oId forKey:@"inputOrderId"];
        }
    }
}



- (void)fillOrdersWithUsername:(NSString*)username from:(int)pageIndex to:(int)pageSize
{
    
    if ([self.orderType isEqualToString:@"服务"]) {
        
        [self.skillDataService serveOrderListWithUser:username from:pageIndex to:pageSize withCallback:^(NSString *errorString, NSArray *serves) {
            
            if (errorString) {
                [ProgressHUD showError:errorString];
                [self.tableView.mj_header setState:MJRefreshStateIdle];
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                if (pageIndex == 0) {
                    [self.orders removeAllObjects];
                    [self.tableView reloadData];
                    [self.tableView.mj_header endRefreshing];
                }
                
                if (serves.count > 0) {
                    
                    for (Order *order in serves){
                        //if (order.status != UNPAY) {
                        [self.orders addObject:order];
                        // }
                    }
                    
                    [self.tableView reloadData];
                    [self.tableView.mj_footer endRefreshing];
                }else{
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            
            
        }];
        
        return;
    }
    
    [self.dataService orderListWithUser:username from:pageIndex to:pageSize withCallback:^(NSString *errorString, NSArray *orders) {
        
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self.tableView.mj_header setState:MJRefreshStateIdle];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            if (pageIndex == 0) {
                [self.orders removeAllObjects];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            }
            
            if (orders.count > 0) {
                
                for (Order *order in orders){
                    if (order.status != UNPAY) {
                        [self.orders addObject:order];
                    }
                }
                
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    }];
}


@end
