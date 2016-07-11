//
//  IconManager.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/9.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconManager : NSObject

- (void)saveImage:(UIImage*)image withImei:(NSString*)imei;
- (UIImage*)imageWithImei:(NSString*)imei;
- (NSString*)imageStringWithImei:(NSString*)imei;

@end
