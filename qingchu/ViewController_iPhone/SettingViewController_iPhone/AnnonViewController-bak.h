/*!
 @header HomeViewController_iPhone
 @abstract 首页控制器
 @author 王松
 @version 1.0 2013/07/25建立
 */

#import <UIKit/UIKit.h>
#import "BaseViewController_iPhone.h" 
#import "MHTextField.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AnnonViewController :UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
{
    NSString *sexString;
}
@property (nonatomic, strong) UIImageView *portraitImageView;
 
//系统登录
@property(nonatomic,retain)UIImageView *backView;
  


@property(nonatomic,retain)UIImage *okImg;
@property(nonatomic,retain)UIImage *cancelImg;

@property(nonatomic,retain)MHTextField *gxField;
@property(nonatomic,retain)MHTextField *userNameField;
@property(nonatomic,retain)MHTextField *ImeiField;
@property(nonatomic,retain)MHTextField *telNOField;



-(void)initView;
@end
