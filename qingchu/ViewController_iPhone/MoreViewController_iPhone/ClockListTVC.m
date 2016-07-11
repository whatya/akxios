//
//  ClockListTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/7.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "ClockListTVC.h"
#import "HttpManager.h"
#import "NSPublic.h"
#import "ProgressHUD.h"
#import "Clock.h"
#import "ClockCell.h"

@interface ClockListTVC ()<UIAlertViewDelegate>

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) Clock *tobeDeletedClock;

@end

@implementation ClockListTVC

#define CellID @"ClockCell"

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.dataSource = [NSMutableArray new];
    [self fetchClockList];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show clock detail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Clock *model = self.dataSource[indexPath.row];
        [segue.destinationViewController setValue:model forKey:@"clock"];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClockCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    Clock *model = self.dataSource[indexPath.row];
    cell.model = model;
    [cell setClockOff:^(Clock* clock,BOOL isOn){
        [self closeClock:clock with:isOn];
    }];
    
    [cell setDelClock:^(Clock* clock){
        [self deleteClock:clock];
    }];
    
    return cell;
}

#pragma mark- 打开/关闭闹钟
- (void)toogleClock:(Clock*)clock flag:(BOOL)isOn
{
    [ProgressHUD show:@"更改闹钟..." Interaction:YES];
    NSString *url = @"chunhui/m/terminal@updateClockSwitch.do";
    NSString *queryString = [NSString stringWithFormat:@"id=%@&isValid=%@",clock.cid,isOn ? @"1":@"0"];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (jsonData) {
            NSString *status = jsonData[@"status"];
            if ([status isEqualToString:@"0"]) {
                [ProgressHUD showSuccess:@"更改成功！" Interaction:YES];
                }else{
                [ProgressHUD showError:@"更改失败！" Interaction:YES];
            }
        }else{
            [ProgressHUD showError:@"网络错误！" Interaction:YES];
        }
        
    }];

}

#pragma mark- 移除闹钟
- (void)removeClock:(Clock*)clock
{
    [ProgressHUD show:@"删除闹钟中..." Interaction:YES];
    NSString *url = @"chunhui/m/terminal@deleteClock.do";
    NSString *queryString = [NSString stringWithFormat:@"id=%@",clock.cid];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (jsonData) {
            NSString *status = jsonData[@"status"];
            if ([status isEqualToString:@"0"]) {
                [ProgressHUD dismiss];
                NSInteger index = [self.dataSource indexOfObject:clock];
                [self.dataSource removeObject:clock];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
                self.tobeDeletedClock = nil;
              
            }else{
                [ProgressHUD showError:@"删除失败！" Interaction:YES];
            }
        }else{
            [ProgressHUD showError:@"网络错误！" Interaction:YES];
        }
        
    }];

}


#pragma mark- 获取闹钟列表
- (void)fetchClockList
{
    [ProgressHUD show:@"获取闹钟中..." Interaction:YES];
    NSString *url = @"chunhui/m/terminal@getClockSetting.do";
    NSString *imei = [[NSPublic shareInstance] getImei];
    NSString *queryString = [NSString stringWithFormat:@"imei=%@",imei];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (jsonData) {
            NSString *status = jsonData[@"status"];
            if ([status isEqualToString:@"0"]) {
                
                NSArray *clocks = jsonData[@"data"];
                for (NSDictionary *dictionary in clocks){
                    Clock *clock = [[Clock alloc] initFromDictionary:dictionary];
                    [self.dataSource addObject:clock];
                }
                [self.tableView reloadData];
            }else{
                [ProgressHUD showError:@"失败！" Interaction:YES];
            }
        }else{
            [ProgressHUD showError:@"网络错误！" Interaction:YES];
        }
        
    }];
}

- (void)closeClock:(Clock*)clock with:(BOOL)flag
{
    NSLog(@"%@ %@",clock.clockTime,flag ? @"开" : @"关");
    clock.isValid = flag ? @"1" : @"0";
    [self toogleClock:clock flag:flag];
}

- (void)deleteClock:(Clock*)clock
{
    self.tobeDeletedClock = clock;
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"删除闹钟！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [deleteAlert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeClock:self.tobeDeletedClock];
    }
}

@end
