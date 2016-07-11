//
//  MessageService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//


#import "HttpManager.h"
#import "AppDelegate.h"
#import "CommonConstants.h"
#import "Base64.h"
#import "TCPManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSUserDefaults+Util.h"
#import "SDImageCache.h"
#import "MessageService.h"

@interface MessageService()

@end

@implementation MessageService

#define debug 1



#pragma mark- 通过原始数据保存消息
- (void)saveMessageFromRowValues:(NSArray *)rowValues notifiy:(BOOL)shouldNotify{ ShowLog

    if (rowValues.count >= 9) {
        //打印原始数据
        for (int i = 0; i < rowValues.count; i++) {
            NSLog(@"%@ : %d------>%@",[self typeOfIndex:i],i,rowValues[i]);
        }
        
        //数据验证
        if (!([rowValues[2] isKindOfClass:[NSString class]] &&
            [rowValues[4] isKindOfClass:[NSNumber class]] &&
            [rowValues[5] isKindOfClass:[NSNumber class]] &&
            [rowValues[6] isKindOfClass:[NSString class]] &&
            [rowValues[7] isKindOfClass:[NSString class]])&&
            [rowValues[8] isKindOfClass:[NSString class]]) {
            NSLog(@"数据格式有误！");
            return;
        }
       
        
        //1、保存消息对象 －－》增加会话消息条数－－》通知界面
    
        Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.coreDataHelper.context];
        int messageType = [rowValues[4] intValue];
        //消息类型为文本、语音、 图片
        if (messageType == 1 || messageType == 2 || messageType == 3) {
            newMessage.senderId = rowValues[2];
            newMessage.type     = rowValues[4];
            newMessage.content  = rowValues[6];
            newMessage.roomId   = rowValues[7];
            newMessage.date     = [self msecToDate:rowValues[8]];
            //语音数据需保存语音长度
            if (messageType == 2) {
                newMessage.length   = rowValues[5];
            }
        }
        else if(messageType >= 4 && messageType <= 10){
            //type:消息类型，其中4代表一般系统系统，5代表有亲友关注，6代表网页链接消息，7代表修改了自己的昵称，8代表修改了圈名称，9代表更换管理员，10代表解除绑定
            //message：推送的消息内容，如果类型是6，消息格式为“标题^简介^url
            newMessage.senderId = rowValues[2];
            newMessage.type     = rowValues[4];
            newMessage.content  = rowValues[6];
            newMessage.roomId   = rowValues[7];
            newMessage.date     = [self msecToDate:rowValues[8]];
        }
        else{
            return;
        }
        
        //修改群信息、不用保存和提示
        if (messageType == 7 || messageType == 8) {
            [[SDImageCache sharedImageCache] cleanDisk];
            [[SDImageCache sharedImageCache] clearMemory];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RoomInformationUpdated" object:newMessage];
            return;
        }
        
        //2、增加消息条数
        [self addConversationCountWithRoomId:newMessage.roomId];
        
        if (shouldNotify) {
            //3、通知界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewIncomingMessage" object:newMessage];
            NSLog(@"已发送通知");
            if (![NSUserDefaults shouldRoomRemind:newMessage.roomId]) {
                AudioServicesPlaySystemSound(1007);
            }
        }
        
    }
}

#pragma mark- 数据类型
- (NSString*)typeOfIndex:(int)index
{
    NSArray *array  = [[self class] attributies];
    if (index < array.count) {
        return array[index];
    }else{
        return @"";
    }
}

