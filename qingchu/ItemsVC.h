//
//  ItemsVC.h
//  Demo
//
//  Created by ZhuXiaoyan on 16/3/9.
//  Copyright © 2016年 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
@interface ItemsVC : UIViewController<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end
