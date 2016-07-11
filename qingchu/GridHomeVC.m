//
//  GridHomeVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/24.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "GridHomeVC.h"
#import "CommonConstants.h"
#import "NSPublic.h"
#import "Base64.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "RootViewController.h"
#import "CHTermUser.h"
#import "FocusPersonModel.h"
#import "DataPublic.h"
#import "MyMD5.H"
#import "TCPManager.h"
#import "ChatVC.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "NSUserDefaults+Util.h"
#import "V2LoginTVC.h"
#import "SettingTVC.h"

#define ThisRedColor  [UIColor colorWithRed:233/255.0 green:59/255.0 blue:60/255.0 alpha:1]
#define ThisGrayColor [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]

@interface GridHomeVC ()

@property (weak, nonatomic) IBOutlet UIButton *userIcon;
@property (weak, nonatomic) IBOutlet UIView *circleBackView;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeLB;
@property (weak, nonatomic) IBOutlet UILabel *deepTimeLB;
@property (weak, nonatomic) IBOutlet UIImageView *qualityIMV;

@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;

@property (weak, nonatomic) IBOutlet UIButton *rightArrow;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *backViews;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *paperPlaneBtn;

@property (weak, nonatomic) IBOutlet UIImageView *weatherIMV;
@property (weak, nonatomic) IBOutlet UILabel *weatherLB;
@property (weak, nonatomic) IBOutlet UILabel *locationLB;
@property (weak, nonatomic) IBOutlet UIButton *powerIMV;

@property (weak, nonatomic) IBOutlet UIView *sleepContainerView;
@property (weak, nonatomic) IBOutlet UIView *heartRateContainerView;

@property (weak, nonatomic) IBOutlet UILabel *heartRateLB;
@property (weak, nonatomic) IBOutlet UILabel *stepLB;
@property (weak, nonatomic) IBOutlet UILabel *heartRateDateLB;
@property (weak, nonatomic) IBOutlet UILabel *stepDateLB;

@property (weak, nonatomic) IBOutlet UILabel *heartRateLB2;
@property (weak, nonatomic) IBOutlet UILabel *stepLB2;
@property (weak, nonatomic) IBOutlet UILabel *heartRateDateLB2;
@property (weak, nonatomic) IBOutlet UILabel *stepDateLB2;


@property (weak, nonatomic) IBOutlet UIImageView *pinnerIMV;
@property (weak, nonatomic) IBOutlet UIScrollView *runningHourseView;
@property (weak, nonatomic) IBOutlet UIImageView *oemHomeBgImage;
@property (weak, nonatomic) IBOutlet UINavigationItem *oemTitle;

@property (strong, nonatomic) NSMutableArray *focusPersonArray;
@property (strong, nonatomic) NSMutableArray *imeisArray;
@property (weak, nonatomic) IBOutlet UIView *circleCoverView;
@property (weak, nonatomic) IBOutlet UIView *offWatchBannerView;

@end

@implementation GridHomeVC

/**
 *  控制器生命周期
 *
 *  @return
 */
#pragma mark- vc 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.offWatchBannerView.hidden = YES;
    AddCornerBorder(self.offWatchBannerView, self.offWatchBannerView.height/2, 0, nil);
    //设置透明导航栏
    AddCornerBorder(self.circleCoverView, self.circleBackView.bounds.size.width/2, 0, nil);
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    //清除图片缓存
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    
    if ([self isLogined]) {
        
        //判断是否是略过登录界面，直接进主界面
        BOOL loginDerectly = [FromUserDefaults(@"LoginDerectly") boolValue];
        if (loginDerectly) {
            //如果是，说明没有登录服务器，需要执行登录操作
            [self loginToServer];
        }else{
            //如果不是，说明是从登录界面跳转过来，不需要执行登录操作，获取用户名密码，登录消息服务器即可
            NSString *username = [[NSPublic shareInstance] getUserName];
            NSString *password = [MyMD5 md5:[[NSPublic shareInstance] getPwd]];
            [[TCPManager sharedInstance] loginWithUsername:username andPwd:password];
            //获取并处理关注人列表
            [self setupRelativesArray];
            //初始化界面
            [self makeUI];
        }

    }
    
    //启动页面中间的跑马灯动画
    [self hourseRun];
}



