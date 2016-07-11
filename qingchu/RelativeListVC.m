//
//  RelativeListVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/13.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "RelativeListVC.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "CommonConstants.h"
#import "Room.h"
#import "WatchCell.h"
#import "ChatVC.h"
#import "Conversation.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MessageService.h"
#import "TCPManager.h"
#import "NSUserDefaults+Util.h"
#import "ProgressHUD.h"
#import "SubscriptionCell.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface RelativeListVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *rooms;
@property (nonatomic, strong) NSMutableArray *subscriptionRooms;
@property (nonatomic, strong) NSMutableDictionary *unreadCountsDictionary;
@property (nonatomic, strong) MessageService *messageService;
@property (nonatomic, assign) BOOL  shouldBeQuiet;

@end

@implementation RelativeListVC

#define RelativeCellID @"RelativeCell"
#define NewsCellID @"FeedCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRooms];

    
    [self.messageService.coreDataHelper saveContext];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:@"NewIncomingMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PendingMessagesReceived) name:@"PendingMessagesReceived" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRooms) name:@"RoomInformationUpdated" object:nil];
    
    
}

- (void)updateRooms
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.rooms.count > 0) {
//            [self.rooms removeAllObjects];
//            [self.tableView reloadData];
//        }
//        [self.tableView clearsContextBeforeDrawing];
//        [self fetchRooms];
//        
//    });
}

- (void)newMessageReceived:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        Message *newMessage = [notification object];
        for (Room *room in self.rooms){
            if ([room.roomId isEqualToString:newMessage.roomId]) {
                NSInteger newIndex = [self.rooms indexOfObject:room];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }

    });
    
    }

- (void)PendingMessagesReceived
{
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.rooms.count > 0) {
            [self.tableView reloadData];
        }
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.shouldBeQuiet = NO;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.shouldBeQuiet = YES;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.rooms.count;
    }else{
        return self.subscriptionRooms.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35;
    }else{
        return 15;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"我的亲友圈";
    }else{
        return @"我的订阅";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:RelativeCellID];
        WatchCell *watchCell = (WatchCell*)cell;
        Room *room = self.rooms[indexPath.row];
        room.unreadCount = [self.unreadCountsDictionary[room.roomId] intValue];
        watchCell.room = room;
        
        watchCell.indexPath = indexPath;
        watchCell.cellTaped = ^(NSIndexPath *cellIndexPath){
            if (self.rooms.count > indexPath.row) {
                Room *room = self.rooms[indexPath.row];
                ChatVC *chatVC = [[ChatVC alloc] init];
                
                chatVC.senderId = [[NSPublic shareInstance] getUserName];
                chatVC.senderDisplayName = [[NSPublic shareInstance] getUserName];
                chatVC.title = room.roomName;
                chatVC.roomId = room.roomId;
                chatVC.room = room;
                
                [self.navigationController pushViewController:chatVC animated:YES];
            }
        };
        watchCell.addBtnClick = ^(NSIndexPath *cellIndexPath){
            Room *room = self.rooms[indexPath.row];
            PUSH(@"Relatives", @"WXShareVC", @"分享", @{@"imei":room.imei}, YES);
        };
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:NewsCellID];
        SubscriptionCell *subscriptionCell = (SubscriptionCell*)cell;
        Room *room = self.subscriptionRooms[indexPath.row];
        room.unreadCount = [self.unreadCountsDictionary[room.roomId] intValue];
        subscriptionCell.room = room;
        
        subscriptionCell.indexPath = indexPath;
        subscriptionCell.cellTaped = ^(NSIndexPath *cellIndexPath){
            if (self.rooms.count > indexPath.row) {
                Room *room = self.subscriptionRooms[indexPath.row];
                ChatVC *chatVC = [[ChatVC alloc] init];
                
                chatVC.senderId = [[NSPublic shareInstance] getUserName];
                chatVC.senderDisplayName = [[NSPublic shareInstance] getUserName];
                chatVC.title = room.roomName;
                chatVC.roomId = room.roomId;
                chatVC.room = room;
                
                [self.navigationController pushViewController:chatVC animated:YES];
            }
        };
        
        subscriptionCell.subscribteClick = ^(NSIndexPath *cellIndexPath){
            Room *room = self.subscriptionRooms[indexPath.row];
            NSString *username = [[NSPublic shareInstance] getUserName];
            [self subscribWithUsername:username andRoomID:room.imei];
            
        };

    }
    return cell;
}

- (void)subscribWithUsername:(NSString*)username andRoomID:(NSString*)roomID
{
    [ProgressHUD show:@"订阅中..."];
    NSArray *keys = @[@"user",@"imei"];
    NSArray *values = @[username,roomID];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@simpleBind.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (!error) {
            
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"订阅成功！"];
                [self fetchRooms];
            }else{
                [ProgressHUD dismiss];
                [[Alert sharedAlert] showMessage:@"您已订阅！"];
            }
        }else{
            [ProgressHUD dismiss];
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
    
}


- (void)fetchRooms
{
    [ProgressHUD show:@"获取亲友圈中..."];
    self.rooms = [NSMutableArray new];
    self.subscriptionRooms = [NSMutableArray new];
    NSArray *keys = @[@"user"];
    NSArray *values = @[[[NSPublic shareInstance] getUserName]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@getMyRooms.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                NSArray *roomDictionaries = jsonData[@"data"];
                if (roomDictionaries.count > 0) {
                    for (NSDictionary *dictionray in roomDictionaries){
                        Room *model = [[Room alloc] initFromDictionary:dictionray];
                        [NSUserDefaults room:model.roomId shouldRemind:model.isRemind];
                        if (model.roomType == 1) {
                            if (model.isMaster) {
                                [self.rooms insertObject:model atIndex:0];
                            }else{
                                [self.rooms addObject:model];
                            }

                        }else{
                            [self.subscriptionRooms addObject:model];
                        }
                        
                    }
                    [self.tableView reloadData];
                }
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];

}

- (MessageService *)messageService
{
    if (!_messageService) {
        _messageService = [[MessageService alloc] init];
    }
    return _messageService;
}

@end

