/*************************************************
 File name: CAlertView.h
 Description: 自定义弹出框类
 Others:
 History:
 *************************************************/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
typedef enum {
    AlertAnimationType,
    NaviAnimationType,
    NoneAnimationType,
    PageCureAnimationType
}AnimationType;

@interface CAlertView : UIView <UITextFieldDelegate>{
    UIView *m_AlertView;
    UIControl *m_AlertSuperView;
    UIWindow *m_FullscreenWindow;
    CGFloat backAlpha;
    CGFloat kTransitionDuration;
    BOOL    isBackPress;
    AnimationType mType;
    UIWindowLevel windowLevel;
}
@property UIWindowLevel windowLevel;
@property BOOL    isBackPress;
@property BOOL    isDetail;
@property CGFloat backAlpha;
@property CGFloat kTransitionDuration;
@property (retain,nonatomic) UIView *m_AlertView;
- (id)initWithAlertView:(UIView*)alertView andAnimationType:(AnimationType)aType;

- (void)show;

- (void)dismissAlertView;

- (void)backPress;

- (void)hideAlertView;

- (void)showAlertView;
@end
