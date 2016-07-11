//
//  SkillRecordsVC.m
//  qingchu
//
//  Created by 张宝 on 16/7/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillRecordsVC.h"
#import "CommonConstants.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "MJRefresh.h"
#import "SkillRecord.h"
#import "SkillRecordCell.h"
#import "SkillHeader.h"

@interface SkillRecordsVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *skillRecords;
@property (strong,nonatomic) NSMutableArray *comentRecords;
@property (nonatomic,assign) int currentPageNo;

@end

@implementation SkillRecordsVC


#define CellID      @"SkillRecordCell"
#define DateTag     1973
#define ContentTag  1974
#define NameTag     1975

#define PageSize    10

#define AddSegue @"Add log segue"
#define ShowSegue @"Show log segue"

#define TextWidth Screen_Width-72
#define CellHeightPadding 60

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    
}


- (void)initData
{
    self.currentPageNo = 1;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.skillRecords = [NSMutableArray new];
    self.comentRecords = [NSMutableArray new];
    
    [self logsWithID:self.inputOrderID pageNo:self.currentPageNo pageSize:PageSize];
    __weak SkillRecordsVC* weak_self = self;
//    self.tableView.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        NSLog(@"开始刷新");
//        weak_self.currentPageNo += 1;
//        [self logsWithID:self.inputOrderID pageNo:weak_self.currentPageNo pageSize:PageSize];
//        
//    }];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weak_self.currentPageNo = 1;
        [self logsWithID:self.inputOrderID pageNo:0 pageSize:PageSize];
    }];
    
    
}

#define ImgHost @"http://img.3chunhui.com"

- (void)logsWithID:(NSString*)oid pageNo:(int)pageNo pageSize:(int)size
{
    [ProgressHUD show:@"获取记录中..."];
    NSArray *keys = @[@"orderId"];
    NSArray *values = @[oid];// @[@"201607071131237495"];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/comment@getEmployeeComment.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                NSArray *empComents = jsonData[@"data"][@"empComment"];
                NSArray *userComents = jsonData[@"data"][@"userComment"];
                if (empComents.count > 0 || userComents.count > 0) {
                    
                    if (pageNo == 0) {
                        [self.skillRecords removeAllObjects];
                        [self.comentRecords removeAllObjects];
                    }
                    
                    //服务纪录
                    for (NSDictionary *logDic in empComents){
                        SkillRecord *model = [[SkillRecord alloc] initFromDictionary:logDic];
                        //图片地址拼接
                        model.headImg = [ImgHost stringByAppendingString:model.headImg];
                        
                        NSMutableArray *newImgUrls = [NSMutableArray new];
                        for (NSString *url in model.imgs){
                            NSString *newUrl = [ImgHost stringByAppendingString:url];
                            [newImgUrls addObject:newUrl];
                        }
                        model.imgs = newImgUrls;
                        [self.skillRecords addObject:model];
                    }
                    //用户评价
                    for (NSDictionary *logDic in userComents){
                        SkillRecord *model = [[SkillRecord alloc] initFromDictionary:logDic];
                        //图片地址拼接
                        model.headImg = [ImgHost stringByAppendingString:model.headImg];
                        
                        NSMutableArray *newImgUrls = [NSMutableArray new];
                        for (NSString *url in model.imgs){
                            NSString *newUrl = [ImgHost stringByAppendingString:url];
                            [newImgUrls addObject:newUrl];
                        }
                        model.imgs = newImgUrls;
                        [self.comentRecords addObject:model];
                    }
                    
                    //计算高度
                    [self figureOutHeights];
                    //刷新视图
                    [self.tableView reloadData];
                    [self.tableView.mj_footer endRefreshing];
                    if (pageNo == 0) {
                        [self.tableView.mj_header endRefreshing];
                    }
                }else{
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        SkillHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"SkillHeader" owner:self options:nil] lastObject];
        header.headerLB.text = @"服务纪录";
        if (self.skillRecords.count == 0) {
            header.headerLB.text = @"没有服务纪录";
        }
        header.moreBtn.hidden = YES;

        return header;
    }else{
        SkillHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"SkillHeader" owner:self options:nil] lastObject];
        header.headerLB.text = @"用户评价";
        if (self.comentRecords.count == 0) {
            header.headerLB.text = @"没有用户评价";
        }
        header.moreBtn.hidden = YES;

        return header;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.skillRecords.count : self.comentRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SkillRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    NSArray *temp = indexPath.section == 0 ? self.skillRecords : self.comentRecords;
    SkillRecord *model = temp[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark- 高度计算
- (float)contentHeightFor:(NSString*)text
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13]};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(TextWidth, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *temp = indexPath.section == 0 ? self.skillRecords : self.comentRecords;
    SkillRecord *model = temp[indexPath.row];
    return model.contentHeight;
}

- (void)figureOutHeights
{
    for (SkillRecord *model in self.skillRecords){
        
        CGFloat textContentHeight = [self contentHeightFor:model.content]+ 20;
        //计算图片高度
        NSInteger imagesCount = model.imgs.count;
        NSInteger imageHeight = 0;
        if (imagesCount >= 1 && imagesCount <= 3){
            imageHeight = ((TextWidth - 16)/3)+ 8;
        }else if (imagesCount >3 && imagesCount <= 6){
            imageHeight = ((TextWidth - 16)/3)*2 + 16;
        }else if (imagesCount > 6 && imagesCount <= 9){
            imageHeight = ((TextWidth - 16)/3)*3 + 24;
        }else{
            imageHeight = 8;
        }
        
        model.contentHeight = textContentHeight + imageHeight + CellHeightPadding;
    }
    
    for (SkillRecord *model in self.comentRecords){
        
        CGFloat textContentHeight = [self contentHeightFor:model.content]+ 20;
        //计算图片高度
        NSInteger imagesCount = model.imgs.count;
        NSInteger imageHeight = 0;
        if (imagesCount >= 1 && imagesCount <= 3){
            imageHeight = ((TextWidth - 16)/3)+ 8;
        }else if (imagesCount >3 && imagesCount <= 6){
            imageHeight = ((TextWidth - 16)/3)*2 + 16;
        }else if (imagesCount > 6 && imagesCount <= 9){
            imageHeight = ((TextWidth - 16)/3)*3 + 24;
        }else{
            imageHeight = 8;
        }
        
        model.contentHeight = textContentHeight + imageHeight + CellHeightPadding;
    }

}




@end
