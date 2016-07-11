//
//  SeverVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/6.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol severViewDelegate <NSObject>

- (void)changeButtonState:(BOOL)isSeletec;

@end


@interface SeverVC : UIViewController


@property (nonatomic,strong)id <severViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)itemsWithTitle:(NSString*)title user:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray *items))action;


@end
