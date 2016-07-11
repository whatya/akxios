//
//  SkillRecordCell.m
//  qingchu
//
//  Created by 张宝 on 16/7/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillRecordCell.h"
#import "ClickImage.h"
#import "UIImageView+WebCache.h"
#import "CommonConstants.h"

@interface SkillRecordCell()<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@end

@implementation SkillRecordCell

#define CollectionCellID        @"ImageCollectionCell"
#define CollectionCellImageTag  1973

- (void)awakeFromNib
{
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    AddCornerBorder(self.avatarIMV, self.avatarIMV.bounds.size.width/2, 0.5, [UIColor lightGrayColor].CGColor);
    [self syncDataToUI];
}

- (void)setModel:(SkillRecord *)model
{
    _model = model;
    [self syncDataToUI];
}

#pragma mark- rgb生成颜色
UIColor* RGB(int r,int g,int b,float alph)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alph];
}

#define NormalTextAttr  @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13],NSForegroundColorAttributeName:RGB(110, 110, 110, 1)}
#define AtTextAttr      @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13],NSForegroundColorAttributeName:RGB(78, 135, 213, 1)}

- (void)syncDataToUI
{
    if (self.model) {
        self.dateLB.text = self.model.createTime;
        [self.avatarIMV sd_setImageWithURL:URL(self.model.headImg) placeholderImage:[UIImage imageNamed:@"org_default_avatar"]];
        self.contentLB.text = self.model.content;
        self.nameLB.text = self.model.realname;
        self.locationLB.text = self.model.location;
        [self.collectionView reloadData];
    }
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.imgs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageUrl = self.model.imgs[indexPath.row];
    UICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellID
                                                                                forIndexPath:indexPath];
    ClickImage *imageView = (ClickImage*)[imageCell viewWithTag:CollectionCellImageTag];
    AddCornerBorder(imageCell, 0, 1, [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1].CGColor);
    imageView.canClick = YES;
    [imageView sd_setImageWithURL:URL(imageUrl) placeholderImage:nil];
    return imageCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectionViewWidth = collectionView.bounds.size.width;
    CGFloat width = (collectionViewWidth-16) / 3;
    return CGSizeMake(width, width);
}

@end
