//
//  OrderCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/15.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLB;
@property (weak, nonatomic) IBOutlet UILabel *statusLB;
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
@property (weak, nonatomic) IBOutlet UIImageView *coverIMV;
@property (weak, nonatomic) IBOutlet UILabel *salePrcieLB;
@property (weak, nonatomic) IBOutlet UILabel *marketPriceLB;
@property (weak, nonatomic) IBOutlet UILabel *countLB;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLB;


@end
