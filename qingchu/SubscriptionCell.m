//
//  SubscriptionCell.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/25.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SubscriptionCell.h"
#import "CommonConstants.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "UIImageView+WebCache.h"

@implementation SubscriptionCell

- (void)awakeFromNib {
    AddCornerBorder(self.messageCountLB, self.messageCountLB.bounds.size.width/2, 0, nil);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClicked)];
    [self addGestureRecognizer:tap];
    AddCornerBorder(self.imv, self.imv.bounds.size.width/2, 1, [UIColor colorWithRed:211/255.0 green:71/255.0 blue:67/255.0 alpha:1].CGColor);
    AddCornerBorder(self.subscriptateBtn, 4, 1, [UIColor lightGrayColor].CGColor);
}
- (void)setRoom:(Room *)room
{
    _room = room;
    self.nameLB.text = room.roomName;
    
    if (room.roomType == 2 && room.isSubscription) {
        self.subscriptateBtn.hidden = YES;
    }else{
        self.subscriptateBtn.hidden = NO;
    }

    if (room.roomName.length > 2) {
        NSString *imageStr = [room.roomName substringToIndex:1];
        JSQMessagesAvatarImage *jsqImage = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:imageStr
                                                                                      backgroundColor:[UIColor whiteColor]
                                                                                            textColor:[UIColor colorWithRed:211/255.0 green:71/255.0 blue:67/255.0 alpha:1]
                                                                                                 font:[UIFont systemFontOfSize:22.0f]
                                                                                             diameter:self.imv.bounds.size.width];
        
        
        [self.imv sd_setImageWithURL:URL(room.imageUrl) placeholderImage:jsqImage.avatarImage options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            AddCornerBorder(self.imv, self.imv.bounds.size.width/2, 1, [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1].CGColor);
        }];
        
    }
    
    
    
    
    
    dispatch_async(kBgQueue, ^{
        int unreadCount = [self.messageService unReadCountWithRoomId:room.roomId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (unreadCount > 0) {
                self.messageCountLB.hidden = NO;
                self.messageCountLB.text = [NSString stringWithFormat:@"%d",unreadCount];
            }else{
                self.messageCountLB.text = @"0";
                self.messageCountLB.hidden = YES;
            }
        });
    });
}

- (IBAction)subscribe:(id)sender {
    WatchCellAction action = self.subscribteClick;
    if (action) {
        action(self.indexPath);
    }
}

- (void)cellClicked
{
    WatchCellAction action = self.cellTaped;
    if (action) {
        action(self.indexPath);
    }
}

#pragma mark- 惰性初始化
- (MessageService *)messageService
{
    if (!_messageService) {
        _messageService = [[MessageService alloc] init];
    }
    return _messageService;
}

@end