/**
 *  跑马灯效果，实现思路，移动视图的x坐标，当x等于整个视图的宽度时，将x设置为起始点坐标，实现无限循环
 */
- (void)hourseRun
{
    CGPoint orignalPoint = self.runningHourseView.contentOffset;
    
    if (orignalPoint.x == Screen_Width *2) {
        [self.runningHourseView setContentOffset:CGPointMake(0.5, 0)];
    }else{
        CGPoint newPoint = CGPointMake(orignalPoint.x + 0.5, 0);
        [self.runningHourseView setContentOffset:newPoint];
    }
    
    __weak GridHomeVC *weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self hourseRun];
    });
}


/**
 *  登录http服务器，然后登录tcp消息服务器
 */
- (void)loginToServer
{
    [ProgressHUD show:@"登录中..." Interaction:YES];
    NSString *username = [[NSPublic shareInstance] getUserName];
    NSString *password = [[NSPublic shareInstance] getPwd];
    
    NSArray *keys = @[@"user",@"pwd",@"regid",@"apikey",@"secretkey",@"devicetype"];
    NSArray *values = @[username ?: @"",
                        [MyMD5 md5:password] ?: @"",
                        [[NSPublic shareInstance] getUserTXId] ?: @"" ,
                        @"9085bca5773959465f5c933c",
                        @"2330451c7921a0e5c9ed1f92",
                        @"4"];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@login.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                //登录成功后登录tcp消息服务器
                
//                UIImageView *homgBgImg = (UIImageView*)[self.view viewWithTag:100];
                
                NSString *imgString = jsonData[@"data"][@"oem"][@"oemLoginBgImage"];
                NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithString:imgString]];
                _oemHomeBgImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
                
                NSString *titleString = jsonData[@"data"][@"oem"][@"oemTitle"];
                
                _oemTitle.title = titleString;
                
                [self loginSucceed];
                NSString *username = [[NSPublic shareInstance] getUserName];
                NSString *password = [MyMD5 md5:[[NSPublic shareInstance] getPwd]];
                [[TCPManager sharedInstance] loginWithUsername:username andPwd:password];

            }else{
                
                //登录失败，跳转到登录界面
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
                UIViewController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
                self.view.window.rootViewController = VC;
                [self.view.window makeKeyAndVisible];
            }
        }else{
            
            //如果是服务器或者网络原因导致登录失败，同样跳转到登录界面
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
            
            UIViewController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
            self.view.window.rootViewController = VC;
            [self.view.window makeKeyAndVisible];
        }
    }];
    
}


/**
 *  登录成功后执行的操作
 */
- (void)loginSucceed
{
    //2.获取亲人信息
    [ProgressHUD show:@"获取亲人中..." Interaction:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSString *relativesInfo = [[DataPublic shareInstance]getRelativesInfo];
        [[DataPublic shareInstance]getSettingInfo];
        [[DataPublic shareInstance] getUserInfo];
        //如果没有亲人信息，跳着到添加亲人绑定页面：
        if ([relativesInfo isEqualToString:@"1"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
                self.nameLB.text = @"快去绑定手表吧！";
                [self.userIcon setImage:[UIImage imageNamed:@"defaultLu"] forState:UIControlStateNormal];
                //                [ProgressHUD dismiss];
                //                [[Alert sharedAlert] showMessage:@"还没有绑定亲人喔！" okTitle:@"去绑定亲人" action:^{
                //                    PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
                //                }];
            });
        }else{//如果有亲人信息，存储亲人信息，并跳转到首页
            //如果之前关注过亲人，直接跳转到首页
            NSString *focusedImei = [[NSUserDefaults standardUserDefaults] objectForKey:@"focusedPersionImei"];
            if (focusedImei) {
                NSArray *relatives = [[NSPublic shareInstance] getTermUserArray];
                
                //如果之前选择过亲人，设置该亲人为当前选择的亲人
                for (CHTermUser *termUser  in relatives){
                    if ([focusedImei isEqualToString:termUser.imei]) {
                        [[NSPublic shareInstance]setImei:termUser.imei];
                        [[NSPublic shareInstance]setname:termUser.name];
                        [[NSPublic shareInstance]setrelative:termUser.relative];
                        [[NSPublic shareInstance]setsim:termUser.sim];
                        [[NSPublic shareInstance]setsex:termUser.sex];
                        [[NSPublic shareInstance]setimage:termUser.image];
                        break;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupRelativesArray];
                    [self makeUI];
                });
                
            }else{ //如果没有选择过亲人，跳转到亲人列表选择页面
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"More", @"FocusListVC");
                });
                
            }
        }
        
    });
    
}


