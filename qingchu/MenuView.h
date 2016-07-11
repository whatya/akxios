//
//  MenuView.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WSNoFound (-1)

#define LeftButtonTitle @"区域"
#define MidButtonTitle  @"专长"
#define RightButtonTitle @"职业"

typedef void (^DesBlock)(NSArray * array);
@interface WSIndexPath : NSObject

@property (nonatomic,assign) NSInteger column; //区分  0 为区域的   1 是 专长   2职业

@property (nonatomic,assign) NSInteger row; //左边第一级的行
@property (nonatomic,assign) NSInteger item; //左边第二级的行
@property (nonatomic,assign) NSInteger rank; //左边第三级的行




+ (instancetype)twIndexPathWithColumn:(NSInteger )column
                                  row:(NSInteger )row
                                 item:(NSInteger )item
                                 rank:(NSInteger )rank;

@end

@class MenuView;

@protocol MenuViewDataSource <NSObject>

- (NSInteger )dropMenuView:(MenuView *)dropMenuView numberWithIndexPath:(WSIndexPath *)indexPath Provinces:(NSArray *)provinces Cities:(NSArray *)cities Areas:(NSArray *)areas;

- (NSString *)dropMenuView:(MenuView *)dropMenuView titleWithIndexPath:(WSIndexPath *)indexPath  Provinces:(NSArray *)provinces Cities:(NSArray *)cities Areas:(NSArray *)areas;

@end

@protocol MenuViewDelegate <NSObject>

- (void)dropMenuView:(MenuView *)dropMenuView didSelectWithIndexPath:(WSIndexPath *)indexPath;

- (void)getCityName:(NSString *)string;

- (void)getOtherSideName:(NSString *)string;

-(void)touchMenu:(NSArray *)array;
@end


@interface MenuView : UIView

@property (nonatomic,weak) id<MenuViewDataSource> dataSource;
@property (nonatomic,weak) id<MenuViewDelegate> delegate;
@property (nonatomic,strong) NSArray * array;
@property(nonatomic,copy) NSString * address;
@property(nonatomic,copy) NSString * str1;
@property(nonatomic,copy) NSString * str2;
@property(nonatomic,copy) NSString * str3;
@property(nonatomic,copy) NSString * major;
@property(nonatomic,copy) NSString * userType;
@property(nonatomic,assign) long num1;
@property(nonatomic,assign) long num2;
- (void)reloadLeftTableView;

- (void)reloadMidTableView;

- (void)reloadRightTableView;

@end
