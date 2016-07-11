//
//  BillRecordsVC.h
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

#define K_billRecord_rechargeId     @"rechargeId"
#define K_billRecord_payTime        @"payTime"
#define K_billRecord_rechargeTime   @"rechargeTime"
#define K_billRecord_mobile         @"mobile"
#define K_billRecord_fee            @"fee"
#define K_billRecord_provider       @"provider"
#define K_billRecord_status         @"status"


@interface BillRecord: NSObject

@property(nonatomic,strong) NSString *rechargeId;
@property(nonatomic,strong) NSString *payTime;
@property(nonatomic,strong) NSString *rechargeTime;
@property(nonatomic,strong) NSString *mobile;
@property(nonatomic,strong) NSString *fee;
@property(nonatomic,strong) NSString *provider;
@property(nonatomic,strong) NSString *status;

- (id)initFromDictionary:(NSDictionary*)dictionary;

@end

@interface BillRecordsVC : UIViewController

@end
