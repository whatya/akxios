//
//  SkillChildVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/9.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillChildVC.h"
#import "CommonConstants.h"
#import "SkillCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "ItemDataService.h"
#import "Query.h"

@interface SkillChildVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *skillsArray;
@property (nonatomic, strong) ItemDataService *dataServices;
@property (nonatomic, strong) Query *query;

@end

@implementation SkillChildVC


#define CellID @"SkillCell"
#define PageSize 10

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *username = [[NSPublic shareInstance] getUserName];
    self.skillsArray = [NSMutableArray new];
    self.dataServices = [[ItemDataService alloc] init];
    self.query = [[Query alloc] init];
    self.query.pageNum = 0;
    self.query.pageSize  = PageSize;
    self.query.user = username;
    
    //根据输入产生区别请求数据
    if ([self.skillsType isEqualToString:@"周期服务"]) {
        self.query.pType = 1;
    }else if ([self.skillsType isEqualToString:@"按次服务"]){
        self.query.pType = 2;
    }else{
        // do noth for now
    }
    
    //上拉刷新
    __weak SkillChildVC *weak_self = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        weak_self.query.pageNum = 0;
        [weak_self fillSkills];
        
    }];
    
    
    //下拉加载更多
    self.tableView.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weak_self.query.pageNum ++;
        [weak_self fillSkills];
        
    }];
    
    [self.tableView.mj_header setState:MJRefreshStateRefreshing];

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.skillsArray.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    [self fillCell:cell at:indexPath];
    return cell;
}



- (void)fillCell:(UITableViewCell*)cell at:(NSIndexPath*)indePath
{
    SkillCell *sCell = (SkillCell*)cell;
    Skill *model = self.skillsArray[indePath.row];
    
    [sCell.imv sd_setImageWithURL:URL(model.imageList.firstObject) placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    sCell.nameLB.text = model.title;
    sCell.priceLB.text = [NSString stringWithFormat:@"¥%.1f",model.salePrice];
    sCell.pointLB.text = [NSString stringWithFormat:@"+%d积分",(int)model.needScore];
    NSString *termString = model.serviceTerm > 0 ? [NSString stringWithFormat:@"服务时长:%d个月 ",model.serviceTerm] : @"";
    sCell.noteLB.text = indePath.section == 0? [NSString stringWithFormat:@"%@服务次数：%d",termString,model.useTimes] : @"";
    if ([self.skillsType isEqualToString:@"按次服务"]) {
        sCell.noteLB.text = @"";
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Skill *model = self.skillsArray[indexPath.row];
    if ([self.skillsType isEqualToString:@"按次服务"]) {
        PUSH(@"Mall", @"ItemDetailVC", @"服务详情", (@{@"inputGoodsId":model.gId,@"itemType":@"服务",@"type":@"按次服务"}), YES);
    }else{
        PUSH(@"Mall", @"ItemDetailVC", @"服务详情", (@{@"inputGoodsId":model.gId,@"itemType":@"服务"}), YES);
    }
    
}

#pragma mark- 获取数据
- (void)fillSkills
{
    [self.dataServices itemsWithQuery:self.query andCallback:^(NSString *errorString, NSArray *items) {
       
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self.tableView.mj_header setState:MJRefreshStateIdle];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            if (self.query.pageNum == 0) {
                [self.skillsArray removeAllObjects];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            }
            if (items.count > 0) {
                
                [self.skillsArray addObjectsFromArray:items];
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
                
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}


- (IBAction)search:(id)sender {
    UIViewController *searchVC  = VCFromStoryboard(@"Mall", @"MallSearchVC");
    
    [searchVC setValue:@"服务" forKey:@"searchType"];
    [searchVC setValue:self.skillsType forKey:@"type"];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    searchNav.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0 green:77/255.0 blue:8/255.0 alpha:1];
    [self presentViewController:searchNav animated:YES completion:NULL];
}



@end
