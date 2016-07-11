//
//  MessageListManager.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/31.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageListManager : NSObject
- (void)appendMessage:(NSDictionary*)message toImei:(NSString*)imei withSender:(NSString*)sender;
- (NSMutableArray*)jsonFromJsonFile:(NSString*)jsonFileName;

- (void)fetchNewMessage:(NSDictionary*)params;

@end
