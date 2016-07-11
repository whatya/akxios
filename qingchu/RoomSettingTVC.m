//
//  RoomSettingTVC.m
//  qingchu
//
//  Created by 张宝 on 15/10/23.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#pragma mark- Page Top

#import "RoomSettingTVC.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CommonConstants.h"
#import "HttpManager.h"
#import "NSPublic.h"
#import "Base64.h"
#import "CanHideTF.h"
#import "ProgressHUD.h"
#import "MessageService.h"
#import "UIImageView+WebCache.h"
#import "NSUserDefaults+Util.h"

#define MemberCellID @"MemberCell"
#define AddCellID    @"AddCell"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface RoomSettingTVC ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIAlertViewDelegate,
UICollectionViewDelegateFlowLayout>


@property (nonatomic,strong) NSMutableArray *roomMembers;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *roomAvatar;
@property (weak, nonatomic) IBOutlet UILabel *memeberCountLB;
@property (weak, nonatomic) IBOutlet CanHideTF *myNicknameTF;
@property (weak, nonatomic) IBOutlet UISwitch *beQuiteSwitch;
@property (weak, nonatomic) IBOutlet CanHideTF *roomTF;
@property (weak, nonatomic) IBOutlet UITextView *introductionTV;
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
@property (strong, nonatomic) MessageService *messageService;

@end

@implementation RoomSettingTVC

#pragma mark- 控制器生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource  = self;
    self.collectionView.delegate    = self;
    AddCornerBorder(self.roomAvatar, self.roomAvatar.bounds.size.width/2, 1, [UIColor lightGrayColor].CGColor);
    //界面
    dispatch_async(kBgQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:URL(self.room.imageUrl)];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.roomAvatar.image = [UIImage imageWithData:data] ? :[UIImage imageNamed:@"profileUserAvatar"];
        });
    });
    

    
    self.roomTF.text            = self.room.roomName;
    self.introductionTV.text    = self.room.introduction;
    self.beQuiteSwitch.on       = self.room.isRemind;
    self.roomTF.enabled         = self.room.isMaster;
    self.introductionTV.editable= self.room.isMaster;
    self.titleLB.text           = self.room.roomName;
    
    
    
    
}

- (NSString*)myNickName
{
    for (NSDictionary *dictionary in self.roomMembers){
        if ([dictionary[@"username"] isEqualToString:[[NSPublic shareInstance] getUserName]]) {
            NSString* nickname = dictionary[@"nickname"];
            if (nickname.length > 0) {
                return nickname;
            }else{
                return dictionary[@"username"];
            }
        }
    }
    return @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self fetchRoomMembers];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark- tableview 数据源和代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认清空？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 1975;
        [alert show];
    }
}

#pragma mark- collection view 数据源和代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.roomMembers.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.roomMembers.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AddCellID forIndexPath:indexPath];
        return cell;
    }else{
        
         NSDictionary *model  = self.roomMembers[indexPath.row];
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MemberCellID forIndexPath:indexPath];
        UIImageView *userAvatar = (UIImageView*)[cell viewWithTag:1973];
        
        UIImageView *banner = (UIImageView*)[cell viewWithTag:1976];
        banner.hidden = (![model[@"isMaster"] boolValue]);
        
       
        
        [userAvatar sd_setImageWithURL:URL(model[@"image"]) placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
        AddCornerBorder(userAvatar,
                        userAvatar.bounds.size.width/2,
                        1,
                        [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1].CGColor);

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.roomMembers.count) {
        PUSH(@"Relatives", @"WXShareVC", @"分享", @{@"imei":self.room.imei}, YES);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(72, 72);
}

#pragma mark- 返回上级界面
- (IBAction)pop:(UIButton *)sender
{
    if ([self isPageUnChanged]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:nil
                                                              message:@"是否保存？"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                                    otherButtonTitles:@"保存", nil];
        updateAlert.tag = 1973;
        [updateAlert show];
    }
}

#pragma mark- 弹出框代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1973) {
        if (buttonIndex == 1) {
            [self updateRoomInformation];
            self.room.roomName = self.roomTF.text;
            self.room.introduction = self.introductionTV.text;
            self.room.isRemind = self.beQuiteSwitch.isOn;
            [NSUserDefaults room:self.room.roomId shouldRemind:self.room.isRemind];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (alertView.tag == 1975){
        [self.messageService deleteMessagesWith:self.room.roomId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagesCleared" object:nil];
    }
    
}



#pragma mark- 滑动关闭键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark- 添加亲友圈头像
- (IBAction)addAvatar:(UITapGestureRecognizer *)sender
{
    if (!self.room.isMaster) {
        return;
    }
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [actionSheet showInView:self.view.window];
}

#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
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
        
        self.roomAvatar.image = editImage;
        [self updateRoomAvatar];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- 提交头像到服务器
- (void)updateRoomAvatar
{
    NSArray *keys = @[@"image",@"roomId"];
    
    NSData *imageData = UIImageJPEGRepresentation(self.roomAvatar.image, 0.5);
    
    NSString *baseStr = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSString *userImageStr = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)baseStr,
                                                                                         NULL,
                                                                                         CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                         kCFStringEncodingUTF8);
    NSLog(@"%@",userImageStr);
    NSArray *values = @[userImageStr,self.room.roomId];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@uploadRoomHeadImage.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [[Alert sharedAlert] showMessage:@"头像上传成功！"];
                [[SDImageCache sharedImageCache] cleanDisk];
                [[SDImageCache sharedImageCache] clearMemory];
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];

}