+ (NSArray*)attributies
{
    return @[@"命令类型",@"附带整数",@"发送账号",@"占位数据",@"命令类型",@"语音长度",@"真实数据",@"房间账号",@"消息时间"];
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)savePendingMessagesFromRowValues:(NSArray *)rowValues
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    
    if (rowValues.count < 8) {
        NSLog(@"数据数组错误！");
        return;
    }
    
    dispatch_async(kBgQueue, ^{
        NSArray *values2 = [rowValues[2] componentsSeparatedByString:@"$"];//发送者id ——》2  string
        NSArray *values3 = [rowValues[3] componentsSeparatedByString:@"$"];//消息类型 ——》4   int
        NSArray *values4 = [rowValues[4] componentsSeparatedByString:@"$"];//语音长度 ——》5   int
        NSArray *values5 = [rowValues[5] componentsSeparatedByString:@"$"];//消息内容 ——》6   string
        NSArray *values6 = [rowValues[6] componentsSeparatedByString:@"$"];//房间id  ——》7   string
        NSArray *values7 = [rowValues[7] componentsSeparatedByString:@"$"];//消息时间 ——》8   string
        
        for (int i = 0; i < values2.count; i++) {
            NSMutableArray *unitValues = [NSMutableArray arrayWithArray:@[@(13),@(0),@"",
                                                                          @"",@(0),@(0),
                                                                          @"",@"",@""]];
            
            if ((values2.count > i && [values2[i] isKindOfClass:[NSString class]])) {
                 unitValues[2] = values2[i];
            }else{
                continue;
            }
            
            //--------------------------------------------------------------------------------------------------------------------------
            //消息类型 int
            if (values3.count > i) {
                unitValues[4] = @([values3[i] intValue]);
            }else{
                continue;
            }
            
            
            //--------------------------------------------------------------------------------------------------------------------------
            //消息长度 int
            if (values4.count > i) {
                unitValues[5] = @([values4[i] intValue]);
            }else{
                continue;
            }
            
            //--------------------------------------------------------------------------------------------------------------------------
            //消息内容
            if ((values5.count > i &&[values5[i] isKindOfClass:[NSString class]])) {
                unitValues[6] = values5[i];
            }else{
                continue;
            }
            
            
            //--------------------------------------------------------------------------------------------------------------------------
            //房间id
            if ((values6.count > i && [values6[i] isKindOfClass:[NSString class]])) {
                unitValues[7] = values6[i];
            }else{
                continue;
            }
            
            //--------------------------------------------------------------------------------------------------------------------------
            //消息时间
            
            if ((values7.count > i && [values7[i] isKindOfClass:[NSString class]])) {
                unitValues[8] = values7[i];
            }else{
                continue;
            }
            
            //--------------------------------------------------------------------------------------------------------------------------
            [self saveMessageFromRowValues:unitValues notifiy:NO];
        }
        [self.coreDataHelper saveContext];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingMessagesReceived" object:nil];
        AudioServicesPlaySystemSound(1007);
    });
    
    
}


#pragma mark- 保存头像和用户名
- (void)saveAvatar:(NSDictionary*)dictionary
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    //根据id查询该用户头像是否存在
    NSString *senderId = dictionary[@"senderId"];
    NSString *username = dictionary[@"username"];
    NSString *imageUrl = dictionary[@"imageUrl"];
    //根据用户id查询头像
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Avatar"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"userId" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"userId == %@",senderId];
    [request setPredicate:filter];
    NSArray *avatars = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    if (avatars.count == 0) {
        Avatar *avatar = [NSEntityDescription insertNewObjectForEntityForName:@"Avatar" inManagedObjectContext:self.coreDataHelper.context];
        avatar.userId = senderId;
        avatar.userName = username;
        avatar.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    }
}

#pragma mark- 根据会话id获取会话
- (NSArray*)messagesWithConversationId:(NSString*)conversationId  pageIndex:(int)index rowsLimit:(int)limit;
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    //1、获取会话数组 －－ 》2、未读数目清零 －－ 》3、返回会话数组
    
    //1、获取会话数组
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sort]];
    
     [request setFetchOffset:index];
    [request setFetchLimit:limit];
   
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"roomId == %@",conversationId];
    [request setPredicate:filter];
    NSArray *messages = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    
    if (messages.count > 0) {
        //2、未读数清零
        [self clearCountWithConverationId:conversationId];
        
        //3、返回数组
        return [messages sortedArrayUsingComparator:^NSComparisonResult(Message *obj1, Message  *obj2) {
            return [obj1.date compare:obj2.date];
        }];
    }else{
        return nil;
    }
}

