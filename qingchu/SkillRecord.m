//
//  SkillRecord.m
//  qingchu
//
//  Created by 张宝 on 16/7/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillRecord.h"
#import "CommonConstants.h"

@implementation SkillRecord

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _content = dictionary[k_skillrecord_content];
        _SRId = dictionary[k_skillrecord_id];
        _imgs = dictionary[k_skillrecord_imgs];
        _createTime = dictionary[k_skillrecord_createTime];
        _headImg = dictionary[k_skillrecord_headImg];
        _location = dictionary[k_skillrecord_location];
        _realname = dictionary[k_skillrecord_realname];
    }
    return self;
}

#define HeightPadding 120
- (void)calculateContentHeight
{
    NSDictionary *textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
    CGFloat width = Screen_Width - 16;
    CGSize size = [self.content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttr context:nil].size;
    _contentHeight = size.height + HeightPadding;
}

@end
