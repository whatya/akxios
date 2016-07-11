//
//  GradeListVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/24.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "GradeListVC.h"
#import "HttpManager.h"
#import "NSPublic.h"
#import "ProgressHUD.h"

@interface GradeListVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *gradesArray;
@property (weak, nonatomic) IBOutlet UILabel *gradeLB;

@end

@implementation GradeListVC

#define GradeCellID @"GradeCellID"

// Tag define
#define TG_name   1973
#define TG_point  1974


//键定义
#define KG_name   @"gradeName"
#define KG_point  @"lowPoint"

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gradesArray = [NSMutableArray new];
    NSString *username = [[NSPublic shareInstance] getUserName];
    if (username.length > 0) {
        [self gradesWithUser:username];
    }
    self.gradeLB.text = [NSString stringWithFormat:@"当前等级:%@",self.inputGradeStr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gradesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GradeCellID];
    [self fillCell:cell atIndxPath:indexPath];
    return cell;
}


- (void)fillCell:(UITableViewCell*)cell atIndxPath:(NSIndexPath*)indexPath
{
    NSDictionary *modelDic = self.gradesArray[indexPath.row];
    UILabel *nameLB =   [cell viewWithTag:TG_name];
    UILabel *pointLB = [cell viewWithTag:TG_point];
    
    nameLB.text = modelDic[KG_name];
    pointLB.text = [NSString stringWithFormat:@"%@",modelDic[KG_point]];
    
}

#pragma mark- 数据获取
- (void)gradesWithUser:(NSString*)username
{
    NSArray *keys = @[@"user"];
    NSArray *values = @[username];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@getGradeDesc.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                NSArray *points = jsonData[@"data"];
                if ([points isKindOfClass:[NSArray class]]) {
                    [self.gradesArray addObjectsFromArray:points];
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
