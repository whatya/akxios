//
//  PeopleGetVC.h
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTermUser.h"

@interface PeopelModel : NSObject

@property(nonatomic,strong) CHTermUser *user;
@property(nonatomic,assign) BOOL checked;

@end

@interface PeopleGetVC : UIViewController

@end
