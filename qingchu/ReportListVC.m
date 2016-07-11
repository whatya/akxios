//
//  ReportListVC.m
//  qingchu
//
//  Created by caoguochi on 16/5/3.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ReportListVC.h"
#import "ProgressHUD.h"
#import "HttpManager.h"
#import "NSPublic.h"

@interface TipModel : NSObject
@property(nonatomic,strong) NSString *content;
@property(nonatomic,assign) CGFloat height;
@property(nonatomic,strong) NSString *date;
@end

@implementation TipModel


@end

@interface ReportListVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSMutableArray *tips;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ReportListVC

#define CellID @"TipCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tips = [NSMutableArray new];
    [self fetchTips];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TipModel *tip = self.tips[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    UILabel *timeLabel    = [cell viewWithTag:1973];
    UITextView *tv        = [cell viewWithTag:1974];
    timeLabel.text = tip.date;
    tv.text = tip.content;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 350;
}

- (void)fetchTips
{
    [ProgressHUD show:@"获取中..."];
    NSString *user = [[NSPublic shareInstance] getUserName];
    NSString *userId = [[NSPublic shareInstance] getUserId];
    
    NSArray *keys = @[@"user",@"userid",@"pagesize",@"pagenum"];
    NSArray *values = @[user?:@"",userId?:@"",@"0",@"100"];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/doctor@getDiagnosisList.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                [self makeData:jsonData[@"data"]];
                [self.tableView reloadData];
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}


- (void)makeData:(NSArray*)tipsDic
{
    for (NSDictionary *tempDic in tipsDic){
        NSString *text = @"";
        text = [text stringByAppendingString:[NSString stringWithFormat:@"运动建议:%@\n\n",tempDic[@"stepadvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"心率建议:%@\n\n",tempDic[@"pulseadvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"血压建议:%@\n\n",tempDic[@"bloodadvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"睡眠建议:%@\n\n",tempDic[@"sleepadvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"血糖建议:%@\n\n",tempDic[@"sugaradvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"心理建议:%@\n\n",tempDic[@"mindadvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"饮食建议:%@\n\n",tempDic[@"drinkadvice"]]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"总       评:%@\n\n",tempDic[@"sumadvice"]]];
        TipModel *model = [[TipModel alloc] init];
        model.content = text;
        NSString *dateString = tempDic[@"updatetime"];
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        inputFormatter.dateFormat = @"yyyyMMddHHmmss";
        NSDate *inpuDate = [inputFormatter dateFromString:dateString];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
        NSString *outputString = [outputFormatter stringFromDate:inpuDate];
        model.date = outputString;
        [self.tips addObject:model];
    }
    
    
}

@end
