 
//  AppDelegate.m
//  OTT

//  Created by wangsong on 13-7-25.
//  Copyright (c) 2013年 whtriples. All rights reserved.
//

#import "AppDelegate.h"
#import "ProgressHUD.h"
#import "GlobalDefine.h" 
#import "tooles.h"
#import "NSPublic.h" 
#import "ACPReminder.h"
#import "APService.h"
#import "UIView+Toast.h"
#import "NSPublic.h"
#import "MessageListManager.h"
#import "CommonConstants.h"
#import "GridHomeVC.h"
#import "HeartRateVC.h"
#import "BloodPressureVC.h"
#import "MyMD5.h"
#import "HttpManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "TCPManager.h"
#import "ProgressHUD.h"
#import "WXApiManager.h"
#import "SDImageCache.h"
#import <AlipaySDK/AlipaySDK.h>

#define SUPPORT_IOS8 1

@interface AppDelegate ()

@property (nonatomic,strong) MessageListManager *messageListManager;
@property (nonatomic,strong) NSString *imei;
@property (nonatomic,strong) NSTimer *heartBeatTimer;
@property (nonatomic,strong) NSTimer *streamKeeperTimer;

@end

@implementation AppDelegate

# define debug 1

#pragma mark- tcp登录
- (void)login
{
    [[TCPManager sharedInstance] loginWithUsername:nil andPwd:nil];
}

#pragma mark- 发送心跳包
- (void)sendHeartBeat
{
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    NSLog(@"发送心跳包！");
    [[TCPManager sharedInstance] heartBeat];
}

#pragma mark- tcp连接
- (void)checkTCPConnection
{
    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    TCPManager *manager = [TCPManager sharedInstance];
    NSStreamStatus inputStreamStatus    = manager.inputStream.streamStatus;
    NSStreamStatus outputStreamStatus   = manager.outputStream.streamStatus;
    
    if (inputStreamStatus == NSStreamStatusNotOpen || inputStreamStatus == NSStreamStatusClosed || inputStreamStatus == NSStreamStatusError ||
        outputStreamStatus == NSStreamStatusNotOpen || outputStreamStatus == NSStreamStatusClosed || outputStreamStatus == NSStreamStatusError) {
        NSLog(@"连接断开，开始重连！");
        [[TCPManager sharedInstance] initNetworkCommunication];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[TCPManager sharedInstance] loginWithUsername:nil andPwd:nil];
        });
    }else{
        NSLog(@"连接保持中...");
    }
}

#pragma mark- 初始化coredata
- (CoreDataHelper *)cdh
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreCata];
    }
    return _coreDataHelper;
}


#pragma mark- 处理链接回调
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
           // int status = [resultDic[@"resultStatus"] intValue];
            //if (status == 9000) {
           // NSLog(@"********************************************************************pay successed!****************************************************************");
            //}
        }];
        return YES;
    }
    
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}



NSDictionary *dict;

#pragma mark- 应用启动
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
  //  NSString *banben = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [TCPManager sharedInstance].IPAddress = TcpServerIP;   //设置tcp地址和端口号
    [TCPManager sharedInstance].portNumber = 8080;
    [[TCPManager sharedInstance] initNetworkCommunication]; //建立连接
    //初始化定时器维护连接
    self.streamKeeperTimer  = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkTCPConnection) userInfo:nil repeats:YES];
    self.heartBeatTimer     = [NSTimer scheduledTimerWithTimeInterval:240 target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
    [self.streamKeeperTimer fire];
    [self.streamKeeperTimer fire];
    
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotJsonData:) name:@"Received json data" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"Commond error" object:nil];
    
    //向微信注册
    [WXApi registerApp:@"wxa316902ccb966706" withDescription:@""];

    self.messageListManager = [[MessageListManager alloc] init];
    
    //界面设置
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName]=[UIColor whiteColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:textAttrs];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //判断是否首次使用，如果是，进入介绍页面
    NSString *firstLogin = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstLogin"];
    if (!firstLogin) {
        ToUserDefaults(@"EULA", @(YES));
        UIStoryboard *main = [UIStoryboard storyboardWithName:@"AppEntrance" bundle:nil];
        UIViewController *pageVC = [main instantiateViewControllerWithIdentifier:@"InitialPageVC"];
        self.window.rootViewController = pageVC;
    }else{
        
//        BOOL autoLogin = [FromUserDefaults(@"shouldAutoLogin") boolValue];
//        BOOL accounSaved = [FromUserDefaults(@"shouldSavePassword") boolValue];
//        if (autoLogin && accounSaved) {
//            
            ToUserDefaults(@"LoginDerectly", @(YES));
            self.window.rootViewController = VCFromStoryboard(@"Home", @"GridHomeNav");
            [self.window makeKeyAndVisible];
//        }else{
//            UIViewController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
//            self.window.rootViewController = VC;
//            [self.window makeKeyAndVisible];
//        }
    }



    //极光推送配置
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(//UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(//UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    

    // Required
    [APService setupWithOption:launchOptions];
    [self initMessageInfo];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


#pragma mark- 极光配置
-(void)initMessageInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
    
}

