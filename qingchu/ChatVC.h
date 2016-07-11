//
//  ChatVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import "JSQMessages.h"
#import "ChatDataModel.h"
#import "Room.h"

@interface ChatVC : JSQMessagesViewController<UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (nonatomic,strong) NSString *roomId;

@property (nonatomic,strong) Room     *room;

@property (nonatomic,strong) ChatDataModel *dataModel;

@end
