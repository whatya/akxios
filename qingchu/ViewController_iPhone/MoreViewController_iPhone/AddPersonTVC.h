//
//  AddPersonTVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/15.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RelativeModel.h"

@interface AddPersonTVC : UITableViewController

@property (nonatomic,strong) NSString *barCode;
@property (strong,nonatomic) RelativeModel *model;
@property (nonatomic,strong) NSString* imei;


@property (nonatomic,strong) NSString *incomingImei;
@property (nonatomic,strong) NSString *incomingName;

@end
