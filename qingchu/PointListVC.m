//
//  PointListVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/24.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "PointListVC.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "HttpManager.h"

@interface PointListVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentPointsLB;
@property (weak, nonatomic) IBOutlet UILabel *totalPointsLB;
@property (weak, nonatomic) IBOutlet UILabel *usedPointsLB;

@property (nonatomic,strong) NSMutableArray *pointsArray;

@end

@implementation PointListVC

#define PointsCellID @"PointCell"

//键定义
#define KP_date     @"actionTime"
#define KP_action   @"action"
#define KP_value    @"point"

//tag 定义
#define T_date      1973
#define T_action    1974
#define T_value     1975

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pointsArray = [NSMutableArray new];
    NSString *username = [[NSPublic shareInstance] getUserName];
    if (username.length > 0) {
        [self pointsWithUser:username from:0 to:100];
    }
    
    self.totalPointsLB.text = [NSString stringWithFormat:@"%d",self.totalPoints];
    self.currentPointsLB.text = [NSString stringWithFormat:@"%d",self.currentPoints];
    self.usedPointsLB.text = [NSString stringWithFormat:@"%d",self.totalPoints- self.currentPoints];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pointsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PointsCellID];
    [self fillCell:cell atIndxPath:indexPath];
    return cell;
}


- (void)fillCell:(UITableViewCell*)cell atIndxPath:(NSIndexPath*)indexPath
{
    NSDictionary *modelDic = self.pointsArray[indexPath.row];
    UILabel *dateLB =   [cell viewWithTag:T_date];
    UILabel *actionLB = [cell viewWithTag:T_action];
    UILabel *valueLB =  [cell viewWithTag:T_value];
    
    dateLB.text = modelDic[KP_date];
    actionLB.text = modelDic[KP_action];
    valueLB.text = [NSString stringWithFormat:@"%@",modelDic[KP_value]];
    
}


#pragma mark- 数据获取
- (void)pointsWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize
{
    NSArray *keys = @[@"user",@"pageNum",@"pageSize"];
    NSArray *values = @[username,
                        [NSString stringWithFormat:@"%d",pageIndex],
                        [NSString stringWithFormat:@"%d",pageSize]];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@getPointHistory.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
               
                NSArray *points = jsonData[@"data"];
                if ([points isKindOfClass:[NSArray class]]) {
                    [self.pointsArray addObjectsFromArray:points];
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
