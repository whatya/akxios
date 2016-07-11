//
//  MixVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/12/3.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "MixVC.h"
#import "UIViewController+CusomeBackButton.h"
#import "CommonConstants.h"
#import "qingchu-swift.h"
#import "LBHamburgerButton.h"
#import "NSPublic.h"
#import "DataManager.h"
#import "ProgressHUD.h"
#import "CHTermUser.h"
#import "WXApi.h"
#import "WXMediaMessage+messageConstruct.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#define BUFFER_SIZE 1024 * 100

@interface MixVC ()<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *topButtons;
@property (strong, nonatomic) NSArray *childVCS;
@property (assign, nonatomic) int  selectedIndex;
@property (strong, nonatomic) UIButton *gearBtn;
@property (strong, nonatomic) UIView *currentView;
@property (weak,   nonatomic) IBOutlet UIButton *rateBtn;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *menuTopCST;
@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) LBHamburgerButton *buttonHamburgerCloseSmall;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) UIImage *capturedImage;

@end

@implementation MixVC

#define SleepBtn 1973
#define SportBtn 1974
#define HeartBtn 1975
#define BloodBtn 1976
#define SugarBtn 1977

#pragma mark- 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (IBAction)share:(id)sender {
    
    [ProgressHUD show:@"截屏中..."];
    [self buttonPressed:self.buttonHamburgerCloseSmall];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ProgressHUD dismiss];
        UIImage *image = [self captureScreen];
        self.capturedImage = image;
        
        UIActionSheet *shareSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"微信分享"
                                     delegate:self
                                     cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:@"微信好友"
                                     otherButtonTitles:@"朋友圈", nil];
        [shareSheet showInView:self.view];

        
    });
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    
    
            WXImageObject *shareImage = [WXImageObject object];
            shareImage.imageData = UIImageJPEGRepresentation(self.capturedImage, 1);
    
            shareImage.imageUrl = @"https://itunes.apple.com/us/app/an-kang-xin/id990174637?l=zh&ls=1&mt=8";
    
            WXMediaMessage *message = [WXMediaMessage message];
            message.mediaObject = shareImage;
    
            SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                           OrMediaMessage:message
                                                                    bText:NO
                                                                  InScene:(int)buttonIndex];
            [WXApi sendReq:req];
}

