//
//  MessageService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message+CoreDataProperties.h"
#import "Avatar+CoreDataProperties.h"
#import "Conversation+CoreDataProperties.h"
#import "CoreDataHelper.h"


#define NewMessageReceived @"NewMessageReceived"

@interface MessageService : NSObject

@property (nonatomic,strong) CoreDataHelper *coreDataHelper;

- (void)saveSentMessage:(NSArray *)sentMessage;

- (void)saveMessageFromRowValues:(NSArray*)rowValues notifiy:(BOOL)shouldNotify;

- (NSArray*)messagesWithConversationId:(NSString*)conversationId  pageIndex:(int)index rowsLimit:(int)limit;

- (int)unReadCountWithRoomId:(NSString*)roomId;

- (NSArray*)allUnreadInfors;

- (void)clearCountWithConverationId:(NSString*)conversationId;

- (void)savePendingMessagesFromRowValues:(NSArray *)rowValues;

- (void)deleteMessagesWith:(NSString*)roomId;

@end
