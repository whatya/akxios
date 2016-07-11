//
//  AddPersonTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/15.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "AddPersonTVC.h"
#import "CJSONDeserializer.h"
#import "UIView+Toast.h"
#import "GlobalDefine.h"
#import "UIWindow+YzdHUD.h"
#import "GBPathImageView.h"
#import "MyMD5.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSPublic.h"
#import "Base64.h"
#import "CHTermUser.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+CusomeBackButton.h"
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface AddPersonTVC ()<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
VPImageCropperDelegate,
AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topIconIMV;
@property (weak, nonatomic) IBOutlet UITextField *watchUserNameTF;
@property (weak, nonatomic) IBOutlet UITextField *watchUserPhoneTF;
@property (weak, nonatomic) IBOutlet UITextField *watchIMEITF;
@property (weak, nonatomic) IBOutlet UITextField *watchSimTF;
@property (weak, nonatomic) IBOutlet UIButton *boyBTN;
@property (weak, nonatomic) IBOutlet UIButton *girlBTN;
@property (weak, nonatomic) IBOutlet UITextField *watchUserCardTF;
@property (assign,nonatomic) BOOL backBtnCliked;

@end

@implementation AddPersonTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    self.topIconIMV.clipsToBounds = YES;
    self.topIconIMV.layer.cornerRadius = 46.0;
    
    [self.boyBTN setImage:[UIImage imageNamed:@"register-radiobutton-u"] forState:UIControlStateNormal];
    [self.boyBTN setImage:[UIImage imageNamed:@"register-radiobutton-d"] forState:UIControlStateSelected];
    
    [self.girlBTN setImage:[UIImage imageNamed:@"register-radiobutton-u"] forState:UIControlStateNormal];
    [self.girlBTN setImage:[UIImage imageNamed:@"register-radiobutton-d"] forState:UIControlStateSelected];
    
    if ([self.title isEqualToString:@"编辑关注人"]) {
        
        [self.topIconIMV sd_setImageWithURL:[NSURL URLWithString:self.model.iconBase64String] placeholderImage:[UIImage imageNamed:@"tx-xq"]];
        
        self.watchUserNameTF.text = self.model.name;
        self.watchUserPhoneTF.text = self.model.phone;
        self.watchIMEITF.text = self.model.imei;
        self.watchSimTF.text = self.model.sim;
        self.watchUserCardTF.text = self.model.mcard;
        if ([self.model.gender isEqualToString:@"男"]) {
            self.boyBTN.selected = YES;
        }
        
        if ([self.model.gender isEqualToString:@"女"]) {
            self.girlBTN.selected = YES;
        }
        
    }else{
        self.model = [[RelativeModel alloc] init];
        if (self.imei) {
            self.watchIMEITF.text = self.imei;
        }

    }
    
    if (self.incomingImei) {
        self.watchIMEITF.text = self.incomingImei;
    }
    
    if (self.incomingName) {
        self.watchUserNameTF.text = self.incomingName;
    }
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.backBtnCliked) {
        return YES;
    }
    
    if (textField.tag == 1977) {
        if (![self isValidPhone:textField.text]) {
            [ProgressHUD showError:@"手机号为11位！"];
            return NO;
        }
    }
    
    if (textField.tag == 1973) {
        if (![self isValidImei:textField.text]) {
            [ProgressHUD showError:@"imei号不正确！"];
            return NO;
        }
    }
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.backBtnCliked) {
        return YES;
    }
    
    
    if (textField.tag == 1976 || textField.tag == 1977 ) {
        if (![self isValidPhone:textField.text]) {
            [ProgressHUD showError:@"手机号为11位！"];
            return NO;
        }
    }
    if (textField.tag == 1973) {
        if (![self isValidImei:textField.text]) {
            [ProgressHUD showError:@"imei号不正确！"];
            return NO;
        }
    }
    
    UITextField *nextOne = [self nextTextFiledWithCurrenIndex:textField.tag];
    if (nextOne) {
        [nextOne becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
    }
    return YES;
}


- (UITextField*)nextTextFiledWithCurrenIndex:(NSInteger)index
{
    if (self.backBtnCliked) {
        return nil;
    }
    
    if (index == 1977) {
        return nil;
    }
    NSInteger realIndex = index - 1973 + 1;
    
    return @[self.watchIMEITF,self.watchUserNameTF,self.watchUserPhoneTF,self.watchSimTF][realIndex];
}

- (BOOL)isValidNameOrRelationShip:(NSString*)beValidatedString
{
    
    if (beValidatedString.length > 0 && beValidatedString.length < 3 && beValidatedString.length != 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isValidPhone:(NSString*)phone
{
    if (phone.length == 11 || phone.length == 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isValidImei:(NSString*)imei
{
    if (imei.length > 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (void)setBarCode:(NSString *)barCode
{
    _barCode = barCode;
    self.watchIMEITF.text = barCode;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([self isValidImei:self.watchIMEITF.text] && self.watchUserPhoneTF.text.length == 11 && self.watchUserNameTF.text.length > 0) {
        return YES;
    }else{
        [self.view.window makeToast:@"imei、姓名和手机号必填！" duration:1 position:CSToastPositionCenter];
        return NO;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.model.name = self.watchUserNameTF.text;
    self.model.phone = self.watchUserPhoneTF.text;
    self.model.mcard = self.watchUserCardTF.text;
    self.model.imei = self.watchIMEITF.text;
    self.model.sim = self.watchSimTF.text;
    self.model.gender = [self boyOrGirl];
    self.model.iconBase64String = [Base64 stringByEncodingData:UIImageJPEGRepresentation(self.topIconIMV.image, 0.5)];
    
    UIViewController *devc = segue.destinationViewController;
    if ([self.title isEqualToString:@"编辑关注人"]) {
        devc.title = @"编辑健康档案";
    }
    
    [segue.destinationViewController setValue:self.model forKey:@"model"];
}

- (NSString*)boyOrGirl
{
    if (self.boyBTN.selected) {
        return @"男";
    }
    if (self.girlBTN.selected) {
        return @"女";
    }
    return @"";
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
- (IBAction)selectIcon:(UITapGestureRecognizer *)sender
{
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
        self.topIconIMV.image = editImage;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)getCode:(UIButton *)sender {
    
    UIViewController *scannerVC = [[UIStoryboard storyboardWithName:@"More" bundle:nil] instantiateViewControllerWithIdentifier:@"ScannerVC"];
    [scannerVC setValue:self forKey:@"delegate"];
    [self presentViewController:scannerVC animated:YES completion:NULL];
 
}


- (IBAction)toggleGender:(UIButton *)sender {
    
    sender.selected = !sender.isSelected;
    
    if (sender.tag == 1973) {
        self.girlBTN.selected = NO;
    }else{
        self.boyBTN.selected = NO;
    }
}

-(void)doBack:(id)sender
{
    self.backBtnCliked = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
