//
//  SubscriptionCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/25.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room.h"
#import "MessageService.h"
#import "WatchCell.h"

@interface SubscriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UIButton *subscriptateBtn;
@property (weak, nonatomic) IBOutlet UILabel *messageCountLB;

@property (nonatomic,strong) Room *room;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) WatchCellAction cellTaped;
@property (nonatomic, copy) WatchCellAction subscribteClick;

@property (nonatomic, strong) MessageService *messageService;

@end
