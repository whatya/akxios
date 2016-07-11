//
//  Room.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "Room.h"

@implementation Room

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _currentUser    = [dictionary[currentUserKey] intValue];
        _imageUrl       = dictionary[imageUrlKey];
        _imei           = dictionary[imeiKey];
        
        _isMaster       = [dictionary[isMasterKey] boolValue];
        _isRemind       = [dictionary[isRemindKey] boolValue];
        _realName       = dictionary[realNameKey];
        
        _roomId         = dictionary[roomIdKey];
        _roomName       = dictionary[roomNameKey];
        _introduction   = dictionary[introductionKey];
        _roomType       = [dictionary[roomTypeKey] intValue];
        
        _isSubscription = [dictionary[roomIsSubsKey] boolValue];
    }
    return self;
}


- (NSString *)description
{
    [super description];
    return [NSString stringWithFormat:@"\nCurrentUser  :  %d \n ImageUrl  :  %@ \n Imei  :  %@ \n IsMasger  :  %@ \n IsRemind  :  %@ \n RealName  :  %@ \n RoomId  :  %@ \n RoomName  :  %@  \n Introduction  :  %@  \n",self.currentUser,self.imageUrl,self.imei,self.isMaster ? @"yes" : @"no",self.isRemind ? @"yes": @"no",self.realName,self.roomId,self.roomName,self.introduction];
}

@end
