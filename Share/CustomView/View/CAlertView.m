
#import "CAlertView.h"


@implementation CAlertView
@synthesize m_AlertView;
@synthesize backAlpha;
@synthesize kTransitionDuration;
@synthesize isBackPress;
@synthesize windowLevel;

- (id)initWithAlertView:(UIView*)alertView  andAnimationType:(AnimationType)aType{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];

        m_AlertSuperView = [[UIControl alloc]init];
        [m_AlertSuperView addTarget:self action:@selector(backPress) forControlEvents:UIControlEventTouchDown];
        self.m_AlertView = alertView;
        [m_AlertSuperView addSubview:m_AlertView];
        backAlpha = 0.5;
        kTransitionDuration = 0.3f;
        isBackPress = NO;
        mType = aType;
        windowLevel = UIWindowLevelAlert;
        self.isDetail = NO;
    }
    return self;
}

#pragma mark animations
- (CGAffineTransform)transformForDeviceDirection {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (void)doBounceAnimationSecond{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    m_AlertView.transform = [self transformForDeviceDirection];
    [UIView commitAnimations];
}

- (void)doBounceAnimationFirst{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(doBounceAnimationSecond)];
    m_AlertView.transform = CGAffineTransformScale([self transformForDeviceDirection], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)alertViewIsRemoved
{
    [m_AlertSuperView  removeFromSuperview];
    if (m_FullscreenWindow)
    {
        [m_FullscreenWindow release];
        m_FullscreenWindow = nil;
    }
}

- (void)doAlertAnimation{
    m_AlertView.transform = CGAffineTransformScale([self transformForDeviceDirection], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(doBounceAnimationFirst)];
    m_AlertView.transform = CGAffineTransformScale([self transformForDeviceDirection], 1.1, 1.1);
    [m_AlertSuperView setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void)doNaviAnimation {
    m_AlertView.transform = CGAffineTransformTranslate([self transformForDeviceDirection], m_AlertView.frame.size.width, 0);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    m_AlertView.transform = CGAffineTransformTranslate([self transformForDeviceDirection], 0, 0);
    [m_AlertSuperView setAlpha:1.0f];
    [UIView commitAnimations];
}

-(void)doPageCureAnimation
{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.75;
//    transition.type = @"pageCurl";
//    transition.subtype = kCATransitionFromRight;
//    [m_AlertSuperView setAlpha:1.0f];
    m_AlertView.transform = [self transformForDeviceDirection];
//    [m_FullscreenWindow.layer addAnimation:transition forKey:nil];
}
- (void)orientationChanged:(NSNotification *)note {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration*2.7];
    CGAffineTransform tranform = [self transformForDeviceDirection];
    for (id obj in m_AlertView.subviews) {
        if ([obj isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)obj;
            if (textField.isEditing) {
                tranform= CGAffineTransformTranslate([self transformForDeviceDirection], 0, -90);
            }
        }
    }
    m_AlertView.transform = tranform;
    [UIView commitAnimations];
}

- (void)show {
    if (!m_FullscreenWindow) {
        m_FullscreenWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        m_FullscreenWindow.windowLevel = windowLevel;
        m_FullscreenWindow.backgroundColor = [UIColor clearColor];
        [m_FullscreenWindow addSubview:m_AlertSuperView];
        [m_AlertSuperView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:backAlpha]];
        [m_AlertSuperView setFrame:[m_FullscreenWindow bounds]];
        [m_FullscreenWindow makeKeyAndVisible];
        for (id obj in m_AlertView.subviews) {
            if ([obj isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField*)obj;
                textField.delegate = self;
            }
        }
        if (self.isDetail)
        {
            m_AlertView.frame = CGRectMake(-50.0f, 215.0f, 886.0f, 590.0f);
        }else
        {
            m_AlertView.center = m_AlertSuperView.center;
        }
        if (mType == AlertAnimationType) {
            [self doAlertAnimation];
        }
        else if (mType == NaviAnimationType) {
            [self doNaviAnimation];
        }
        else if (mType == NoneAnimationType) {
            [m_AlertSuperView setAlpha:1.0f];
            m_AlertView.transform = [self transformForDeviceDirection];
        }
        else if(mType==PageCureAnimationType)
        {
            [self doPageCureAnimation];
        }

    }
}

- (void)hideAlertView {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [mainWindow makeKeyAndVisible];
}

- (void)showAlertView {
    [m_FullscreenWindow makeKeyAndVisible];
}

- (void)dismissAlertView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(alertViewIsRemoved)];
    if (mType == NaviAnimationType) {
        m_AlertView.transform = CGAffineTransformTranslate([self transformForDeviceDirection], m_AlertView.frame.size.width, 0);
    }
    else {
        [m_AlertSuperView setAlpha:0.0f];
    }
    [UIView commitAnimations];
}

- (void)backPress{
    if (isBackPress) {
        [self dismissAlertView];
    }
}

#pragma mark -
#pragma mark UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    m_AlertView.transform = CGAffineTransformTranslate([self transformForDeviceDirection], 0, -90);
    [UIView commitAnimations];
}   

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    m_AlertView.transform = CGAffineTransformTranslate([self transformForDeviceDirection], 0, 0);
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
#pragma mark -
#pragma mark dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [m_AlertView release];
    [m_AlertSuperView release];
    [super dealloc];
}

@end
