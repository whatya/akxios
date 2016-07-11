//
//  SelectUserCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/12.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectUser.h"


@protocol SelectUserCellDelegate <NSObject>

- (void)selecteCellWithModel:(SelectUser*)model;

@end

@interface SelectUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageV;

@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *itemLB;

@property (weak, nonatomic) IBOutlet UIImageView *statusImageV;

@property (nonatomic,strong) SelectUser *model;


@property (weak, nonatomic) id<SelectUserCellDelegate> delegate;



@end
