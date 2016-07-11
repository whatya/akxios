//
//  Room.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define currentUserKey      @"currentUser"
#define introductionKey     @"description"
#define imageUrlKey         @"image"
#define imeiKey             @"imei"

#define isMasterKey         @"isMaster"
#define isRemindKey         @"isRemind"
#define realNameKey         @"realname"
#define roomIdKey           @"roomId"

#define roomNameKey         @"roomName"
#define roomTypeKey         @"roomType"
#define roomIsSubsKey       @"isSubscription"


@interface Room : NSObject

@property(nonatomic) int    currentUser;
@property(nonatomic,strong) NSString *introduction;
@property(nonatomic,strong) NSString *imageUrl;
@property(nonatomic,strong) NSString *imei;

@property(nonatomic) BOOL   isMaster;
@property(nonatomic) BOOL   isRemind;
@property(nonatomic,strong) NSString *realName;
@property(nonatomic,strong) NSString *roomId;

@property(nonatomic,strong) NSString *roomName;
@property(nonatomic,assign) int roomType;
@property(nonatomic,assign) BOOL isSubscription;
@property(nonatomic) int unreadCount;

- (id)initFromDictionary:(NSDictionary*)dictionary;

@end
