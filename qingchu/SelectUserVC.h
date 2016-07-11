//
//  SelectUserVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/12.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectUser.h"

@interface SelectUserVC : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *TBView;

@property (strong,nonatomic) NSMutableArray *usersArray;

@end
