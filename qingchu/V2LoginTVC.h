//
//  V2LoginTVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2LoginTVC : UITableViewController

@property (nonatomic, assign) BOOL shouldShowBackBtn;
@property (copy, nonatomic) void(^loginCallback)();

@end