- (void)viewDidLayoutSubviews
{
    AddCornerBorder(self.userIcon, self.userIcon.bounds.size.width/2, 0, NULL);
    AddCornerBorder(self.circleBackView, self.circleBackView.bounds.size.width/2, 0, NULL);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //格子菜单选中bug
    for (UIView *view in self.backViews){
        view.backgroundColor = [UIColor whiteColor];
    }
}


#pragma mark- 初始化界面
- (void)makeUI
{
    //35开头的为儿童手表，不能发送消息给儿童手表
    if ([[[NSPublic shareInstance] getImei] hasPrefix:@"35"]){
        self.paperPlaneBtn.enabled = NO;
    }else{
        self.paperPlaneBtn.enabled = YES;
    }
    
    [self.userIcon sd_setBackgroundImageWithURL:[NSURL URLWithString:[[NSPublic shareInstance] getimage]]
                                       forState:UIControlStateNormal
                               placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
    
    NSString *nameTemp = [[NSPublic shareInstance] getname];
    if (nameTemp.length > 0) {
        self.nameLB.text = nameTemp;
    }else{
        self.nameLB.text = [[NSPublic shareInstance] getrelative];
    }
    
    //获取睡眠和天气信息
    [self fetchSleepData];
    [self fetchWeatherPowerAndLBS];
    
    if([[NSPublic shareInstance] getTermUserArray].count == 0){
        self.nameLB.text = @"快去绑定手表吧！";
        [self.userIcon setImage:[UIImage imageNamed:@"defaultLu"] forState:UIControlStateNormal];
        
    }
}



#pragma mark- Targe Actions
#pragma mark- -----消息发送1


- (IBAction)sendSth:(UIBarButtonItem *)sender {
    
    if (![self isLogined]) {
        [self presentLoginVC];
        return;
    }

        NSString *imeiTemp = [[NSPublic shareInstance] getImei];
        if (imeiTemp.length > 0) {
            RootViewController *chatVC = [[RootViewController alloc] init];
            chatVC.incomingImei = [[NSPublic shareInstance] getImei];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
            [nav.navigationBar setBarTintColor:ThisRedColor];
            [self presentViewController:nav animated:YES completion:NULL];
        }
    
}

- (void)showMessageVC
{
    RootViewController *chatVC = [[RootViewController alloc] init];
    NSString *imeiTemp = [[NSPublic shareInstance] getImei];
    if (imeiTemp.length > 0) {
        chatVC.incomingImei = [[NSPublic shareInstance] getImei];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
        [nav.navigationBar setBarTintColor:ThisRedColor];
        [self presentViewController:nav animated:NO completion:NULL];
    }
}

#pragma mark- -----导航到健康2、亲友圈3、定位4、健康报表5、健康报警6、我的7

- (IBAction)gridIconBtnTouchd:(UIButton *)sender
{
    
    [self navigateTo:(int)sender.superview.tag withParameters:nil animation:YES];
}

- (IBAction)gridUp:(UIButton *)sender {
    sender.superview.backgroundColor = [UIColor whiteColor];
    [self navigateTo:(int)sender.superview.tag withParameters:nil animation:YES];
}
- (IBAction)gridDown:(UIButton *)sender {
    
    for (UIView *view in self.backViews){
        view.backgroundColor = [UIColor whiteColor]; 
    }
    
    sender.superview.backgroundColor = ThisGrayColor;
}

#pragma mark- -----切换联系人 left:1973 riht:1974
- (IBAction)switchRelatives:(UIButton *)sender
{
    self.offWatchBannerView.hidden = YES;
    FocusPersonModel *model = nil;
    ToUserDefaults(@"leftSeconds", @(0));
    if (sender.tag == 1973) {
        model = [self preModelOfImei:[[NSPublic shareInstance] getImei]];
    }else{
        model = [self nexModelOfImei:[[NSPublic shareInstance] getImei]];
    }
    
    if (model) {
        CHTermUser *termUser = model.user;
        [[NSPublic shareInstance]setImei:termUser.imei];
        [[NSPublic shareInstance]setname:termUser.name];
        [[NSPublic shareInstance]setrelative:termUser.relative];
        [[NSPublic shareInstance]setsim:termUser.sim];
        [[NSPublic shareInstance]setsex:termUser.sex];
        [[NSPublic shareInstance]setimage:termUser.image];
        [[NSPublic shareInstance]setUserId:termUser.userId];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:termUser.imei forKey:@"focusedPersionImei"];
        [userDefaults synchronize];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DataPublic shareInstance] getSettingInfo];
        });
        
        [self makeUI];

    }
}

