//
//  SelectServeUserCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServeUserModel.h"

@protocol selectButtonDelegate <NSObject>

- (void)choseButton:(NSInteger *)tag;

@end

@interface SelectServeUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageV;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *surplusNumLB;
@property (weak, nonatomic) IBOutlet UILabel *serveLB;
@property (weak, nonatomic) IBOutlet UILabel *rankLB;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn;
@property (assign, nonatomic) NSInteger buttonTag;

@property (nonatomic,assign) id<selectButtonDelegate> delegate;

- (void)configUI:(ServeUserModel *)model withTag:(NSInteger)tag;

@end
