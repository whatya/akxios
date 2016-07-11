//
//  SkillRecord.h
//  qingchu
//
//  Created by 张宝 on 16/7/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define k_skillrecord_content       @"content"
#define k_skillrecord_id            @"id"
#define k_skillrecord_imgs          @"imgs"
#define k_skillrecord_createTime    @"createTime"
#define k_skillrecord_headImg       @"headImg"
#define k_skillrecord_location      @"location"
#define k_skillrecord_realname      @"realname"


@interface SkillRecord : NSObject

@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) NSString *SRId;
@property(nonatomic,strong) NSArray  *imgs;
@property(nonatomic,strong) NSString *createTime;
@property(nonatomic,strong) NSString *headImg;
@property(nonatomic,strong) NSString *location;
@property(nonatomic,strong) NSString *realname;
@property(nonatomic,assign) CGFloat  contentHeight;

- (id)initFromDictionary:(NSDictionary*)dictionary;

@end