- (void)toImei:(NSString*)imei
{
    FocusPersonModel *model = [self modelOfImei:imei];
    if (model) {
        CHTermUser *termUser = model.user;
        [[NSPublic shareInstance]setImei:termUser.imei];
        [[NSPublic shareInstance]setname:termUser.name];
        [[NSPublic shareInstance]setrelative:termUser.relative];
        [[NSPublic shareInstance]setsim:termUser.sim];
        [[NSPublic shareInstance]setsex:termUser.sex];
        [[NSPublic shareInstance]setimage:termUser.image];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:termUser.imei forKey:@"focusedPersionImei"];
        [userDefaults synchronize];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DataPublic shareInstance] getSettingInfo];
        });
        
        [self makeUI];

    }
}

- (IBAction)widerSwitch:(UITapGestureRecognizer *)sender
{
    UIButton *temp = [[UIButton alloc] init];
    if (sender.view.tag == 1975) {
        temp.tag = 1973;
        [self switchRelatives:temp];
    }else{
        temp.tag = 1974;
        [self switchRelatives:temp];
    }
    
}


#pragma mark- -----联系人列表
- (IBAction)relativeList:(UIButton *)sender
{
    if (![self isLogined]) {
        [self presentLoginVC];
        return;
    }
    
    if ([[NSPublic shareInstance] getTermUserArray].count == 0) {
        PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
    }else{
        UINavigationController *nav =VCFromStoryboard(@"More", @"FocusListNav");
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    }
}

#pragma mark- -----添加关注人
- (IBAction)addRelative:(UIBarButtonItem *)sender {
    
    if (![self isLogined]) {
        [self presentLoginVC];
        return;
    }
    
    if ([[NSPublic shareInstance] getTermUserArray].count < 5){
        PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
    }else{
        [ProgressHUD showError:@"最多只能绑定5个亲人！"];
        return;
    }
    
    
}

- (IBAction)toMapVC:(UITapGestureRecognizer *)sender
{
    [self navigateTo:4 withParameters:nil animation:YES];
}

- (void)presentLoginVC
{
    UINavigationController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
    V2LoginTVC *loginVC = VC.viewControllers.firstObject;
    loginVC.shouldShowBackBtn = YES;
    [self presentViewController:VC animated:YES completion:NULL];
}

#pragma mark- 工具方法
#pragma mark- -----导航到下级 健康2、亲友圈3、定位4、健康报表5、健康报警6、我的7
- (void)navigateTo:(int)index withParameters:(NSDictionary*)dictionary animation:(BOOL)animate
{

    if (![self isLogined] && index != 6) {
        [self presentLoginVC];
        return;
    }
    
    
    FocusPersonModel *model = [self modelOfImei:[[NSPublic shareInstance]getImei]];
    //[self toHeartVC:dictionary animation:animate];
    
    
    switch (index) {
        case 2:
            if (self.focusPersonArray.count > 0) {
                PUSH(@"Home", @"MixVC", nil, dictionary, YES);
            }else{
                PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
            }
            
            break;
        case 3:
            if (self.focusPersonArray.count > 0) {
                PUSH(@"Relatives", @"RelativeListVC", @"亲友圈", @{},animate);
            }else{
                PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
            }
           
            break;
        case 4:
            
            if (self.focusPersonArray.count > 0) {
                PUSH(@"Main", @"MapVC", @"周边", @{@"isMaster" : @(model.user.isMaster)}, YES);
            }else{
                PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
            }
            
            
            break;
        case 5:
            
            if (self.focusPersonArray.count > 0) {
                PUSH(@"Home", @"NoteListVC", @"消息通知", @{},animate);
            }else{
                PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
            }
            
            
            break;
        case 6:
           
            PUSH(@"Mall", @"MallsVC", @"", @{},animate);
        
            break;
        case 7:
        
            
           PUSH(@"More", @"SettingTVC", @"设置", @{},animate);
            
            break;
            
        default:
            break;
    }
}

