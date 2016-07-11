//
//  BillRecordsVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "BillRecordsVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "CommonConstants.h"
#import "ProgressHUD.h"

@interface BillRecordsVC ()
<UITableViewDelegate,
UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *records;

@end

@implementation BillRecordsVC
#define CellID @"BillRecordCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.records = [NSMutableArray new];
    [self fetchBillsRecord];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BillRecord *record = self.records[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    UILabel *timeLB = [cell viewWithTag:1973];
    UILabel *contentLB = [cell viewWithTag:1974];
    UILabel *statusLB = [cell viewWithTag:1975];
    UILabel *provideLB = [cell viewWithTag:1976];
    
    timeLB.text = [NSString stringWithFormat:@"付款时间:%@",record.payTime];
    contentLB.text = [NSString stringWithFormat:@"%@ 充值%@元",record.mobile,
                      record.fee];
    statusLB.text = [record.status isEqualToString:@"1"] ? @"正在充值" : @"充值成功";
    
    provideLB.text = [NSString stringWithFormat:@"%@提供",record.provider];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

#define billRecordsUrl @"chunhui/m/order@getAllRechargeOrder.do"
- (void)fetchBillsRecord
{
    NSString *user = [[NSPublic shareInstance] getUserName] ?: @"";
    NSString *pageNum = @"0";
    NSString *pageSize = @"1000";
    
    NSArray *keys = @[@"user",@"pageNum",@"pageSize"];
    NSArray *vals = @[user,pageNum,pageSize];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:vals];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:billRecordsUrl portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:[error localizedDescription]];
            return ;
        }
        
        if (IsSuccessful(jsonData)) {
            
            NSArray *recordDics = jsonData[@"data"];
            for (NSDictionary *dic in recordDics){
                BillRecord *record = [[BillRecord alloc] initFromDictionary:dic];
                [self.records addObject:record];
            }
            [self.tableView reloadData];
            
        }else{
            [ProgressHUD showError:ErrorString(jsonData)];
        }
        
        
    }];

}

@end

@implementation BillRecord

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _rechargeId = dictionary[K_billRecord_rechargeId];
        _payTime = dictionary[K_billRecord_payTime];
        _rechargeTime = dictionary[K_billRecord_rechargeTime];
        _mobile = dictionary[K_billRecord_mobile];
        _fee = [NSString stringWithFormat:@"%@",dictionary[K_billRecord_fee]];
        _provider = dictionary[K_billRecord_provider];
        _status = [NSString stringWithFormat:@"%@",dictionary[K_billRecord_status]];
    }
    return self;
}

@end
