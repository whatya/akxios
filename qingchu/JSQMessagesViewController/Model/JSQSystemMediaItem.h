//
//  JSQSystemMediaItem.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "JSQMediaItem.h"

@interface JSQSystemMediaItem : JSQMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

@property (copy, nonatomic) NSString *contentUrl;
@property (copy, nonatomic) NSString *contentTitle;
@property (copy, nonatomic) NSString *content;

- (instancetype) initWithContentUrl:(NSString*)url contentTitle:(NSString*)title contentText:(NSString*)content;

@end
