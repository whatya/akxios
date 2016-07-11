//
//  ServeUserModel.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>


#define K_serve_id               @"id"
#define K_serve_image            @"image"


#define K_serve_realname         @"realname"
#define K_serve_major            @"major"
#define K_serve_userType         @"userType"
#define K_serve_currentUsers     @"currentUsers"

#define K_serve_username         @"username"
#define K_serve_allUsers         @"allUsers"

@interface ServeUserModel : NSObject


@property (nonatomic,strong) NSString  *gId;
@property (nonatomic,strong) NSString  *image;

@property (nonatomic,strong) NSString  *realname;
@property (nonatomic,assign) int       major;
@property (nonatomic,assign) int     userType;
@property (nonatomic,assign) int    currentUsers;
@property (nonatomic,strong) NSString  *username;
@property (nonatomic,assign) double    allUsers;

- (instancetype)initFromDictonary:(NSDictionary *)dict;


@property (nonatomic,strong) NSIndexPath *indexPath;

@end
