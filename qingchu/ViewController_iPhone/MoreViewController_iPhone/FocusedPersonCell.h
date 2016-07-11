//
//  FocusedPersonCell.h
//  SlideCellDemo
//
//  Created by ZhuXiaoyan on 15/8/11.
//  Copyright (c) 2015年 ZhuXiaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FocusPersonModel.h"
#import "NSPublic.h"

#define SendMessage 1973
#define Update      1974
#define Unbind      1975

@protocol FocusedPersonCellDelegate <NSObject>

- (void)selecteCellWithModel:(FocusPersonModel*)model;

- (void)takeActionWithCode:(NSInteger)actionCode withModel:(FocusPersonModel*)model;


@end

@interface FocusedPersonCell : UITableViewCell<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *roundView;
@property (weak, nonatomic) IBOutlet UIImageView *personIcon;
@property (weak, nonatomic) IBOutlet UILabel *ime;
@property (weak, nonatomic) IBOutlet UILabel *detailLB;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (strong,nonatomic) FocusPersonModel *model;

@property (weak, nonatomic) id<FocusedPersonCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *updateContainerView;

@end
