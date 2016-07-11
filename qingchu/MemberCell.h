//
//  MemberCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/3.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MemberCellAction)(NSIndexPath *cellIndexPath);

@interface MemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;

@property (strong,nonatomic) NSString *imageUrl;
@property (strong,nonatomic) NSString *name;

@property (strong,nonatomic) NSIndexPath *indexPath;

@property (nonatomic, copy) MemberCellAction remove;
@property (nonatomic, copy) MemberCellAction transfer;

- (void)closeMenu;

@end