- (void)networkDidSetup:(NSNotification *)notification { NSLog(@"已连接"); }

- (void)networkDidClose:(NSNotification *)notification { NSLog(@"未连接"); }

- (void)networkDidRegister:(NSNotification *)notification { NSLog(@"%@", [notification userInfo]); NSLog(@"已注册");}

- (void)networkDidLogin:(NSNotification *)notification {
    
    NSLog(@"已登录");
    NSLog(@"%@", [NSString stringWithFormat:@"[APService registrationID]: %@", [APService registrationID]]);
    [[NSPublic shareInstance]setUserTXId:[APService registrationID]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[self cdh] saveContext];
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

#if SUPPORT_IOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{ 
    [application registerForRemoteNotifications];
}
#endif


#pragma mark 移除本地通知，在不需要此通知时记得移除
-(void)removeNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [APService handleRemoteNotification:userInfo];
 
}


#pragma mark- 处理远程通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSString *messageContent =[userInfo objectForKey:@"content"];
    
    NSData *jsonData = [messageContent dataUsingEncoding:NSUTF8StringEncoding];
    
    dict=[NSJSONSerialization JSONObjectWithData:jsonData
                             options:NSJSONReadingMutableLeaves
                             error:nil];
  
    NSString *title  =  [userInfo  objectForKey:@"title"];
    NSString *status0 =  [dict  objectForKey:@"status"];

 
    if ([status0 isEqualToString:@"-15"]) {
       [self.window.rootViewController.view makeToast:@"(>_<)手表不在线喔！" duration:1.0  position:CSToastPositionCenter ];
    }
   
    
    if ([title isEqualToString:@"心率"] || [title isEqualToString:@"心率报警"])
    {
        saveAlarmNote(userInfo);
        ToUserDefaults(@"leftSeconds", @(0));
        [self showNoteListVC];
    }
    
    
    if ([title isEqualToString:@"定位"] || [title isEqualToString:@"定位报警"])
    {
        saveAlarmNote(userInfo);
        [self showNoteListVC];

    }

    if ([title isEqualToString:@"血压报警"])
    {
        saveAlarmNote(userInfo);
        [self showNoteListVC];

    }
    
    if ([title isEqualToString:@"消息回复"]) {
        [self.messageListManager fetchNewMessage:dict[@"data"]];
        
        dispatch_after(2, dispatch_get_main_queue(), ^{
            UINavigationController *nav = VCFromStoryboard(@"Home", @"GridHomeNav");;
            GridHomeVC *home = [nav.viewControllers firstObject];
            self.window.rootViewController = nav;
            [home showMessageVC];
            
        });
    }
    
    if ([title isEqualToString:@"每日安康信"]) {
        saveDailyAkx(userInfo);
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
}

- (void)showNoteListVC{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UINavigationController *nav = VCFromStoryboard(@"Home", @"GridHomeNav");;
        self.window.rootViewController = nav;
        UIViewController *noteListVC = VCFromStoryboard(@"Home", @"NoteListVC");
        [nav pushViewController:noteListVC animated:YES];
        
    });

}

