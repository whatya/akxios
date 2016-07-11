//
//  ServeUserModel.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ServeUserModel.h"

@implementation ServeUserModel


//http://appservice.3chunhui.com/chunhui/m/doctor@getAllDoctor.do

- (instancetype)initFromDictonary:(NSDictionary *)dict{
 
    self = [super init];
    
    if (self) {
        
        _gId =    dict[K_serve_id];
        _image =  dict[K_serve_image];
        _realname = dict[K_serve_realname];
        _major = [dict[K_serve_major]floatValue];
        _username = dict[K_serve_username];
        _userType = [dict[K_serve_userType] floatValue];
        _currentUsers = [dict[K_serve_currentUsers] doubleValue];
        _allUsers = [dict[K_serve_allUsers] doubleValue];
    }
    return self;
}

@end
