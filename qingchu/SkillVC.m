//
//  SkillVC.m
//  qingchu
//
//  Created by 张宝 on 16/5/25.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillVC.h"
#import "CommonConstants.h"
#import "SkillCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "ItemDataService.h"
#import "SkillHeader.h"

@interface SkillVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,  weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *skillsArray;
@property (nonatomic,strong) NSMutableArray *skillTimesArray;
@property (nonatomic, strong) ItemDataService *dataServices;


@end

@implementation SkillVC

#define CellID @"SkillCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    //搜索视图界面
    
    self.skillsArray = [NSMutableArray new];
    self.skillTimesArray = [NSMutableArray new];
    self.dataServices = [[ItemDataService alloc] init];
    
    __weak SkillVC *weak_self = self;
    
    NSString *username = [[NSPublic shareInstance] getUserName];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        Query *query1 = [[Query alloc] init];
        query1.pageNum = 0;
        query1.user = username;
        query1.pageSize = 40;
        query1.pType = 1;
        [weak_self fillSkillsWith:query1];
        
        Query *query2 = [[Query alloc] init];
        query2.pageNum = 0;
        query2.user = username;
        query2.pageSize = 40;
        query2.pType = 2;
        
        
        [weak_self fillTimesSkillsWith:query2];
        
    }];
    [self.tableView.mj_header setState:MJRefreshStateRefreshing];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.skillsArray.count;
    }else if (section == 1){
        return self.skillTimesArray.count;
    }else{
        return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    if (section == 0) {
        SkillHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"SkillHeader" owner:self options:nil] lastObject];
        header.headerLB.text = @"周期服务";
        header.moreBtn.hidden = NO;
        header.moreBtn.tag = 1973;
        
        header.pushAction = ^(){
            PUSH(@"Mall", @"SkillChildVC", @"周期服务", @{@"skillsType":@"周期服务"}, YES);
        };
        
        if (self.skillsArray.count == 0) {
            header.headerLB.text = @"";
            header.moreBtn.hidden = YES;
        }
        return header;
    }else{
        SkillHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"SkillHeader" owner:self options:nil] lastObject];
        header.headerLB.text = @"按次服务";
        header.moreBtn.hidden = NO;
        header.moreBtn.tag = 1974;
        header.pushAction = ^(){
            PUSH(@"Mall", @"SkillChildVC", @"按次服务", @{@"skillsType":@"按次服务"}, YES);
        };

        if (self.skillTimesArray.count == 0) {
            header.headerLB.text = @"";
            header.moreBtn.hidden = YES;
        }
        return header;
    }
    
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
    Skill *model = indePath.section == 0 ? self.skillsArray[indePath.row] : self.skillTimesArray[indePath.row];
    
    [sCell.imv sd_setImageWithURL:URL(model.imageList.firstObject) placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    sCell.nameLB.text = model.title;
    sCell.priceLB.text = [NSString stringWithFormat:@"¥%.1f",model.salePrice];
    sCell.pointLB.text = [NSString stringWithFormat:@"+%d积分",(int)model.needScore];
    NSString *termString = model.serviceTerm > 0 ? [NSString stringWithFormat:@"服务时长:%d个月 ",model.serviceTerm] : @"";
    
    sCell.noteLB.text = indePath.section == 0? [NSString stringWithFormat:@"%@服务次数：%d",termString,model.useTimes] : @"";
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *targetArray = indexPath.section == 0 ? self.skillsArray : self.skillTimesArray;
    Goods *model = targetArray[indexPath.row];
    NSString *type = indexPath.section == 0 ? @"" : @"按次服务";
    PUSH(@"Mall", @"ItemDetailVC", @"服务详情", (@{@"inputGoodsId":model.gId,@"itemType":@"服务",@"type":type}), YES);
}

#pragma mark- data fetch relative
- (void)fillSkillsWith:(Query*)query
{
    [self.dataServices itemsWithQuery:query andCallback:^(NSString *errorString, NSArray *items) {
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self.tableView.mj_header setState:MJRefreshStateIdle];
        }else{
            if (query.pageNum == 0) {
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

- (void)fillTimesSkillsWith:(Query*)query
{
    [self.dataServices itemsWithQuery:query andCallback:^(NSString *errorString, NSArray *items) {
        if (errorString) {
            [ProgressHUD showError:errorString];
            [self.tableView.mj_header setState:MJRefreshStateIdle];
        }else{
            if (query.pageNum == 0) {
                [self.skillTimesArray removeAllObjects];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            }
            if (items.count > 0) {
                
                [self.skillTimesArray addObjectsFromArray:items];
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
                
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    }];

}

@end
