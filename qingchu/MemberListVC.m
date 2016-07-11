//
//  MemberListVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/28.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "MemberListVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "CommonConstants.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "MemberCell.h"
#import "UIImageView+WebCache.h"
#import "ProgressHUD.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MemberListVC ()<
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *memberList;
@property (nonatomic,strong) NSMutableDictionary *masterModel;
@property (nonatomic,strong) NSDictionary *selectedDictionary;

@end

@implementation MemberListVC

#define MemberCellID @"MemberCell"
#define AvatarTag    1973
#define NameTag      1974

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    if (self.incomingImei.length > 0) {
        
        NSLog(@"%@",self.incomingImei);
        [self fetchRoomInformation];
        
    }else{
        [self fetchRoomMembers];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if(section == 0){
        return 40;
    }else{
        return 20;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [ProgressHUD show:@"转让管理员中..."];
        NSDictionary *selectedModel = self.selectedDictionary;
        NSArray *keys = @[@"user",@"roomId",@"assignToUser"];
        NSArray *values = @[[[NSPublic shareInstance] getUserName],self.roomId,selectedModel[@"username"]];
        
        NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
        NSString *apiString = @"chunhui/m/room@assignMaster.do";
        
        [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
            if (!error) {
                if (IsSuccessful(jsonData)) {
                    [ProgressHUD showSuccess:@"转让成功！"];
                    [self fetchRoomMembers];
                }else{
                    [ProgressHUD showError:@"转让失败！"];
                }
            }else{
                [ProgressHUD showError:@"请求出错！"];
            }
            
        }];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"管理员";
    }else{
        return @"圈成员";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.masterModel) {
            return 1;
        }else{
            return 0;
        }
    }else{
        return self.memberList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MasterCell"];
        UIImageView *imv    = (UIImageView*)[cell viewWithTag:1973];
        UILabel     *label  = (UILabel*)[cell viewWithTag:1974];
        NSString *nameTemp = self.masterModel[@"nickname"];
        if (nameTemp.length > 0) {
            label.text = nameTemp;
        }else{
            label.text = self.masterModel[@"username"];
        }
        
        [imv sd_setImageWithURL:URL(self.masterModel[@"image"]) placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
         AddCornerBorder(imv, imv.bounds.size.width/2, 1, [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1].CGColor);
        
        return cell;
    }else{
        NSDictionary *model = self.memberList[indexPath.row];
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
        cell.indexPath = indexPath;
        NSString *nameTemp = model[@"nickname"];
        if (nameTemp.length > 0) {
            cell.name =  nameTemp;
        }else{
            cell.name = model[@"username"];
        }
        
        UIScrollView *scrollView = (UIScrollView*)[cell viewWithTag:1977];
        
        if ([[[NSPublic shareInstance] getUserName] isEqualToString:self.masterModel[@"username"]]) {
            scrollView.scrollEnabled = YES;
        }else{
            scrollView.scrollEnabled = NO;
        }
        
        cell.imageUrl = model[@"image"];
        
        __block MemberCell *blockCell = cell;
        
        cell.transfer = ^(NSIndexPath *indexPath){
            
            if (indexPath.section == 1 && [[[NSPublic shareInstance] getUserName] isEqualToString:self.masterModel[@"username"]]) {
                
                self.selectedDictionary = self.memberList[indexPath.row];
                [self.tableView reloadInputViews];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认转让管理员？"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
                [blockCell closeMenu];
                [alert show];
            }

        };
        cell.remove   = ^(NSIndexPath *indexPath){
            [blockCell closeMenu];
            if (indexPath.section == 1 && [[[NSPublic shareInstance] getUserName] isEqualToString:self.masterModel[@"username"]]){
                self.selectedDictionary = self.memberList[indexPath.row];
                [self removeMember];
            }
        };
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)fetchRoomMembers
{
    [ProgressHUD show:@"获取成员列表中..."];
    self.memberList = [NSMutableArray new];
    NSArray *keys = @[@"user",@"roomId"];
    NSArray *values = @[[[NSPublic shareInstance] getUserName],self.roomId];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@getMembersByRoomId.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            if (IsSuccessful(jsonData)) {
                NSArray *roomMembers = jsonData[@"data"];
                for (NSDictionary *dic in roomMembers){
                    if ([dic[@"isMaster"] boolValue]) {
                        //是管理员
                        self.masterModel = [dic mutableCopy];
                    }else{
                        //非管理员
                        [self.memberList addObject:dic];
                    }
                }
                [self.tableView reloadData];
            }else{
                [ProgressHUD showError:ErrorString(jsonData)];
            }
        }else{
            [ProgressHUD showError:@"请求出错！"];
        }
        
        }];
}

- (void)removeMember
{
    [ProgressHUD show:@"删除成员中..."];
    NSArray *keys = @[@"user",@"roomId",@"userId"];
    NSArray *values = @[[[NSPublic shareInstance] getUserName],self.roomId,self.selectedDictionary[@"id"]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@deleteRoomMember.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD dismiss];
                [self fetchRoomMembers];
            }else{
                [ProgressHUD showError:ErrorString(jsonData)];
            }
        }else{
            [ProgressHUD showError:@"请求出错！"];
        }
        
    }];

}

- (void)fetchRoomInformation
{
    NSArray *keys = @[@"user",@"imei"];
    NSArray *values = @[[[NSPublic shareInstance] getUserName],self.incomingImei];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@getRoomInfoByImei.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            if (IsSuccessful(jsonData)) {
                NSDictionary *room = jsonData[@"data"];
                NSString *roomId = room[@"roomId"];
                self.roomId = roomId;
                [self fetchRoomMembers];
                
            }else{
                [ProgressHUD showError:ErrorString(jsonData)];
            }
        }else{
            [ProgressHUD showError:@"请求出错！"];
        }
        
    }];

}

@end