- (void)toHeartVC:(NSDictionary*)dictionary animation:(BOOL)animate
{
    NSDictionary *param = nil;
    if (!dictionary) {
        if (![[NSPublic shareInstance] getImei]) {return;}
        param = @{@"mesuredPulse":@{@"imei":[[NSPublic shareInstance]getImei],@"name":[[NSPublic shareInstance]getname]}};
        
    }else{
        NSMutableDictionary *tempDic = [dictionary[@"mesuredPulse"] mutableCopy];
        if ([tempDic[@"imei"] isEqualToString:[[NSPublic shareInstance]getImei]]) {
            tempDic[@"name"] = [[NSPublic shareInstance] getname];
        }else{
            FocusPersonModel *model = [self modelOfImei:dictionary[@"imei"]];
            tempDic[@"name"] = model.user.name;
        }
        param = @{@"mesuredPulse":tempDic};
    }
    PUSH(@"Home", @"HeartRateVC",nil, param,animate);
}


#pragma mark- 网络请求，获取健康数据
- (void)fetchSleepData
{
    [self.flower startAnimating];
    NSString *imei = [[NSPublic shareInstance] getImei];
    NSString *dateString = [[NSPublic shareInstance] getDate:0];
    NSArray *keys = @[@"imei",@"date"];
    
    if (!imei || !dateString) {
        return;
    }
    
    NSArray *values = @[imei,dateString];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/data@getHealthData.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [self.flower stopAnimating];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [self formatData:jsonData];
            }else{
                [self clearSleepUI];
                [self clearHealthUI];
            }
        }else{
            [self clearSleepUI];
            [self clearHealthUI];
        }
    }];

}


- (void)clearHealthUI
{
    self.stepDateLB.text = @"";
    self.stepDateLB2.text = @"";
    
    self.heartRateDateLB.text = @"";
    self.heartRateDateLB2.text = @"";
    
    self.heartRateLB.text = @"0";
    self.heartRateLB2.text = @"0";
    
    self.stepLB.text = @"0";
    self.stepLB2.text = @"0";
}

#pragma mark- 网路请求，获取天气、电量、lbs数据
- (void)fetchWeatherPowerAndLBS
{
    NSString *imei = [[NSPublic shareInstance] getImei];
    NSArray *keys = @[@"imei"];
    
    if (!imei) {
        return;
    }
    
    NSArray *values = @[imei];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/data@getTerminalCurInfo.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [self.flower stopAnimating];
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [self formatWeatherPowerLBS:jsonData];
            }else{
                [self clearWPLUI];
            }
        }else{
            [self clearWPLUI];
        }
    }];
}


