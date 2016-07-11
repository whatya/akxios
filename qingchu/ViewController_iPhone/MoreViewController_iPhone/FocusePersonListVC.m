//
//  FocusePersonListVC.m
//  SlideCellDemo
//
//  Created by ZhuXiaoyan on 15/8/11.
//  Copyright (c) 2015年 ZhuXiaoyan. All rights reserved.
//

#import "FocusePersonListVC.h"
#import "FocusedPersonCell.h"
#import "UIView+Toast.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSPublic.h"
#import "CHTermUser.h"
#import "CHTermUserFrame.h"
#import "Base64.h"
#import "AppDelegate.h"
#import "RelativeModel.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "RootViewController.h"
#import "DataPublic.h"
#import "IconManager.h"
#import "CommonConstants.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "GlobalDefine.h"

@interface FocusePersonListVC ()
<UITabBarDelegate,
UITableViewDataSource,
FocusedPersonCellDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *loginedUserIcon;
@property (weak, nonatomic) IBOutlet UILabel *loginedUserLB;
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *focusPersonArray;

@property (strong,nonatomic) NSString *dismissImei;//管理员待解绑imei号码

@end

@implementation FocusePersonListVC
#define FocusedPersonCellID @"FocusedPersonCell"

#pragma mark- 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    
    self.focusPersonArray = [NSMutableArray new];
    
    [self initUI];
}
- (IBAction)addPic:(UITapGestureRecognizer *)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [actionSheet showInView:self.view.window];
}

- (IBAction)addRelative:(id)sender {
    
    if ([[NSPublic shareInstance] getTermUserArray].count < 5){
        PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
    }else{
        [ProgressHUD showError:@"最多只能绑定5个亲人！"];
        return;
    }

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

        self.loginedUserIcon.image = editImage;
        [self updateLoginedUserInformation];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self populateData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [ProgressHUD dismiss];
}

#pragma mark-  静态界面初始化
- (void)initUI
{
    self.loginedUserIcon.clipsToBounds = YES;
    self.loginedUserIcon.layer.cornerRadius = 50;
    self.plusBtn.clipsToBounds = YES;
    self.plusBtn.layer.cornerRadius = 15;

}



#pragma mark- tableview 数据源和代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.focusPersonArray.count;
    // NSLog(@"qaswqasqwaswqasqwasqasqwasqasq%ld",(unsigned long)self.focusPersonArray.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FocusPersonModel *model = self.focusPersonArray[indexPath.row];
    model.indexPath = indexPath;
    FocusedPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:FocusedPersonCellID];
    cell.delegate = self;
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark- cell代理方法
- (void)selecteCellWithModel:(FocusPersonModel *)model
{
    
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
    
    //2.得到配置信息
    
    [[DataPublic shareInstance] getSettingInfo];
    
//     UIViewController *tabbarVC  = [OttTabbarController shareInstance];
//    [[OttTabbarController shareInstance] initView];
    [UIApplication sharedApplication].keyWindow.rootViewController = VCFromStoryboard(@"Home", @"GridHomeNav");

}

