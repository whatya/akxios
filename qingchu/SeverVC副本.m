//
//  SeverVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/6.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SeverVC.h"
#import "SeverCell.h"
#import "MJRefresh.h"

#import "UIImageView+WebCache.h"
#import "NSPublic.h"
#import "V2LoginTVC.h"
#import "ProgressHUD.h"
#import "ItemDataService.h"
#import "Goods.h"
#import "HttpManager.h"
#import "ItemAPI.h"
#import "CHTCollectionViewWaterfallLayout.h"

@interface SeverVC ()<UITableViewDataSource,UITableViewDelegate>

{
    
    UIButton *_severButton;
    
    UIButton *_goodsButton;
    
    UIImageView *_indexImage1;
    UIImageView *_indexImage2;
    
}


@property (nonatomic, strong) NSArray *cellSize;
@property (nonatomic, strong) NSMutableArray *severs;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, strong) ItemDataService *dataServices;

@end

@implementation SeverVC

#define PageSize           10
#define Cell_count         20
#define cell_identifier    @"SeverCell"
#define SeverDetailSegue   @"To SeverDetailVC"
#define NavBarHeight 44.0f

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    _indexImage1.hidden = YES;
    self.navigationController.navigationBarHidden = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];
    //self.view.backgroundColor = [UIColor orangeColor];
    [self navigationBar];
    
    
    self.dataServices = [[ItemDataService alloc] init];
    self.severs = [NSMutableArray array];
    
    __weak SeverVC *weak_self = self;
    
    NSString *username = [[NSPublic shareInstance] getUserName];
    
    if (!username) {
        
        username = @"";
    }
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        weak_self.currentPage ++;
        [weak_self fillSeversWithTitle:@"" user:(NSString *)username  from:weak_self.currentPage to:PageSize];
    }];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        weak_self.currentPage = 0;
        [self fillSeversWithTitle:@"" user:(NSString *)username from:weak_self.currentPage to:PageSize];
    }];
    [self.tableView.mj_header setState:MJRefreshStateRefreshing];
    
    _tableView.delegate = self;
    
    _tableView.dataSource = self;

    [self itemsWithTitle:@"" user:@"13125052494" from:0 to:10 withCallback:nil];
}

#pragma mark - loadData
- (void)itemsWithTitle:(NSString *)title user:(NSString *)username from:(int)pageIndex to:(int)pageSize withCallback:(void (^)(NSString *, NSArray *))action{

    ShowLog
    
    if (title.length == 0) {
        NSLog(@"title为空！");
    }
    
    if (username.length == 0) {
        NSLog(@"username为空！");
    }
    
    if (pageIndex < 0) {
        NSLog(@"%@",[NSString stringWithFormat:@"pageIndex(输入值：%d)不能小于0",pageIndex]);
        return;
    }
    
    if (pageSize < 1) {
        NSLog(@"%@",[NSString stringWithFormat:@"pageSize(输入值：%d)必须大于0",pageSize]);
        return;
    }
    
    NSArray *keys = @[@"title",@"user",@"pageNum",@"pageSize",@"pType"];
    
    NSArray *values = @[title,username,[NSString stringWithFormat:@"%d",pageIndex],[NSString stringWithFormat:@"%d",pageSize],@"1"];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:ItemsList portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            action(@"服务错误！",@[]);
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            NSLog(@"%@",ErrorString(jsonData));
            action(ErrorString(jsonData),@[]);
            return;
        }
        
        //action(nil,jsonData[@"data"]);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.severs.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    [_tableView registerClass:[SeverCell class] forCellReuseIdentifier:cell_identifier];
    
    SeverCell *cell = (SeverCell *)[tableView dequeueReusableCellWithIdentifier:cell_identifier forIndexPath:indexPath];
    
    
    [self fillCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"select at : %@",indexPath);
}

- (void)fillCell:(SeverCell *)cell atIndexPath:(NSIndexPath *)indexPath{

    Goods *model = self.severs[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.timeLabel.text = [NSString stringWithFormat:@"%d",model.useTimes];
    cell.numLabel.text  = [NSString stringWithFormat:@"%d",model.serviceTerm];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.imageList.firstObject] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
    
    UIView *selectView = [[UIView alloc] initWithFrame:cell.bounds];
    selectView.backgroundColor = [UIColor lightGrayColor];
    cell.selectedBackgroundView = selectView;
    
    NSLog(@"sever image url : %@",model.imageList.firstObject);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 150.0f;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 
    if ([segue.identifier isEqualToString:SeverDetailSegue]) {
        
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            
            Goods *model = self.severs[indexPath.row];
            [segue.destinationViewController setValue:model.gId forKey:@"inputSeverId"];
        }
    }
}

#pragma mark- data fetch relative
- (void)fillSeversWithTitle:(NSString *)title user:(NSString *)username from:(int)index to:(int)size{
      ShowLog
    
    [self.dataServices itemsWithTitle:title user:(NSString *)username from:index to:size withCallback:^(NSString *errorString, NSArray *items) {
        
        if (errorString) {
            
            [ProgressHUD showError:errorString];
            [self.tableView.mj_header setState:MJRefreshStateIdle];
        }else{
        
            if (index == 0) {
                
                [self.severs removeAllObjects];
                [self.tableView.mj_header endRefreshing];
            }
            if (items.count >0) {
                
                [self.severs addObjectsFromArray:items];
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
            
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

#pragma mark - 自定义navigationBar
- (void)navigationBar{
    
    NSArray *nameArray = @[@"商品",@"服务"];
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0, 20, Screen_Width, NavBarHeight)];
    
    iv.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:iv];
    
    _goodsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _goodsButton.frame = CGRectMake((Screen_Width-60-60)/2, 5, 50, 34);
    
    [_goodsButton setTitle:nameArray[0] forState:UIControlStateNormal];
    [_goodsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _goodsButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    _indexImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_goodsButton.frame)-_goodsButton.frame.size.width + 10, CGRectGetMaxY(_goodsButton.frame)-7, 25, 12)];
    _indexImage1.image = [UIImage imageNamed:@"切换.png"];
    [_goodsButton addTarget:self action:@selector(goodButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _indexImage1.hidden = NO;
    
    _severButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _severButton.frame = CGRectMake(CGRectGetMaxX(_goodsButton.frame)+20, _goodsButton.frame.origin.y, 50, 34);
    
    [_severButton setTitle:nameArray[1] forState:UIControlStateNormal];
    [_severButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _severButton.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    _indexImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_severButton.frame)-_severButton.frame.size.width+10, CGRectGetMaxY(_severButton.frame)-7, 25, 12)];
    _indexImage2.image = [UIImage imageNamed:@"切换.png"];
    
    [iv addSubview:_indexImage1];
    [iv addSubview:_indexImage2];
    [iv addSubview:_severButton];
    [iv addSubview:_goodsButton];
    
    _severButton.selected = YES;
}

- (void)goodButtonClick:(UIButton *)btn{
    
    _severButton.selected = NO;
    
    _indexImage1.hidden = NO;
    
    
    btn.selected = YES;
    
    if ([self.delegate respondsToSelector:@selector(changeButtonState:)]) {
        
        [self.delegate changeButtonState:YES];
    }
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