- (UIImage *) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark- 界面初始化
- (void)initUI
{
    [self setUpBackButton];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        self.shareBtn.enabled = YES;
    }else{
        self.shareBtn.enabled = NO;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.gearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.gearBtn.frame = CGRectMake(0, 0, 26, 26);
    [self.gearBtn setImage:[UIImage imageNamed:@"Gear"] forState:UIControlStateNormal];
    [self.gearBtn addTarget:self action:@selector(set) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 26, 26);
    [menuBtn setImage:[UIImage imageNamed:@"Hunberger"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    self.buttonHamburgerCloseSmall = [[LBHamburgerButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)
                                                                            withHamburgerType:LBHamburgerButtonTypeCloseButton
                                                                                    lineWidth:20
                                                                                   lineHeight:2
                                                                                  lineSpacing:5
                                                                                   lineCenter:CGPointMake(13, 13)
                                                                                        color:[UIColor whiteColor]];
    
    [self.buttonHamburgerCloseSmall setBackgroundColor:[UIColor clearColor]];
    [self.buttonHamburgerCloseSmall addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.buttonHamburgerCloseSmall],[[UIBarButtonItem alloc] initWithCustomView:self.gearBtn]];
    
    self.menuTopCST.constant = - 40;
}

- (void)buttonPressed:(id)sender {
    LBHamburgerButton* btn = (LBHamburgerButton*)sender;
    [btn switchState];
     self.menuTopCST.constant = self.menuTopCST.constant == 0 ? -40 : 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
    
}

#pragma mark- 数据初始化
- (void)initData
{
    self.dataManager = [[DataManager alloc] init];
    UIViewController* SleepVC = VCFromStoryboard(@"Home", @"SleepVC");
    UIViewController* SportVC = VCFromStoryboard(@"Home", @"SportVC");
    UIViewController* HeartVC = VCFromStoryboard(@"Home", @"HeartRateVC");
    UIViewController* BloodVC = VCFromStoryboard(@"Home", @"BloodPressureVC");
    UIViewController* SugarVC = VCFromStoryboard(@"Home", @"BloodSuarVC");
    
    self.childVCS = @[SleepVC,SportVC,HeartVC,BloodVC,SugarVC];
    
    UIButton *temp = [[UIButton alloc] init];
    if (self.index > 0) {
        temp.tag = SleepBtn + self.index;
    }else{
        temp.tag = HeartBtn;
    }
    
    [self switchVC:temp];
    
}

#pragma mark- 界面初始化
- (IBAction)switchVC:(UIButton *)sender
{
    UIButton *selectedBtn = self.topButtons[sender.tag - SleepBtn];
    if (sender.tag == SleepBtn) {
        self.gearBtn.hidden = YES;
    }else{
        if ([self isMasterOfImei:[[NSPublic shareInstance] getImei]]) {
            self.gearBtn.hidden = NO;
        }else{
            self.gearBtn.hidden = YES;
        }
    }
    self.selectedIndex = (int)sender.tag - SleepBtn;
    UIViewController *selectedVC = self.childVCS[self.selectedIndex];
    
    
    NSLog(@"view bounds : %@",NSStringFromCGSize(self.view.bounds.size));
    NSLog(@"view bounds : %@",NSStringFromCGSize(selectedVC.view.bounds.size));
    
    
    if ([self.view.subviews.firstObject isEqual:selectedVC.view]) {
        return;
    }
    NSLog(@"switched");
    [self allBtnsUnselected];
    [selectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selectedBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    
    if (self.currentView) {
        [self.currentView removeFromSuperview];
        [[self.childViewControllers lastObject] removeFromParentViewController];
    }
    selectedVC.view.frame = self.view.bounds;
    [self.view insertSubview:selectedVC.view atIndex:0];
    self.currentView = selectedVC.view;
    [self addChildViewController:selectedVC];
    [selectedVC didMoveToParentViewController:self];
}

#pragma mark- Top buttons state
- (void)allBtnsUnselected
{
    for (UIButton *btn in self.topButtons){
        [btn setTitleColor:[UIColor colorWithRed:255/255.0 green:161/255.0 blue:148/255.0 alpha:1] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
}

#pragma mark- 点赞
- (IBAction)rate:(id)sender {
    
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],self.selectedIndex)) {
        [ProgressHUD showError:@"您今天已点过赞！" Interaction:YES];
        return;
    }
    
    
    
    [self.dataManager zanWithUser:[[NSPublic shareInstance]getUserName]  imei:[[NSPublic shareInstance]getImei] andType:3 result:^(BOOL status, NSString *error) {
        
        if (status) {
            [ProgressHUD showSuccess:@"点赞成功！" Interaction:YES];
            rate([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],self.selectedIndex);
            [self configureRateButton:self.selectedIndex];
            [self buttonPressed:self.buttonHamburgerCloseSmall];
        }else{
            [ProgressHUD showError:error Interaction:YES];
        }
        
    }];

}

- (IBAction)showBodyData:(UIButton *)sender {
    
    //PUSH(@"Home", @"HealthReportVC", @"健康报表", @{},YES);
    PUSH(@"Home", @"ReportMixVC", @"报告", @{},YES);
    
}

#pragma mark- 配置点赞按钮
- (void)configureRateButton:(int)index
{
    if (doIRated([[NSPublic shareInstance] getUserName], [[NSPublic shareInstance] getImei],index)) {
        [self.rateBtn setImage:[UIImage imageNamed:@"rated"] forState:UIControlStateNormal];
    }else{
        [self.rateBtn setImage:[UIImage imageNamed:@"rate"] forState:UIControlStateNormal];
    }
}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self configureRateButton:selectedIndex];
    [self closeMenuBar];
}

#pragma mark- 关闭下滑菜单
- (void)closeMenuBar
{
    self.menuTopCST.constant = -40;
    [self.buttonHamburgerCloseSmall setState:LBHamburgerButtonStateHamburger];

}

#pragma mark- 设置页面导航
- (void)set
{
    id selectedVC = self.childVCS[self.selectedIndex];
    void (^temp)() = ^{
        [selectedVC initUI];
    };

    switch (self.selectedIndex + 1973) {
        case SleepBtn:;break;
        case SportBtn: PUSH(@"More", @"StepSettingTVC", @"运动设置", @{@"setCallbac":temp}, YES);break;
        case HeartBtn: PUSH(@"More", @"HeartBeatSetterVC", @"心率设置", @{@"setCallbac":temp}, YES);break;
        case BloodBtn: PUSH(@"More", @"BloodPressureSetterVC", @"血压设置", @{@"setCallbac":temp}, YES);break;
        case SugarBtn: PUSH(@"Home", @"BloodSugarTVC", @"血糖设置", @{}, YES);break;
        default:break;
    }
}

#pragma mark- 判断是否为管理员
- (BOOL)isMasterOfImei:(NSString*)imei
{
    NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];
    for (CHTermUser *user in termUsers){
        
        if ([user.imei isEqualToString:imei]) {
            
            return user.isMaster;
        }
    }
    
    return NO;
    
}

@end
