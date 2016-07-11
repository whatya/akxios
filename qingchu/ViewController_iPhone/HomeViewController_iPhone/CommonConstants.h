//
//  CommonConstants.h
//  Aitu
//
//  Created by 张宝 on 15/6/4.
//  Copyright (c) 2015年 zhangbao. All rights reserved.
//0

#ifndef Aitu_CommonConstants_h
#define Aitu_CommonConstants_h

#import "Alert.h"

#define EnableDevelopment 1

#define HttpServerUrl (EnableDevelopment == 0 ? @"http://121.40.187.136:" : @"http://appservice.3chunhui.com:")
#define TcpServerIP   (EnableDevelopment == 0 ? @"121.40.187.136" : @"msgservice.3chunhui.com")

//log日志
#define ShowLog          NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//布局定义
#define Screen_Width    [UIScreen mainScreen].bounds.size.width
#define Screen_Height   [UIScreen mainScreen].bounds.size.height

//颜色定义
#define YelloColor [UIColor yelloColor]
#define WhiteColor [UIColor whiteColor]
#define RedColor   [UIColor redColor]


//占位图定义
#define PlaceHolderImage [UIImage imageNamed:@"trackHolder"]

//生成NSUrl定义
#define URL(urlString) [NSURL URLWithString:urlString]

//dismiss Modle视图
#define DismissMePlease() [self dismissViewControllerAnimated:YES completion:NULL]

//通知发送
#define ShowBottomBar() [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_BOTTOM_BAR" object:@YES]
#define HideBottomBar() [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_BOTTOM_BAR" object:@NO]
#define ShowLoginPage() [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_LOGIN_PAGE" object:@YES];


//通用字典key
#define StatuKey @"status"
#define MessgeKey @"message"
#define RowsKey @"rows"



//通过storyboard生成控制器
#define VCFromStoryboard(storyboardName,vcName) [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:vcName]

//导航视图相关操作
#define PushWithAnimation(VC) [self.navigationController pushViewController:VC animated:YES] //push到下个控制器

//带参数push到下个控制器
#define PUSH(storyboardName,vcName,vcTitle,paramDictionary,animate){\
UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];\
UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:vcName];\
if (vcTitle) {\
    vc.title = vcTitle;\
}\
if (paramDictionary) {\
    for (NSString *key in paramDictionary.allKeys){\
        [vc setValue:paramDictionary[key] forKey:key];\
    }\
}\
[self.navigationController pushViewController:vc animated:animate];\
}

//给视图添加圆角和边框
#define AddCornerBorder(target,radius,width,cgColor){\
    if (radius > 0) {\
        target.layer.cornerRadius = radius;\
        target.clipsToBounds = YES;\
    }else{\
        target.layer.cornerRadius = 0;\
        target.clipsToBounds = YES;\
    }\
    if (width > 0) {\
        target.layer.borderWidth = width;\
    }else{\
        target.layer.borderWidth = 0;\
    }\
    if (cgColor) {\
        target.layer.borderColor = cgColor;\
    }else{\
        target.layer.borderColor = [UIColor clearColor].CGColor;\
    }\
}


//从userdefaults中获取数据
#define ToUserDefaults(key,value){\
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];\
    [[NSUserDefaults standardUserDefaults] synchronize];\
}

#define FromUserDefaults(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define StringFromNumber(num) [NSString stringWithFormat:@"%d",num]

//是否请求成功
#define IsSuccessful(dictionary) [dictionary[@"status"] intValue] == 0
//错误信息
#define ErrorString(dictionary) dictionary[@"data"]
//数据字典
#define DataDictionary(dictionary) dictionary[@"data"]




#endif
