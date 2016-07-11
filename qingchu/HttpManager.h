//
//  HttpManager.h
//  Aitu
//
//  Created by 张宝 on 15-4-23.
//  Copyright (c) 2015年 zhangbao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonConstants.h"

typedef void(^CallbackWithJsonData)(id jsonData,NSError *error);

@interface HttpManager : NSObject

+ (HttpManager*)sharedHttpManager;

- (void)jsonDataFromServerWithBaseUrl:(NSString *)baseUrl
                               portID:(int)port
                          queryString:(NSString *)queryString
                             callBack:(CallbackWithJsonData)callBack;

- (void)jsonDataFromServerWithqueryString:(NSString *)queryString
                                 callBack:(CallbackWithJsonData)callBack;

- (NSString*)joinKeys:(NSArray*)keys withValues:(NSArray*)values;
@end
