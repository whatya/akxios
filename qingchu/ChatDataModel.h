//
//  ChatDataModel.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "JSQMessages.h"
#import "MessageService.h"

typedef void(^Complete)(NSError *error);

@interface ChatDataModel : NSObject

@property (nonatomic,strong) NSMutableArray *roomMembers;

@property (strong, nonatomic) NSMutableArray *messages;//消息数组

@property (strong, nonatomic) NSMutableDictionary *avatars;//头像数组

@property (strong, nonatomic) NSDictionary *users;//用户名数组

@property (strong, nonatomic) NSMutableDictionary *avatarUrls;//头像url地址

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;//发送者气泡

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;//接收者气泡

@property (strong, nonatomic) MessageService *messageService;//消息服务类

 //保存不同类型的消息


//根据群id和用户id获取群成员列表
- (void)fetchRoomMembersWithRoomId:(NSString*)roomId
                         andUserId:(NSString*)userId
                        firstFetch:(BOOL)isFirstFetch
                         pageIndex:(int)index
                         rowsLimit:(int)limit
                       completaion:(Complete)callback;

@end
