

#import "AnnonViewController.h"
#import "CJSONDeserializer.h"
#import "UIView+Toast.h"
#import "GlobalDefine.h"
#import "OttTabbarController.h"
#import "QRadioButton.h"
#import "UIWindow+YzdHUD.h"
#import "GBPathImageView.h"
#import "MyMD5.h"

#import "NSPublic.h"
 

@implementation AnnonViewController
@synthesize backView; 
@synthesize  ImeiField,telNOField,gxField,userNameField;//,tenantIdField
@synthesize okImg,cancelImg;


int prewTag ;  //编辑上一个UITextField的TAG,需要在XIB文件中定义或者程序中添加，不能让两个控件的TAG相同
float prewMoveY; //编辑的时候移动的高度
NSString *status;


 

- (void)viewDidLoad
{
    //-----------------------1、添加背景页面---------------------
    
    backView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,kDeviceWidth,KDeviceHeight-60)];
    backView.image  = [UIImage imageNamed:@"bind"];
    backView.userInteractionEnabled = YES; //给UIImageView添加事件响应
    
    
    //-----------------------2、Button确定 ---------------------
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(30,445,260,30);
    okBtn.backgroundColor = UI_COLOR_FROM_RGB(0xff4a42);
    okBtn.userInteractionEnabled = YES;
    [okBtn setTitle:@ "确 定" forState:UIControlStateNormal];
    UITapGestureRecognizer *bindTouchokBtn = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bindBtnTouch:)];
    [okBtn addGestureRecognizer:bindTouchokBtn];
    [backView addSubview:okBtn];
    
    //-----------------------3、UIText用户名，密码---------------------
    
    //请输入IMEI号
    ImeiField = [[MHTextField alloc] initWithFrame:CGRectMake(90.0f, 178.0f, 280.0f, 30.0f)];
    [ImeiField setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];//格式
    [ImeiField setBorderStyle:UITextBorderStyleNone];
    ImeiField.placeholder = @"请输入IMEI号";
    
    //请输入关注人名称
    userNameField = [[MHTextField alloc] initWithFrame:CGRectMake(90.0f, 230.0f, 280.0f, 30.0f)];
    [userNameField setBorderStyle:UITextBorderStyleNone];
    [userNameField setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];//格式
    userNameField.placeholder = @"请输入关注人名称";
    ///userNameField.delegate = self;//设置它的委托方法
    
    //请输入关注人关系
    gxField = [[MHTextField alloc] initWithFrame:CGRectMake(90.0f, 285.0f, 280.0f, 30.0f)];
    [gxField setBorderStyle:UITextBorderStyleNone];
    [gxField setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];//格式
    gxField.placeholder = @"请输入关注人关系";
    //gxField.delegate = self;//设置它的委托方法
    
    
   
    
    //请输入关注人手机号
    telNOField = [[MHTextField alloc] initWithFrame:CGRectMake(90.0f, 335.0f, 280.0f, 30.0f)];
    [telNOField setBorderStyle:UITextBorderStyleNone];
    [telNOField setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];//格式 
    telNOField.placeholder = @"请输入关注人手机号";
    //telNOField.delegate = self;//设置它的委托方法
    
    
    [backView addSubview:userNameField];
    [backView addSubview:gxField]; 
    [backView addSubview:ImeiField];
    [backView addSubview:telNOField];
    
    [backView addSubview:okBtn]; 
    [[OttTabbarController shareInstance]setTabbarStatus:NO];
    [self.view addSubview:backView];
    
    
    QRadioButton *_radio1 = [[QRadioButton alloc] initWithDelegate:self groupId:@"groupId1"];
    _radio1.frame = CGRectMake(85, 400, 80, 40);
    [_radio1 setTitle:@"男" forState:UIControlStateNormal];
    [_radio1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_radio1.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [self.view addSubview:_radio1];
    [_radio1 setChecked:YES];
    
    QRadioButton *_radio2 = [[QRadioButton alloc] initWithDelegate:self groupId:@"groupId1"];
    _radio2.frame = CGRectMake(195, 400, 80, 40);
    [_radio2 setTitle:@"女" forState:UIControlStateNormal];
    [_radio2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_radio2.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [self.view addSubview:_radio2];
    
    
    //回退
    UIImageView *leftButton = [[UIImageView alloc]initWithFrame:CGRectMake(15,17, 50, 40)];
    leftButton.image = [UIImage imageNamed:@"Nav_back"];
    leftButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouchokBtn1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backTouch:)];
    [leftButton addGestureRecognizer:singleTouchokBtn1];
    [self.view addSubview:leftButton];
    
    
    GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(126.5f, 90, 70, 60)
                                                                    image:[UIImage imageNamed:@"userDefault"]
                                                                 pathType:GBPathImageViewTypeCircle
                                                                pathColor:[UIColor clearColor]
                                                              borderColor:[UIColor clearColor]
                                                                pathWidth:0.0];
    [self.view addSubview:squareImage];
    squareImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait:)];
    [squareImage addGestureRecognizer:portraitTap];
    
    sexString = @"男";
}

/******************************************************************************
 函数名称  : login:
 函数描述  : 系统登录，包含验证、信息提交、页面跳转等
 输入参数  : N/A
 输出参数  : N/A
 返回值    : NSMutableArray,登录页面控件数组
 备注      :	N/A
 ******************************************************************************/
-(void)bindBtnTouch:(id)sender{
    
    NSString * userName = self.userNameField.text;
    NSString *imei = self.ImeiField.text;
    
    if ( userName.length==0 || userName==nil )
    {
        [self.view makeToast:@"请输入用户账号!" duration:1.0  position:CSToastPositionCenter ];
        return;
    }
    if ( imei.length==0 || imei==nil )
    {
        [self.view makeToast:@"请输入imei码!" duration:1.0  position:CSToastPositionCenter ];
        
        return;
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    sexString =@"男";
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        NSArray *array9 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getUserName],telNOField.text,userName,gxField.text,sexString,@"" ,@"",nil];
        NSDictionary *dictionary  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"bind.do"] with:array9 with:@"bind.do"];
        status = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"status"]];
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        [HUD removeFromSuperview];
        if ([status isEqualToString:@"0" ])
        {
            [self.view makeToast:@"关注成功" duration:1.0  position:CSToastPositionCenter ];
            sleep(0.5);
             [[NSNotificationCenter defaultCenter] postNotificationName:@"regBackNotice" object:nil];
        }
        else
        {
            [self.view makeToast:@"关注失败" duration:1.0  position:CSToastPositionCenter ];
            return;
        }
    }];
    
}



- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId {
    sexString = radio.titleLabel.text;
}


- (void)editPortrait:(id)sender {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.portraitImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}



-(void)backTouch:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"regBackNotice" object:nil];
}


 

/******************************************************************************
 函数名称  : login:
 函数描述  : 系统登录，包含验证、信息提交、页面跳转等
 输入参数  : N/A
 输出参数  : N/A
 返回值    : NSMutableArray,登录页面控件数组
 备注      :	N/A
 ******************************************************************************/
-(void)okBtnTouch:(id)sender{
    
    
}


//1.1、点击键盘Go
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

//点击背景事件，关闭键盘
-(IBAction)backBroad:(id)sender
{
    //通过在背景区域的点击事件里调用［textField resignFirstResponser］隐藏键盘
    //[userNameField resignFirstResponder];
    //[passwordField resignFirstResponder];
}






@end