- (void)saveLastValidLocation:(NSDictionary*)data
{
    if ([data isKindOfClass:[NSDictionary class]]) {
        
        NSString *imei    = [[NSPublic shareInstance] getImei];
        NSString *address = data[@"address"];
        NSString *lat     = [NSString stringWithFormat:@"%@",data[@"lbslat"]];
        NSString *lon     = [NSString stringWithFormat:@"%@",data[@"lbslon"]];
        NSString *receTime= data[@"receivetime"];
        
        if (address.length > 0 && lat.length > 0 && lon.length > 0 && receTime.length > 0 && imei.length > 0) {
            
            NSString *point = [NSString stringWithFormat:@"{%@,%@}",lat,lon];
            NSDictionary *placeData = @{@"imei"         : imei,
                                        @"addressText"  : address,
                                        @"place"        : point,
                                        @"receivetime"  : receTime};
            
            [NSUserDefaults saveLastPlace:placeData forImei:imei];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    }
}


#pragma mark- 更新天气、定位、电量到界面
- (void)formatWeatherPowerLBS:(NSDictionary*)jsonData
{
    if (![jsonData isKindOfClass:[NSDictionary class]]) {return;}
    
    NSDictionary *data = jsonData[@"data"];
    
    if (![data isKindOfClass:[NSDictionary class]]) {return;}
    
    [self saveLastValidLocation:data];
    
    //处理位置信息
    NSString *originalAddress = data[@"address"];
    if (originalAddress.length == 0) {
        [self clearWPLUI];
        return;
    }
    NSArray *addrParts = [originalAddress componentsSeparatedByString:@" "];
    int partsCount = (int)addrParts.count;
    NSString *validAddress = @"";
    if (partsCount >= 2) {
        NSString *part1 = addrParts[partsCount-2];
        //NSString *part2 = addrParts[partsCount-1];
        validAddress = [NSString stringWithFormat:@"%@",part1];
    }
    self.locationLB.text = validAddress;
    self.pinnerIMV.alpha = 1;
    
//处理电量信息
    int orignalPower = [data[@"power"] intValue];
    float powerRate    = orignalPower/100.0;
    NSString *validPowerImageName = @"power0";
    if (powerRate == 0) {
        validPowerImageName = @"power0";
    }else if (powerRate > 0 && powerRate <= 0.25){
        validPowerImageName = @"power1";
    }else if (powerRate > 0.25 && powerRate <= 0.5){
        validPowerImageName = @"power2";
    }else if (powerRate > 0.5 && powerRate <= 0.75){
        validPowerImageName = @"power3";
    }else if (powerRate > 0.75 && powerRate <= 1){
        validPowerImageName = @"power4";
    }
    [self.powerIMV setImage:[UIImage imageNamed:validPowerImageName] forState:UIControlStateNormal];
    
    
    //处理天气信息
    NSDictionary *weatherDic =  data[@"weatherInfo"];
    NSString *weatherIconUrl =  weatherDic[@"icon"];
    NSString *minTemp        =  [weatherDic[@"minTemp"] isKindOfClass:[NSString class]] ? weatherDic[@"minTemp"] : @"";
    NSString *maxTemp        =  [weatherDic[@"maxTemp"] isKindOfClass:[NSString class]] ? weatherDic[@"maxTemp"] : @"";
    NSString *weatherText    =  [weatherDic[@"weather"] isKindOfClass:[NSString class]] ? weatherDic[@"weather"] : @"";
    [self.weatherIMV sd_setImageWithURL:URL(weatherIconUrl)];
    if (minTemp.length > 0 && maxTemp.length > 0 && weatherText.length > 0) {
        self.weatherLB.text = [NSString stringWithFormat:@"%@°/%@° %@",minTemp,maxTemp,weatherText];
    }else{
        self.weatherLB.text = @"";
    }
    
    
    
}

- (NSString*)formateDateString:(NSString*)inputString
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[NSLocale currentLocale]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate* inputDate = [inputFormatter dateFromString:inputString];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"MM月dd日 HH:mm:ss"];
    return [outputFormatter stringFromDate:inputDate];
}

- (void)clearSleepUI
{
    self.sleepTimeLB.attributedText = nil;
    self.deepTimeLB.attributedText = nil;
    self.noDataView.hidden = NO;
}

- (void)clearWPLUI
{
    self.offWatchBannerView.hidden = NO;
    self.weatherIMV.image = nil;
    self.pinnerIMV.alpha = 0;
    self.weatherLB.text = @"";
    self.locationLB.text = @"";
    [self.powerIMV setImage:nil forState:UIControlStateNormal];
}

