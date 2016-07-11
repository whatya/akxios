//
//  Conversation+CoreDataProperties.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *conversationId;
@property (nullable, nonatomic, retain) NSNumber *unreadCount;

@end

NS_ASSUME_NONNULL_END
