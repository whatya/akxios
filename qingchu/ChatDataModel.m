//
//  ChatDataModel.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "ChatDataModel.h"
#import "HttpManager.h"
#import "CommonConstants.h"
#import "Base64.h"
#import "JSQAudioMediaItem.h"
#import "JSQSystemMediaItem.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define debug 1

@interface ChatDataModel ()

@end

@implementation ChatDataModel

#pragma mark- 初始化方法
- (instancetype)init
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    self = [super init];
    if (self) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:232/255.0 green:51/255.0 blue:52/255.0 alpha:1]];
    }
    return self;
}

#pragma mark- 获取群成员列表
- (void)fetchRoomMembersWithRoomId:(NSString*)roomId
                         andUserId:(NSString*)userId
                        firstFetch:(BOOL)isFirstFetch
                         pageIndex:(int)index
                         rowsLimit:(int)limit
                       completaion:(Complete)callback
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    NSLog(@"index : %d  rows: %d",index,limit);
    if (!isFirstFetch) {
        //获取消息并处理
        NSArray *messages = [self.messageService messagesWithConversationId:roomId pageIndex:index rowsLimit:limit];
        NSLog(@"messages : %@",messages);
        
        if (messages.count > 0) {
            [self processMessages:messages];
            [self.messages sortUsingComparator:^NSComparisonResult(Message *obj1, Message *obj2) {
                return [obj1.date compare:obj2.date];
            }];
            callback(nil);
        }else{
            NSError *error = [[NSError alloc] init];
            callback(error);
        }
        
        return;
    }
    
    self.roomMembers = [NSMutableArray new];
    NSArray *keys = @[@"user",@"roomId"];
    NSArray *values = @[userId,roomId];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@getMembersByRoomId.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                NSArray *roomMembers = jsonData[@"data"];
                self.roomMembers = [roomMembers mutableCopy];
                //获取所有头像
                if (roomMembers.count > 0) {
                    NSMutableDictionary *usersTemp = [NSMutableDictionary new];
                    NSMutableDictionary *avatasTemp = [NSMutableDictionary new];
                    NSMutableDictionary *avatarUrlsTemp = [NSMutableDictionary new];
                    
                    for (NSDictionary *memeber in roomMembers){
                        NSString *nicknameTemp = memeber[@"nickname"];
                        NSString *usernameTemp = memeber[@"username"];
                        
                        
                        NSString *avatarUrlStr = memeber[@"image"];
                        avatarUrlsTemp[usernameTemp] = avatarUrlStr;
                        
                        
                        //设置用户昵称，如果昵称为空，就用登录帐号作为用户名
                        NSString *senderDisplayName = nicknameTemp.length > 0 ? nicknameTemp : usernameTemp;
                        usersTemp[usernameTemp] = senderDisplayName;
                        
                        //占位图片
                        JSQMessagesAvatarImage *jsqImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profileUserAvatar"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                        avatasTemp[usernameTemp] = jsqImage;
                    }
                    
                    //8 为系统消息
                    JSQMessagesAvatarImage *jsqSystemImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"shareIcon"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                    avatasTemp[@"system"] = jsqSystemImage;
                    usersTemp[@"system"]  = @"安康护士";
                    
                    //6 为安康护士
                    avatasTemp[@"6"] = jsqSystemImage;
                    usersTemp[@"6"]  = @"安康护士";
                    
                    
                    
                    self.users = usersTemp;
                    self.avatars = avatasTemp;
                    self.avatarUrls = avatarUrlsTemp;
                    
                   //获取消息并处理
                  NSArray *messages = [self.messageService messagesWithConversationId:roomId pageIndex:index rowsLimit:limit];
                [self processMessages:messages];
                callback(nil);
                    
                
                }
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];
}


#pragma mark- 处理消息
- (void)processMessages:(NSArray*)messages{ShowLog

    for (Message *message in messages){
        NSString *displayNameTemp = self.users[message.senderId];
        NSString *displayName = @" ";
        if (displayNameTemp.length > 0) {
            displayName = displayNameTemp;
        }
        int type = [message.type intValue];
        if (type == 1) {
          JSQMessage *textMessage =  [[JSQMessage alloc] initWithSenderId:message.senderId
                                                        senderDisplayName:displayName
                                                                     date:message.date
                                                                     text:message.content];
        [self.messages addObject:textMessage];
        }
        else if (type == 2){
            JSQAudioMediaItem *audioIetm = [[JSQAudioMediaItem alloc] initWithFileURL:[NSURL URLWithString:@""] Duration:message.length];
            audioIetm.status = 3;
            audioIetm.voiceContent = message.content;
            JSQMessage *audioMessage = [[JSQMessage alloc] initWithSenderId:message.senderId senderDisplayName:displayName date:message.date media:audioIetm];
            [self.messages addObject:audioMessage];
        }
        else if (type == 3){
            NSData *photoData = [Base64 decodeString: message.content];
            UIImage *photo = [UIImage imageWithData: photoData];
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
            JSQMessage *photoMessage = [[JSQMessage alloc] initWithSenderId:message.senderId
                                                          senderDisplayName:displayName
                                                                       date:message.date
                                                                      media:photoItem];
        [self.messages addObject:photoMessage];
        }else if (type == 4 ||
                  type == 5 ||
                  type == 6 ||
                  type == 9 ||
                  type == 10){
            //处理积分
            if (type == 6 || [message.content rangeOfString:@"^"].location != NSNotFound) {
                NSString *orignalString = message.content;
                NSArray *strings = [orignalString componentsSeparatedByString:@"^"];
                if (strings.count >= 3) {
                    NSString *title = strings[0];
                    NSString *content = strings[1];
                    NSString *url   = strings[2];
                    JSQSystemMediaItem *systemItem = [[JSQSystemMediaItem alloc] initWithContentUrl:url contentTitle:title contentText:content];
                    JSQMessage *systemMessage = [[JSQMessage alloc] initWithSenderId:message.senderId senderDisplayName:displayName date:message.date media:systemItem];
                    [self.messages addObject:systemMessage];
                }

            }else{
                //系统消息和文本消息相同，只是id 为 system
                JSQMessage *systemTextMessage =  [[JSQMessage alloc] initWithSenderId:message.senderId
                                                                    senderDisplayName:displayName
                                                                                 date:message.date
                                                                                 text:message.content];
                [self.messages addObject:systemTextMessage];

            }
            
        }else{
            //do nothing...
        }
    }
}



#pragma mark- 惰性初始化
- (MessageService *)messageService
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    if (!_messageService) {
        _messageService = [[MessageService alloc] init];
    }
    return _messageService;
}

- (NSMutableArray *)messages
{
    if (!_messages) {
        _messages = [NSMutableArray new];
    }
    return _messages;
}

@end