- (void)takeActionWithCode:(NSInteger)actionCode withModel:(FocusPersonModel *)model
{
    if (actionCode == Unbind) {
        NSString __block *status = nil;
        NSString *imei = model.user.imei;
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
            //获取所有的设置信息
            NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getUserName],imei,[[NSPublic shareInstance]getJSESSION],nil];
            
            NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"unbind.do"] with:array0 with:@"unbind.do"];
            status  = [NSString stringWithFormat:@"%@",[dictionary0 objectForKey:@"status"]];
        } completionBlock:^{//回调或者说是通知主线程刷新
            [HUD removeFromSuperview];
            if ([status isEqualToString:@"0" ])
            {

                [[[NSPublic shareInstance] getTermUserArray] removeObject:model.user];
                
                [self.focusPersonArray removeObject:model];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[model.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
                
                [self.tableView reloadData];
                
                [ProgressHUD showSuccess:@"解绑成功！" Interaction:YES];
                
            }
            else if ([status isEqualToString:@"-21" ])
            {
                [self.view makeToast:@"imei号未登记" duration:1.0  position:CSToastPositionCenter];
                return;
            }else
            {
                self.dismissImei = model.user.imei;
                UIAlertView *adminAlert = [[UIAlertView alloc] initWithTitle:@"您是该手表的管理员" message:@"请转让管理员权限后再执行解除绑定操作！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去转让", nil];
                adminAlert.tag = 1973;
                [adminAlert show];
                
                return;
            }
        }];
    }else if(actionCode == SendMessage){
        CHTermUser *termUser = model.user;
        [[NSPublic shareInstance]setImei:termUser.imei];
        [[NSPublic shareInstance]setname:termUser.name];
        [[NSPublic shareInstance]setrelative:termUser.relative];
        [[NSPublic shareInstance]setsim:termUser.sim];
        [[NSPublic shareInstance]setsex:termUser.sex];
        [[NSPublic shareInstance]setimage:termUser.image];
        RootViewController *chatVC = [[RootViewController alloc] init];
        chatVC.incomingImei = termUser.imei;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
        nav.navigationBar.barTintColor = ThisRedColor;
        [self presentViewController:nav animated:YES completion:NULL];
        //[self.navigationController pushViewController:chatVC animated:YES];
    }else{
        
        RelativeModel *detailMoel = [[RelativeModel alloc] init];
        detailMoel.name = model.user.name;
        detailMoel.imei = model.user.imei;
        detailMoel.relationship = model.user.relative;
        detailMoel.sim = model.user.sim;
        detailMoel.gender = model.user.sex;
        detailMoel.iconBase64String = model.user.image;
        detailMoel.phone = model.user.phone;
        
        detailMoel.birthday = model.user.birthday;
        detailMoel.height = model.user.height;
        detailMoel.weight = model.user.weight;
        detailMoel.medicalHistory = model.user.medicalHistory;
        detailMoel.dailyMedicine = model.user.dailyMedicine;
        detailMoel.allergicHistory = model.user.allergicHistory;
        detailMoel.mcard = model.user.mcard;
        
        UIStoryboard *more = [UIStoryboard storyboardWithName:@"More" bundle:nil];
        UIViewController *vc = [more instantiateViewControllerWithIdentifier:@"AddFocusTVC"];
        vc.title = @"编辑关注人";
        [vc setValue:detailMoel forKey:@"model"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark- alert代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1973) {
        
        if (buttonIndex == 1) {
            
            PUSH(@"Relatives", @"MemberListVC", @"管理员转让", @{@"incomingImei":self.dismissImei}, YES);
            self.dismissImei = @"";
        }
        
    }else{
        //do nothing
    }
}

#pragma mark-  actoin方法
- (IBAction)addBtn:(UIButton *)sender
{
//    AnnonViewController *annonViewController = [[AnnonViewController alloc]init];
//    [self.navigationController pushViewController:annonViewController animated:YES];
    
    UIStoryboard *more = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    UIViewController *vc = [more instantiateViewControllerWithIdentifier:@"AddFocusTVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)addPeople:(UITapGestureRecognizer *)sender {
    PUSH(@"More", @"AddFocusTVCForWX", @"添加关注人", @{},YES);
}


#pragma mark- 获取数据
- (void)populateData
{
    [ProgressHUD show:@"获取亲人中" Interaction:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *focusdImei = [userDefaults objectForKey:@"focusedPersionImei"];
        
        [[NSPublic shareInstance] setTermUserArray:[NSMutableArray arrayWithArray:@[]]];
        [[DataPublic shareInstance] getRelativesInfo];
        NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];
        
        if (termUsers.count == 0) {
            return ;
        }
        
        self.focusPersonArray = [NSMutableArray arrayWithCapacity:termUsers.count];
        for (CHTermUser *termUser in termUsers) {
            
            NSLog(@"%@",termUser.name);
            
            
            FocusPersonModel *model = [[FocusPersonModel alloc] init];
            model.user = termUser;
            
            if (focusdImei.length > 0) {
                if ([model.user.imei isEqualToString:focusdImei]) {
                    [self.focusPersonArray insertObject:model atIndex:0];
                }else{
                    [self.focusPersonArray addObject:model];
                }
            }else{
                [self.focusPersonArray addObject:model];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD dismiss];
           [self.tableView reloadData];
        });
    });

    
    
    
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

    
   
    IconManager *iconManager = [[IconManager alloc] init];
    NSString *imei = [[NSPublic shareInstance] getUserName];
    [iconManager saveImage:self.loginedUserIcon.image withImei:imei];
    
    NSString *paramString = [NSString stringWithFormat:@"user=%@&image=%@",[[NSPublic shareInstance] getUserName],baseString];
        [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                                portID:80
                                                           queryString:paramString
                                                              callBack:^(id jsonData, NSError *error) {
                                                                  NSDictionary *temp = jsonData;
                                                                  NSString *status = temp[@"status"];
                                                                  if ([status isEqualToString:@"0"]) {
                                                                      [[NSPublic shareInstance] setUserImage:baseString];
                                                                      [ProgressHUD showSuccess:@"头像提交成功！" Interaction:YES];
                                                                      
                                                                  }else{
                                                                      [ProgressHUD showError:@"头像提交失败！" Interaction:YES];
                                                                  }
                                                              }];
}



@end
