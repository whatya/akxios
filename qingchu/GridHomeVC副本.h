//
//  GridHomeVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/24.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridHomeVC : UIViewController

- (void)navigateTo:(int)index withParameters:(NSDictionary*)dictionary animation:(BOOL)animate;
- (void)showMessageVC;
- (void)toImei:(NSString*)imei;

@end
