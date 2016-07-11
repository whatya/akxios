//
//  PointConditionVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/24.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "PointConditionVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"

@interface PointConditionVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *rulesArray;

@end

@implementation PointConditionVC

#define ConditionCellID @"ConditionCell"

//键定义
#define KM_action     @"action"
#define KM_notes      @"notes"
#define KM_points     @"point"

//tag 定义
#define TM_action      1973
#define TM_points      1974
#define TM_notes       1975

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rulesArray = [NSMutableArray new];
    
    NSString *username = [[NSPublic shareInstance] getUserName];
    if (username.length > 0) {
        [self rulessWithUser:username];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rulesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ConditionCellID];
    [self fillCell:cell atIndxPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (void)fillCell:(UITableViewCell*)cell atIndxPath:(NSIndexPath*)indexPath
{
    NSDictionary *modelDic = self.rulesArray[indexPath.row];
    UILabel *actionLB =   [cell viewWithTag:TM_action];
    UILabel *pointLB = [cell viewWithTag:TM_points];
    UILabel *notesLB =  [cell viewWithTag:TM_notes];
    
    actionLB.text = modelDic[KM_action];
    pointLB.text = [NSString stringWithFormat:@"%@",modelDic[KM_points]];
    notesLB.text = modelDic[KM_notes];
    
}

#pragma mark- 数据获取
- (void)rulessWithUser:(NSString*)username
{
    NSArray *keys = @[@"user"];
    NSArray *values = @[username];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@getPointDesc.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                NSArray *points = jsonData[@"data"];
                if ([points isKindOfClass:[NSArray class]]) {
                    [self.rulesArray addObjectsFromArray:points];
                    [self.tableView reloadData];
                }
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍后再试喔！"];
        }
    }];
    
}

@end
