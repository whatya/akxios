//
//  MemberCell.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/3.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "MemberCell.h"
#import "UIImageView+WebCache.h"
#import "CommonConstants.h"

@implementation MemberCell

- (void)awakeFromNib
{
    AddCornerBorder(self.imv, self.imv.bounds.size.width/2, 1, [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1].CGColor);
}


- (IBAction)transfer:(UIButton *)sender
{
    MemberCellAction action = self.transfer;
    if (action) {
        action(self.indexPath);
    }
}

- (IBAction)remove:(id)sender
{
    MemberCellAction action = self.remove;
    if (action) {
        action(self.indexPath);
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    [self.imv sd_setImageWithURL:URL(imageUrl) placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameLB.text = name;
}

- (void)closeMenu
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