#pragma mark- -----格式化数据到界面
- (void)formatData:(NSDictionary*)jsonData
{
    
    
    NSDictionary *dataDictionary = jsonData[@"data"];
    
    if (![dataDictionary isKindOfClass:[NSDictionary class]]) { return; }
    
    NSString *deepTime   =   dataDictionary[@"deepTime"];
    NSString *sleepTime  =   dataDictionary[@"sleepTime"];
    NSString *quality    =   dataDictionary[@"quality"];
    
    int pulse            =   [dataDictionary[@"pulse"] intValue];
    NSString *pulseTime  =   [self formateDateString:dataDictionary[@"pulseTime"]];
    int totalStep        =   [dataDictionary[@"totalStep"] intValue];
    NSString *stepTime   =   [self formateDateString:dataDictionary[@"stepTime"]];
    
    //处理睡眠信息
    if (deepTime.length == 0) {
        [self clearSleepUI];
    }else{
        self.noDataView.hidden = YES;
        NSString *sleepTemp = sleepTime;
        sleepTemp = [[sleepTemp stringByReplacingOccurrencesOfString:@":" withString:@"h"] stringByAppendingString:@"'"];
        NSMutableAttributedString *sleepAttr = [[NSMutableAttributedString alloc] initWithString:sleepTemp];
        [sleepAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:24]} range:NSMakeRange(0, sleepTemp.length)];
        [sleepAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16]} range:[sleepTemp rangeOfString:@"h"]];
        self.sleepTimeLB.attributedText = sleepAttr;
        
        NSString *deepTemp = deepTime;
        deepTemp = [[deepTemp stringByReplacingOccurrencesOfString:@":" withString:@"h"] stringByAppendingString:@"'"];
        NSMutableAttributedString *deepAttr = [[NSMutableAttributedString alloc] initWithString:deepTemp];
        [deepAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:24]} range:NSMakeRange(0, deepTemp.length)];
        [deepAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16]} range:[deepTemp rangeOfString:@"h"]];
        self.deepTimeLB.attributedText = deepAttr;
        
        //home_sleep_1 良好，home_sleep_2 尚可 home_sleep_3 较差
        if ([quality isEqualToString:@"良好"]) {
            self.qualityIMV.image = [UIImage imageNamed:@"home_sleep_1"];
        }else if ([quality isEqualToString:@"尚可"]){
            self.qualityIMV.image = [UIImage imageNamed:@"home_sleep_2"];
        }else{
            self.qualityIMV.image = [UIImage imageNamed:@"home_sleep_3"];
        }
    }

    //处理心率、计步信息
    self.heartRateLB.text = [NSString stringWithFormat:@"%d",pulse];
    self.stepLB.text = [NSString stringWithFormat:@"%d",totalStep];
    self.heartRateDateLB.text = pulseTime;
    self.stepDateLB.text = stepTime;
    
    self.heartRateLB2.text = [NSString stringWithFormat:@"%d",pulse];
    self.stepLB2.text = [NSString stringWithFormat:@"%d",totalStep];
    self.heartRateDateLB2.text = pulseTime;
    self.stepDateLB2.text = stepTime;
   }


#pragma mark- 获取亲人列表
- (void)setupRelativesArray
{
    NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];
    if (termUsers.count > 0) {
        self.focusPersonArray = [NSMutableArray arrayWithCapacity:termUsers.count];
        self.imeisArray = [NSMutableArray arrayWithCapacity:termUsers.count];
        for (CHTermUser *termUser in termUsers) {
            FocusPersonModel *model = [[FocusPersonModel alloc] init];
            model.user = termUser;
            [self.focusPersonArray addObject:model];
            [self.imeisArray addObject:termUser.imei];
        }
        
        if (self.imeisArray.count > 1) {
            self.leftArrow.hidden = NO;
            self.rightArrow.hidden = NO;
        }else{
            self.leftArrow.hidden = YES;
            self.rightArrow.hidden = YES;
        }
    }
}

- (FocusPersonModel*)modelOfImei:(NSString*)imei
{
    NSInteger currentIndex = [self.imeisArray indexOfObject:imei];
    if (self.focusPersonArray.count > currentIndex ) {
        return self.focusPersonArray[currentIndex];
    }else{
        return nil;
    }
}

- (FocusPersonModel*)preModelOfImei:(NSString*)imei
{
    NSInteger currentIndex = [self.imeisArray indexOfObject:imei];
    NSInteger preIndex = currentIndex - 1;
    if (preIndex >= 0 && preIndex < self.focusPersonArray.count) {
        return self.focusPersonArray[preIndex];
    }else{
        return self.focusPersonArray[self.focusPersonArray.count-1];
    }
}

- (FocusPersonModel*)nexModelOfImei:(NSString*)imei
{
    NSInteger currentIndex = [self.imeisArray indexOfObject:imei];
    NSInteger preIndex = currentIndex + 1;
    if (preIndex >= 0 && preIndex < self.focusPersonArray.count) {
        return self.focusPersonArray[preIndex];
    }else{
        return self.focusPersonArray[0];
    }
}

- (BOOL)isLogined
{
    NSString *username = [[NSPublic shareInstance]getUserName];
    return username.length > 0;
}

@end
