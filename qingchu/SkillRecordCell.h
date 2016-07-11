//
//  SkillRecordCell.h
//  qingchu
//
//  Created by 张宝 on 16/7/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkillRecord.h"
@interface SkillRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIMV;
@property (weak, nonatomic) IBOutlet UILabel *dateLB;
@property (weak, nonatomic) IBOutlet UILabel *contentLB;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) SkillRecord *model;

@property (weak, nonatomic) IBOutlet UILabel *locationLB;


@end
