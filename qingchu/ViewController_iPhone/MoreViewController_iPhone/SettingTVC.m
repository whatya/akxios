//
//  SettingTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/14.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "SettingTVC.h"
#import "AppDelegate.h"
#import "CommonConstants.h"
#import "UIViewController+CusomeBackButton.h"
#import "TCPManager.h"
#import "NSPublic.h"
#import "Base64.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "CHTermUser.H"
#import "UIImageView+WebCache.h"
#import "MyMD5.h"
#import "WXApi.h"
#import "WXMediaMessage+messageConstruct.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#define BUFFER_SIZE 1024 * 100

@interface SettingTVC ()
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *loginedUserIcon;//用户头像
@property (weak, nonatomic) IBOutlet UITextField *loginedUserTF;//用户昵称

@property (strong,nonatomic) NSString *orignalNickname;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;//返回按钮

@property (weak, nonatomic) IBOutlet UIView *pointBackView;//积分控件容器视图
@property (weak, nonatomic) IBOutlet UILabel *pointLB;//积分标签
@property (weak, nonatomic) IBOutlet UILabel *gradeLB;//等级标签

@property (nonatomic,strong) NSDictionary *fetchedPoints;//用来保存服务器获取的积分数据
@property (weak, nonatomic) IBOutlet UIView *gradeContainerView;//等级空间容器视图
@property (weak, nonatomic) IBOutlet UIImageView *oemLoginBgImage;//公司图像


@end

@implementation SettingTVC

#pragma mark- viewdidload
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置返回按钮
    [self setUpBackButton];
    //初始化视图
    [self initUI];
}

#pragma mark- 返回首页
- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark-  静态界面初始化
- (void)initUI
{
    
    //添加边框和圆角
    AddCornerBorder(self.exitBtn, 4, 0, nil);
    AddCornerBorder(self.loginedUserIcon, self.loginedUserIcon.bounds.size.width/2, 1, [UIColor whiteColor].CGColor);
    AddCornerBorder(self.pointBackView, self.pointBackView.bounds.size.height/2, 0, nil);
    
    NSString *tip = @"请输入昵称";
    NSString *username = [[NSPublic shareInstance] getUserName];
    if (username.length > 0) {//保存过用户名和密码
        //获取用户信息
        [self fetchUserInformationWithUser:username];
    }else{
        tip = @"请登录";
        self.loginedUserTF.enabled = NO;
    }
    
   
    //更改昵称输入框占位提示颜色
    self.loginedUserTF.attributedPlaceholder = [[NSAttributedString alloc]
                                                initWithString:tip
                                                attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    
}

#define KUser_idcard        @"idcard"
#define KUser_iamge         @"image"
#define KUser_imageUrl      @"imageUrl"
#define KUser_nickname      @"nickname"

#define KUser_real          @"real"
#define KUser_sex           @"sex"
#define KUser_sign          @"sign"
#define KUser_user          @"user"

#define KUser_data          @"data"
#define KUser_point         @"point"
#define KUser_totalPoints   @"totalpoint"
#define KUser_grade         @"grade"

#define PointsVCSegue       @"PointsVCSegue"
#define GradeVCSegue        @"GradeVCSegue"

- (IBAction)nicknameSet:(UITextField *)sender
{
    if (![sender.text isEqualToString:self.orignalNickname]) {
        [self updateLoginedUserInformation];
    }
}

- (IBAction)gradeMore:(UIButton *)sender {
}
- (IBAction)pointsMore:(UITapGestureRecognizer *)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PointsVCSegue]) {
        if (self.fetchedPoints) {
            int totalPoints = [self.fetchedPoints[KUser_totalPoints] intValue];
            int currentPoints = [self.fetchedPoints[KUser_point] intValue];
            
            [segue.destinationViewController setValue:@(totalPoints) forKey:@"totalPoints"];
            [segue.destinationViewController setValue:@(currentPoints) forKey:@"currentPoints"];
            
        }
    }else if ([segue.identifier isEqualToString:GradeVCSegue]){
        if (self.fetchedPoints) {
            [segue.destinationViewController setValue:self.fetchedPoints[KUser_grade] forKey:@"inputGradeStr"];
        }
    }
}

