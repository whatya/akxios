//
//  PhoneBillChargerTVC.h
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTermUser.h"
#define K_bill_id @"id"
#define K_bill_marketPrice @"marketPrice"
#define K_bill_salePrice   @"salePrice"

@interface Bill : NSObject

@property(nonatomic,strong) NSString *bid;
@property(nonatomic,assign) double marketPrice;
@property(nonatomic,assign) double salePrice;
@property(nonatomic,assign) BOOL checked;

- (id)initFromDictionary:(NSDictionary*)dictionary;

@end

@interface PhoneBillChargerTVC : UITableViewController

@property(nonatomic,strong) CHTermUser *user;

@end