#pragma mark- TCP通知
- (void)gotJsonData:(NSNotification*)notification
{
    AudioServicesPlaySystemSound(1007);
    
    GridHomeVC *homeVC = nil;
    
    UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
    
    if ([nav isKindOfClass:[UINavigationController class]]) {
        
        for (UIViewController* vc in nav.viewControllers){
            if ([vc isKindOfClass:[GridHomeVC class]]) {
                homeVC = (GridHomeVC*)vc;
            }
        }
    }
    
    NSDictionary *userInfo = [notification object];
    
    dict = [userInfo objectForKey:@"content"];
    
    NSString *title  =  [userInfo  objectForKey:@"title"];
    NSString *status0 =  [dict  objectForKey:@"status"];
    
    if ([status0 isEqualToString:@"-2"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [ProgressHUD showError:@"您但账户在其他设备登录！" Interaction:YES];
            
            dispatch_after(1, dispatch_get_main_queue(), ^{
                [NSPublic shareInstance].isFromExitPage = YES;
                [[TCPManager sharedInstance] loginOut];
                [TCPManager sharedInstance].username = nil;
                [TCPManager sharedInstance].passwrod = nil;
                UIViewController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
                self.window.rootViewController = VC;
            });

        });
    }
    
    
    if ([status0 isEqualToString:@"-15"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.window.rootViewController.view makeToast:@"(>_<)手表不在线喔！" duration:1.0  position:CSToastPositionCenter ];
            [ProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"watch offline" object:nil];
        });
        
        return;
    }
    
    
    if ([title hasPrefix:@"心率"])
    {
        
        saveAlarmNote(userInfo);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            ToUserDefaults(@"leftSeconds", @(0));
            NSString *name = userInfo[@"description"];
            name = [name stringByReplacingOccurrencesOfString:@"收到" withString:@""];
            name = [name stringByReplacingOccurrencesOfString:@"的心率信息" withString:@""];
            NSMutableDictionary *tempDic = [[dict  objectForKey:@"data"] mutableCopy];
            tempDic[@"name"] = name;
            
            if ([NSPublic shareInstance].vcIndex != 1 ) {
                
                if (homeVC) { [homeVC navigateTo:5 withParameters:@{} animation:YES]; }
                
            }else{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"heartSendNotice" object:tempDic];
            }

            
        });
        
    }
    
    if ([title hasPrefix:@"定位"])
    {
        saveAlarmNote(userInfo);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([NSPublic shareInstance].vcIndex != 2) {
                
                if (homeVC) { [homeVC navigateTo:5 withParameters:@{} animation:YES]; }
                
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"positionNotice" object:[ dict objectForKey:@"data"]];
            }
        });
        
    }
    
    if ([title isEqualToString:@"血压报警"])
    {
        if ([title isEqualToString:@"血压报警"]) {
            saveAlarmNote(userInfo);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([NSPublic shareInstance].vcIndex != 3) {

                if (homeVC) { [homeVC navigateTo:5 withParameters:@{} animation:YES]; }
            
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bloodSendNotice0" object:[ dict  objectForKey:@"data"]];
            }
        
        });
    }
    
    
    
    if ([title isEqualToString:@"消息回复"]) {
        
        [self.messageListManager fetchNewMessage:dict[@"data"]];
        
        dispatch_after(2, dispatch_get_main_queue(), ^{
        
            if ([NSPublic shareInstance].vcIndex != 4) {
        
                if (homeVC) { [homeVC showMessageVC]; }
                
            }
            
        });
    }
    
    if ([title isEqualToString:@"每日安康信"]) {
        saveDailyAkx(userInfo);
    }

}

#pragma mark- app生命周期
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    NSLog(@"-------------------------------------------程序激活 打开tcp连接-------------------------------------------");
    
    [[TCPManager sharedInstance] loginWithUsername:nil andPwd:nil];
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appReactive" object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:APP_BACKFROM_BACKGROUND
                                                        object:self];
    
    
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    [self cdh];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
     NSLog(@"-------------------------------------------程序进入后台 关闭tcp连接-------------------------------------------");
    
    [[TCPManager sharedInstance] loginOut];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [[NSNotificationCenter defaultCenter] postNotificationName:APP_GOTO_BACKGROUND
                                                        object:self];
    [[self cdh] saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[self cdh] saveContext];
}

#pragma mark-存储报警信息

#define AlarmNoteKey @"AlertNoteKey"

void saveAlarmNote(NSDictionary* note)
{
    NSMutableArray *notesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:AlarmNoteKey] mutableCopy];
    if (!notesArray) {
        notesArray = [NSMutableArray new];
    }
    [notesArray addObject:[note mutableCopy]];
    [[NSUserDefaults standardUserDefaults] setObject:notesArray forKey:AlarmNoteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSArray* alarmNotes()
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:AlarmNoteKey];
}

#pragma mark- 存储每日安康信
#define DailyAKXKey @"DailyAkx"

void saveDailyAkx(NSDictionary* akx)
{
    NSMutableArray *akxsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:DailyAKXKey] mutableCopy];
    if (!akxsArray) {
        akxsArray = [NSMutableArray new];
    }
    [akxsArray addObject:[akx mutableCopy]];
    [[NSUserDefaults standardUserDefaults] setObject:akxsArray forKey:DailyAKXKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSArray* dailyAkXs()
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DailyAKXKey];
}



@end