#pragma mark- 获取用户信息
- (void)fetchUserInformationWithUser:(NSString*)user
{
    NSArray *keys = @[@"user"];
    NSArray *values = @[user];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@getUserInfo.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                
                NSDictionary *data = jsonData[KUser_data];
                NSString *url = data[KUser_imageUrl];
                NSString *nickname = data[KUser_nickname];
                NSString *gradeName = data[KUser_grade];
                NSString *points = data[KUser_point];
                NSString *totalPoints = data[KUser_totalPoints];
                
                
                self.fetchedPoints = @{KUser_grade:gradeName,
                                       KUser_point:points,
                                       KUser_totalPoints:totalPoints};
                
                [self.loginedUserIcon sd_setImageWithURL:URL(url) placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
                if (nickname.length > 0) {
                    self.loginedUserTF.text = nickname;
                    self.orignalNickname = nickname;
                }
                self.pointLB.text = [NSString stringWithFormat:@"%@",points];
                self.gradeLB.text = gradeName;
                if (gradeName.length == 0) {
                    self.gradeContainerView.hidden = YES;
                }else{
                    self.gradeContainerView.hidden = NO;
                }
                
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍后再试喔！"];
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)signOut:(UIButton *)sender
{
    [NSPublic shareInstance].isFromExitPage = YES;
    [[TCPManager sharedInstance] loginOut];
    [TCPManager sharedInstance].username = nil;
    [TCPManager sharedInstance].passwrod = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AlertNoteKey"];
    UIViewController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
    self.view.window.rootViewController = VC;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && indexPath.section == 0) {
        
        NSString *imei = [[NSPublic shareInstance] getImei];
        if ([imei hasPrefix:@"35"]) {
            [self performSegueWithIdentifier:@"ChildSOSVC" sender:nil];
        }else{
            [self performSegueWithIdentifier:@"SOSVC" sender:nil];
        }
    }
    if (indexPath.row == 0 && indexPath.section == 0) {
        
        PUSH(@"Mall", @"OrderListVC", @"订单列表", @{}, YES);
    }
    
    if (indexPath.row == 3 && indexPath.section == 2) {
        //分享给医生
        [self shareToDoctor];
    }
    
    if (indexPath.row == 4 && indexPath.section == 2) {
        //分享给亲友
        [self shareToFriends];
    }
    
}


- (void)shareToDoctor {
    
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"微信分享"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:@"微信好友"
                                                   otherButtonTitles:@"朋友圈", nil];
    shareSheet.tag = 1979;
    
    [shareSheet showInView:self.view];
}

- (void)shareToFriends {
    
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"微信分享"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:@"微信好友"
                                                   otherButtonTitles:@"朋友圈", nil];
    shareSheet.tag = 1980;
    
    [shareSheet showInView:self.view];
}


#pragma mark- 分享
- (void) sendAppMessageInSence:(int)sence withType:(int)type
{
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    UIImage *thumbImage = [UIImage imageNamed:@"shareIcon"];
    [self sendAppContentData:data
                     ExtInfo:@"<xml>extend info</xml>"
                      ExtURL:@"http://h5.3chunhui.com/chunhui-h5/src/template/download/akx/index.html"
                       Title:@"安康信"
                 Description:@"我正在用安康信手机APP,可以与手表互动，很方便，推荐推荐，点这里可以..."
                  MessageExt:@"我正在用安康信手机APP,可以与手表互动，很方便，推荐推荐，点这里可以..."
               MessageAction:@"<action></action>"
                  ThumbImage:thumbImage
                     InScene:sence];
}



- (BOOL)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene {
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    
    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:messageExt
                                                 MessageAction:action
                                                    ThumbImage:thumbImage
                                                      MediaTag:nil];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMasterOfImei:[[NSPublic shareInstance] getImei]]) {
        
//        if (indexPath.section == 2 && indexPath.row == 1) {
//            if ([[[NSPublic shareInstance] getImei] hasPrefix:@"8888"]) {
//                return 0;
//            }else{
//                return 44;
//            }
//        }else{
//            return 44;
//        }
        
        return 44;
        
    }else{
        
        if (indexPath.section == 0 && indexPath.row == 1) {
            return 0;
        }
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            return 0;
        }
        
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isMasterOfImei:[[NSPublic shareInstance] getImei]]) {
        return [super tableView:tableView heightForHeaderInSection:section];
    }else{
        
        return 1;
    }
}

#pragma mark- 选择图片

- (IBAction)addPic:(UITapGestureRecognizer *)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [actionSheet showInView:self.view.window];
}


#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1979 || actionSheet.tag == 1980) {
        [self sendAppMessageInSence:(int)buttonIndex withType:(int)actionSheet.tag];
    }else{
        if (buttonIndex == 0) {
            [self addCarema];
        }else if (buttonIndex == 1){
            [self openPicLibrary];
        }

    }
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}
#define ThisRedColor  [UIColor colorWithRed:233/255.0 green:59/255.0 blue:60/255.0 alpha:1]
-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.navigationBar.barTintColor = ThisRedColor;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.loginedUserIcon.image = editImage;
        [self updateLoginedUserInformation];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- 提交登陆用户的信息（头像here）
- (void)updateLoginedUserInformation
{
    NSString *url = @"chunhui/m/user@uploadUserHeadImage.do";
    
    NSData *imageData = UIImageJPEGRepresentation(self.loginedUserIcon.image, 0.1);
    
    NSString *baseStr = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)baseStr,
                                                                                         NULL,
                                                                                         CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                         kCFStringEncodingUTF8);
    
    NSString *paramString = [NSString stringWithFormat:@"user=%@&image=%@&nickname=%@",[[NSPublic shareInstance] getUserName],baseString,self.loginedUserTF.text];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              NSDictionary *temp = jsonData;
                                                              NSString *status = temp[@"status"];
                                                              if ([status isEqualToString:@"0"]) {
                                                                  [[NSPublic shareInstance] setUserImage:baseString];
                                                                  [ProgressHUD showSuccess:@"修改成功！" Interaction:YES];
                                                                  
                                                                  [[[SDWebImageManager sharedManager] imageCache] clearDisk];
                                                                  [[[SDWebImageManager sharedManager] imageCache] clearMemory];
                                                                  
                                                              }else{
                                                                  [ProgressHUD showError:@"修改失败！" Interaction:YES];
                                                              }
                                                          }];
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
