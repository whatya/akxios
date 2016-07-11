//
//  WatchCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/14.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room.h"
#import "MessageService.h"

typedef void(^WatchCellAction)(NSIndexPath *cellIndexPath);

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface WatchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UIImageView *masterBannerImv;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *messageCountLB;
@property (weak, nonatomic) IBOutlet UILabel *introductionLB;
@property (weak, nonatomic) IBOutlet UIView *leftContent;
@property (nonatomic,strong) Room *room;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) WatchCellAction cellTaped;
@property (nonatomic, copy) WatchCellAction addBtnClick;

@property (nonatomic, strong) MessageService *messageService;

@end