#pragma mark- 会话数增加
- (void)addConversationCountWithRoomId:(NSString*)roomId
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"conversationId" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"conversationId == %@",roomId];
    [request setPredicate:filter];
    NSArray *conversations = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    
    if (conversations.count > 0) {
        //如果会话存在id增加
        Conversation *conversation = [conversations firstObject];
        conversation.unreadCount = @([conversation.unreadCount intValue] + 1);
    }else{
        //如果不存在就插入一条会话信息
        Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:self.coreDataHelper.context];
        conversation.unreadCount = @(1);
        conversation.conversationId = roomId;
    }
    
  //  [self.coreDataHelper saveContext];
}

#pragma mark- 根据会话id获取未读条数
- (int)unReadCountWithRoomId:(NSString*)roomId
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"conversationId" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"conversationId == %@",roomId];
    [request setPredicate:filter];
    NSArray *conversations = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    
    if (conversations.count > 0) {
        Conversation *conversation = [conversations firstObject];
        return [conversation.unreadCount intValue];
    }else{
        return 0;
    }
}

#pragma mark- 获取所有未读信息条目
- (NSArray*)allUnreadInfors
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSArray *conversations = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    return conversations;
}

#pragma mark- 会话未读数清零
- (void)clearCountWithConverationId:(NSString*)conversationId
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"conversationId" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"conversationId == %@",conversationId];
    [request setPredicate:filter];
    NSArray *conversations = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    if (conversations.count > 0) {
        Conversation *conversation = [conversations firstObject];
        conversation.unreadCount = @(0);
    }
}


#pragma mark- 保存发送了到消息
- (void)saveSentMessage:(NSArray *)sentMessage{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    //1、保存到本地 －－ 》2、发送到服务器
    
    //1、保存到本地
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.coreDataHelper.context];
    newMessage.content  = sentMessage[0];
    newMessage.date     = sentMessage[1];
    newMessage.length   = sentMessage[2];
    newMessage.roomId   = sentMessage[3];
    newMessage.senderId = sentMessage[4];
    newMessage.type     = sentMessage[5];
    
    //2、发送到服务器
    if ([newMessage.type intValue] == 1) {
        [[TCPManager sharedInstance] sendText:newMessage.content roomId:newMessage.roomId senderId:newMessage.senderId];
    }else if ([newMessage.type intValue] == 3){
        [[TCPManager sharedInstance] sendImageString:newMessage.content roomId:newMessage.roomId senderId:newMessage.senderId];
    }else if ([newMessage.type intValue] ==2){
        [[TCPManager sharedInstance] sendAudioString:newMessage.content audioLenth:[newMessage.length intValue] roomId:newMessage.roomId senderId:newMessage.senderId];
    }
}

#pragma mark- 获取coredata工具类
- (CoreDataHelper *)coreDataHelper
{
    if (!_coreDataHelper) {
        _coreDataHelper = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).coreDataHelper;
    }
    return _coreDataHelper;
}

#pragma mark- 根据id删除消息
- (void)deleteMessagesWith:(NSString*)roomId
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    //1、获取会话数组 －－ 》2、清楚数组
    
    //1、获取会话数组
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];

    NSPredicate *filter = [NSPredicate predicateWithFormat:@"roomId == %@",roomId];
    [request setPredicate:filter];
    NSArray *messages = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    
    if (messages.count > 0) {
        for (NSManagedObject *managedObject in messages) {
            [self.coreDataHelper.context deleteObject:managedObject];
        }
        
        [self.coreDataHelper saveContext];
    }

}

#pragma mark- 将毫秒转为时间
- (NSDate*)msecToDate:(NSString*)sectionsString
{
    long long time = [sectionsString longLongValue];
    return [NSDate dateWithTimeIntervalSince1970: time /1000.0];
}

@end