#pragma mark- 提交圈信息
- (void)updateRoomInformation
{
    if (self.room.isMaster) {
        //管理员
        NSArray *keys = @[@"user",@"roomId",@"roomName",@"description"];
        NSArray *values = @[[[NSPublic shareInstance] getUserName]?: @"",
                            self.room.roomId ?: @"",
                            self.roomTF.text ?: @"",
                            self.introductionTV.text ?: @""];
        
        NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
        NSString *apiString = @"chunhui/m/room@updateRoomInfo.do";
        
        [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
            if (!error) {
                if (IsSuccessful(jsonData)) {
                    [ProgressHUD showSuccess:@"管理员提交信息成功！" Interaction:YES];
                }else{
                    [ProgressHUD showError:ErrorString(jsonData) Interaction:YES];
                }
            }else{
                [ProgressHUD showError:@"连接失败，请稍候再试喔！" Interaction:YES];
            }
        }];
        
        NSArray *inforKeys = @[@"user",@"roomId",@"nickname",@"isRemind"];
        NSArray *inforValues = @[[[NSPublic shareInstance] getUserName]?: @"",
                            self.room.roomId ?: @"",
                            self.myNicknameTF.text ?: @"",
                            self.beQuiteSwitch.isOn ? @"1" : @"0"];
        
        //管理员提交账户信息
        NSString *inforQueryString = [[HttpManager sharedHttpManager] joinKeys:inforKeys withValues:inforValues];
        NSString *inforapiString = @"chunhui/m/room@updateMyRoomInfo.do";
        
        [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:inforapiString portID:80 queryString:inforQueryString callBack:^(id jsonData, NSError *error) {
            if (!error) {
                if (IsSuccessful(jsonData)) {
                    
                }else{
                    [ProgressHUD showError:ErrorString(jsonData) Interaction:YES];
                }
            }else{
                [ProgressHUD showError:@"连接失败，请稍候再试喔！" Interaction:YES];
            }
        }];


        
    }else{
        //非管理员提交
        NSArray *keys = @[@"user",@"roomId",@"nickname",@"isRemind"];
        NSArray *values = @[[[NSPublic shareInstance] getUserName]?: @"",
                            self.room.roomId ?: @"",
                            self.myNicknameTF.text ?: @"",
                            self.beQuiteSwitch.isOn ? @"1" : @"0"];
        
        NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
        NSLog(@"%@",queryString);
        NSString *apiString = @"chunhui/m/room@updateMyRoomInfo.do";
        
        [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
            if (!error) {
                if (IsSuccessful(jsonData)) {
                    [ProgressHUD showSuccess:@"成功！" Interaction:YES];
                }else{
                    [ProgressHUD showError:ErrorString(jsonData) Interaction:YES];
                }
            }else{
                 [ProgressHUD showError:@"连接失败，请稍候再试喔！" Interaction:YES];
            }
        }];

    }
}

#pragma mark- 验证信息是否有更改
- (BOOL)isPageUnChanged
{
    return [self.myNicknameTF.text isEqualToString:[self myNickName]] &&
            [self.roomTF.text isEqualToString:self.room.roomName] &&
            [self.introductionTV.text isEqualToString:self.room.introduction] &&
            self.beQuiteSwitch.isOn == self.room.isRemind;
}

#pragma mark- 导航
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMemberListVC"]) {
        [segue.destinationViewController setValue:self.room.roomId forKey:@"roomId"];
    }
}

- (void)fetchRoomMembers
{
    self.roomMembers = [NSMutableArray new];
    NSArray *keys = @[@"user",@"roomId"];
    NSArray *values = @[[[NSPublic shareInstance] getUserName],self.room.roomId];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/room@getMembersByRoomId.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                NSArray *roomMembers = jsonData[@"data"];
                
                
                for (NSDictionary *memeber in roomMembers){
                    if ([memeber[@"isMaster"] boolValue]) {
                        [self.roomMembers insertObject:memeber atIndex:0];
                    }else{
                        [self.roomMembers addObject:memeber];
                    }
                }
                
                self.myNicknameTF.text      = [self myNickName];
                self.memeberCountLB.text    = [NSString stringWithFormat:@"%d人",(int)self.roomMembers.count];
                
                [self.collectionView reloadData];
            }
        }
        
    }];
}

#pragma mark- 惰性初始化
- (MessageService *)messageService
{
    if (!_messageService) {
        _messageService = [[MessageService alloc] init];
    }
    return _messageService;
}


#pragma mark- Page Bottom
@end
