/*!
 @header AppDelegate
 @abstract AppDelegate
 @author 王松
 @version 1.0 2013/07/25建立
 */
#import <UIKit/UIKit.h>
#import "BPush.h"
#import "JSONKit.h"
#import "OpenUDID.h"
#import "CoreDataHelper.h"
#import "Message+CoreDataProperties.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder
<UIApplicationDelegate,
UIGestureRecognizerDelegate,
BPushDelegate,
UIAlertViewDelegate,
WXApiDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;


@end
