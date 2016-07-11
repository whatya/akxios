//
//  WatchCell.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/14.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "WatchCell.h"
#import "CommonConstants.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "UIImageView+WebCache.h"





@implementation WatchCell

- (void)awakeFromNib {
    AddCornerBorder(self.messageCountLB, self.messageCountLB.bounds.size.width/2, 0, nil);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClicked)];
    [self addGestureRecognizer:tap];
    AddCornerBorder(self.imv, self.imv.bounds.size.width/2, 1, [UIColor colorWithRed:211/255.0 green:71/255.0 blue:67/255.0 alpha:1].CGColor);
}

- (void)setRoom:(Room *)room
{
    _room = room;
    self.nameLB.text = room.roomName;
    self.introductionLB.text = room.introduction;
    self.imv.image = nil;
    if (room.isMaster) {
        self.masterBannerImv.hidden = NO;
    }else{
        self.masterBannerImv.hidden = YES;
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
- (IBAction)add:(id)sender {
    WatchCellAction action = self.addBtnClick;
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
