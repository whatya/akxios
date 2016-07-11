//
//  ChatVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/21.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "ChatVC.h"
#import "MessageService.h"
#import "Message+CoreDataProperties.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "Base64.h"
#import "CommonConstants.h"
#import "amrFileCodec.h"
#import "AudiRecordView.h"
#import "RNGridMenu.h"
#import "IDMPhotoBrowser.h"
#import "JSQAudioMediaItem.h"
#import "NSPublic.h"
#import "UUAVAudioPlayer.h"
#import "JSQSystemMediaItem.h"
#import "ProgressHUD.h"
#import "RootViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ChatVC ()<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIScrollViewDelegate,
VoiceDelegate,
RNGridMenuDelegate>

@property(nonatomic, strong) NSIndexPath   *playingIndex;
@property(nonatomic, assign) int            pageIndex;
@property(nonatomic, strong) UIButton      *watchBtn;

@end

@implementation ChatVC

#pragma mark - 控制器生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showLoadEarlierMessagesHeader = NO;
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.dataModel = [[ChatDataModel alloc] init];
   // fetchRoomMembersWithRoomId:self.roomId andUserId:self.senderId completaion:^(NSError *error)
    dispatch_async(kBgQueue, ^{
        [self.dataModel fetchRoomMembersWithRoomId:self.roomId andUserId:self.senderId firstFetch:YES pageIndex:0 rowsLimit:20 completaion:^(NSError *error){
            
            for (JSQMessage *message in self.dataModel.messages){
                if (message.isMediaMessage) {
                    JSQMediaItem *mediaItem = (JSQMediaItem*)message.media;
                    mediaItem.appliesMediaViewMaskAsOutgoing = [self.senderId isEqualToString:message.senderId];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dataModel.messages.count >= 20) {
                    self.showLoadEarlierMessagesHeader = YES;
                }else{
                    self.showLoadEarlierMessagesHeader = NO;
                }
                [self.collectionView reloadData];
                [self scrollToBottomAnimated:YES];
                [self downLoadAvatars];
            });
            
            
            
        }];

    });
    
    

    self.watchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.watchBtn.frame = CGRectMake(0, 0, 30, 30);
    [self.watchBtn setImage:[UIImage imageNamed:@"showWatch"] forState:UIControlStateNormal];
    [self.watchBtn addTarget:self action:@selector(watchChat) forControlEvents:UIControlEventTouchUpInside];

    if ([self.room.imei hasPrefix:@"35"]) {
        self.watchBtn.hidden = YES;
    }
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(0, 0, 26, 26);
    [settingBtn setImage:[UIImage imageNamed:@"roomSetting"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:settingBtn],[[UIBarButtonItem alloc] initWithCustomView:self.watchBtn]];
    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    [UIMenuController sharedMenuController].menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action"
                                                                                      action:@selector(customAction:)] ];

    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:@"NewIncomingMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUI) name:@"MessagesCleared" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GotMessagesReceived) name:@"PendingMessagesReceived" object:nil];
}

- (void)GotMessagesReceived
{
    self.showLoadEarlierMessagesHeader = NO;
    dispatch_async(kBgQueue, ^{
        [self.dataModel fetchRoomMembersWithRoomId:self.roomId andUserId:self.senderId firstFetch:YES pageIndex:0 rowsLimit:20 completaion:^(NSError *error){
            
            for (JSQMessage *message in self.dataModel.messages){
                if (message.isMediaMessage) {
                    JSQMediaItem *mediaItem = (JSQMediaItem*)message.media;
                    mediaItem.appliesMediaViewMaskAsOutgoing = [self.senderId isEqualToString:message.senderId];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dataModel.messages.count >= 20) {
                    self.showLoadEarlierMessagesHeader = YES;
                }else{
                    self.showLoadEarlierMessagesHeader = NO;
                }
                [self.collectionView reloadData];
                [self scrollToBottomAnimated:YES];
                
            });
            
            
            
        }];
        
    });
}

#define ThisRedColor  [UIColor colorWithRed:233/255.0 green:59/255.0 blue:60/255.0 alpha:1]
- (void)watchChat
{
    NSArray *vcs = self.navigationController.viewControllers;
    if (vcs.count >= 2) {
        UIViewController *tempVC = vcs[vcs.count -2];
        if ([tempVC isKindOfClass:[RootViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    RootViewController *chatVC = [[RootViewController alloc] init];
    NSString *imeiTemp = self.room.imei;
    if (imeiTemp.length > 0) {
        chatVC.shouldHideWatchIcon = YES;
        chatVC.incomingImei = imeiTemp;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
        [nav.navigationBar setBarTintColor:ThisRedColor];
        [self presentViewController:nav animated:YES completion:NULL];
    }
}

- (void)clearUI
{
    self.showLoadEarlierMessagesHeader = NO;
    [self.dataModel.messages removeAllObjects];
    [self.collectionView reloadData];
}


- (void)downLoadAvatars
{
    dispatch_async(kBgQueue, ^{
        NSDictionary *urls = self.dataModel.avatarUrls;
        for (NSString *key in [urls allKeys]){
            NSString *urlString = urls[key];
            if (urlString.length > 0) {
                NSURL *imageUrl = URL(urlString);
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage *avatarImage = [UIImage imageWithData:imageData];
                if (avatarImage) {
                    JSQMessagesAvatarImage *jsqAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:avatarImage diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                    self.dataModel.avatars[key] = jsqAvatarImage;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });

    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}


#pragma mark- 导航到设置页面
- (void)more
{
    PUSH(@"Relatives", @"RoomSettingTVC", self.title, (@{@"room":self.room}), YES);
}


#pragma mark -收到新的消息
- (void)newMessageReceived:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Message *newMessageModel = [notification object];
        if (![self.room.roomId isEqualToString:newMessageModel.roomId]) {
            return ;
        }
        
        NSString *displayNameTemp = self.dataModel.users[newMessageModel.senderId];
        NSString *displayName = @" ";
        if (displayNameTemp.length > 0) {
            displayName = displayNameTemp;
        }
        
        JSQMessage *copyMessage = nil;
        if ([newMessageModel.type intValue] == 1 ||
            [newMessageModel.type intValue] == 4 ||
            [newMessageModel.type intValue] == 5 ||
            [newMessageModel.type intValue] == 9 ||
            [newMessageModel.type intValue] == 10) {
            
            copyMessage = [JSQMessage messageWithSenderId:newMessageModel.senderId
                                              displayName:displayName
                                                     text:newMessageModel.content];
            
        }else if ([newMessageModel.type intValue] == 3){
            NSData *photoData = [Base64 decodeString: newMessageModel.content];
            UIImage *photo = [UIImage imageWithData: photoData];
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
            copyMessage = [[JSQMessage alloc] initWithSenderId:newMessageModel.senderId
                                             senderDisplayName:displayName
                                                          date:newMessageModel.date
                                                         media:photoItem];
        }else if ([newMessageModel.type intValue] == 2){
            JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithFileURL:[NSURL URLWithString:@""] Duration:newMessageModel.length];
            audioItem.voiceContent = [newMessageModel content];
            copyMessage = [[JSQMessage alloc] initWithSenderId:newMessageModel.senderId
                                             senderDisplayName:displayName
                                                          date:newMessageModel.date
                                                         media:audioItem];
        }else if ([newMessageModel.type intValue] == 6)
        {
            NSString *orignalString = newMessageModel.content;
            NSArray *strings = [orignalString componentsSeparatedByString:@"^"];
            if (strings.count >= 3) {
                NSString *title = strings[0];
                NSString *content= strings[1];
                NSString *url   = strings[2];
                JSQSystemMediaItem *systemItem = [[JSQSystemMediaItem alloc] initWithContentUrl:url contentTitle:title contentText:content];
                copyMessage = [[JSQMessage alloc] initWithSenderId:newMessageModel.senderId
                                                 senderDisplayName:displayName
                                                              date:newMessageModel.date
                                                            media:systemItem];
            }else{
                return;
            }
            
        }
        else{
            return;
        }
        
        self.showTypingIndicator = !self.showTypingIndicator;
        [self scrollToBottomAnimated:YES];
        
        /**
         *  Allow typing indicator to show
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            NSString *outgoingId = newMessageModel.senderId;
            
            JSQMessage *newMessage                  = nil;
            id<JSQMessageMediaData> newMediaData    = nil;
            id newMediaAttachmentCopy               = nil;
            
            if (copyMessage.isMediaMessage) {
                /**
                 *  Last message was a media message
                 */
                id<JSQMessageMediaData> copyMediaData = copyMessage.media;
                
                if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                    
                    /**
                     *  Set image to nil to simulate "downloading" the image
                     *  and show the placeholder view
                     */
                    photoItemCopy.image = nil;
                    
                    newMediaData = photoItemCopy;
                }
                else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                    locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = [locationItemCopy.location copy];
                    
                    /**
                     *  Set location to nil to simulate "downloading" the location data
                     */
                    locationItemCopy.location = nil;
                    
                    newMediaData = locationItemCopy;
                }
                else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                    videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                    
                    /**
                     *  Reset video item to simulate "downloading" the video
                     */
                    videoItemCopy.fileURL = nil;
                    videoItemCopy.isReadyToPlay = NO;
                    
                    newMediaData = videoItemCopy;
                }
                else if ([copyMediaData isKindOfClass:[JSQAudioMediaItem class]]){
                    JSQAudioMediaItem *audioItemCopy = [((JSQAudioMediaItem*)copyMediaData) copy];
                    audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = newMessageModel.content;
                    
                    newMediaData = audioItemCopy;
                }else if ([copyMediaData isKindOfClass:[JSQSystemMediaItem class]]){
                    JSQSystemMediaItem *systemItemCopy = [((JSQAudioMediaItem*)copyMediaData) copy];
                    systemItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    
                    newMediaAttachmentCopy = [systemItemCopy.contentUrl copy];
                    newMediaData = systemItemCopy;
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
                newMessage = [JSQMessage messageWithSenderId:outgoingId
                                                 displayName:self.dataModel.users[outgoingId]
                                                       media:newMediaData];
            }
            else {
                /**
                 *  Last message was a text message
                 */
                newMessage = [JSQMessage messageWithSenderId:outgoingId
                                                 displayName:self.dataModel.users[outgoingId]
                                                        text:copyMessage.text];
            }
            
            /**
             *  Upon receiving a message, you should:
             *
             *  1. Play sound (optional)
             *  2. Add new id<JSQMessageData> object to your data source
             *  3. Call `finishReceivingMessage`
             */
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            [self.dataModel.messages addObject:newMessage];
            [self finishReceivingMessageAnimated:YES];
            
            
            if (newMessage.isMediaMessage) {
                /**
                 *  Simulate "downloading" media
                 */
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    /**
                     *  Media is "finished downloading", re-display visible cells
                     *
                     *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                     *
                     *  Reload the specific item, or simply call `reloadData`
                     */
                    
                    if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                        ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                        [self.collectionView reloadData];
                    }
                    else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                        [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                            [self.collectionView reloadData];
                        }];
                    }
                    else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                        ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                        ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                        [self.collectionView reloadData];
                    }
                    else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]){
                        ((JSQAudioMediaItem *)newMediaData).status = 3;
                        ((JSQAudioMediaItem *)newMediaData).voiceContent = newMediaAttachmentCopy;
                        [self.collectionView reloadData];
                    }
                    else if ([newMediaData isKindOfClass:[JSQSystemMediaItem class]]){
                        ((JSQSystemMediaItem *)newMediaData).contentUrl = newMediaAttachmentCopy;
                        [self.collectionView reloadData];
                    }
                    else {
                        NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                    }
                    
                });
            }
            
        });

        
    });
}



#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.dataModel.messages addObject:message];
    [self finishSendingMessageAnimated:YES];
    
    [self.dataModel.messageService saveSentMessage:@[text,date,@(0),self.roomId,self.senderId,@(1)]];
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    [self.view endEditing:YES];
    NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"相机"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_pictures"] title:@"图片"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"语音"]];
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_videos"] title:@"Videos"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_stickers"] title:@"Stickers"]];
    
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
}

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"相机"]){
        [self addCarema];
    }
    if ([item.title isEqualToString:@"语音"]){
        AudiRecordView *view = [[[NSBundle mainBundle] loadNibNamed:@"AudiRecordView" owner:self options:nil] lastObject];
        view.delegate = self;
        view.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    if ([item.title isEqualToString:@"图片"]){
        [self openPicLibrary];
    }
}

- (void)gotVoiceData:(NSData *)data withLength:(int)length
{
   //1、添加到界面 －－》2、 语音转码 －－－》3、加密为base64字符串 －－－》4、添加到本地数据库 －－－》5、发送到服务器
    NSData *audioData = EncodeWAVEToAMR(data,1,16);
    NSString *voiceString = [audioData base64EncodedStringWithOptions:0];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithFileURL:[NSURL URLWithString:@""] Duration:@(length)];
    audioItem.status = 3;
    audioItem.voiceContent = voiceString;
    
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:self.senderId
                                                   displayName:self.senderDisplayName
                                                         media:audioItem];
    [self.dataModel.messages addObject:audioMessage];
    [self finishSendingMessageAnimated:YES];
    
    dispatch_async(kBgQueue, ^{
        
        [self.dataModel.messageService saveSentMessage:@[voiceString,[NSDate date],@(length),self.roomId,self.senderId,@(2)]];
    });


}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataModel.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataModel.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.dataModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.dataModel.outgoingBubbleImageData;
    }
    
    return self.dataModel.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.dataModel.messages objectAtIndex:indexPath.item];
    
    JSQMessagesAvatarImage *avatar = [self.dataModel.avatars objectForKey:message.senderId];
    if (avatar) {
        return avatar;
    }else{
        JSQMessagesAvatarImage *jsqImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profileUserAvatar"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        return jsqImage;
    }
    
    return [self.dataModel.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.dataModel.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.dataModel.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.dataModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    NSString *displayNameTemp = message.senderDisplayName;
    if (displayNameTemp.length > 0) {
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }else{
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.dataModel.messages objectAtIndex:indexPath.item];
    
    
    
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
            
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.dataModel.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.dataModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events
#pragma mark - 分页获取数据
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
    
    int pageIndex = (int)(self.dataModel.messages.count);
    
    [self.dataModel.messageService.coreDataHelper saveContext];
    
    [self.dataModel fetchRoomMembersWithRoomId:self.roomId andUserId:self.senderId firstFetch:NO pageIndex:pageIndex rowsLimit:20 completaion:^(NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"没有更多数据!"];
            return ;
        }
        
        for (JSQMessage *message in self.dataModel.messages){
            if (message.isMediaMessage) {
                JSQMediaItem *mediaItem = (JSQMediaItem*)message.media;
                mediaItem.appliesMediaViewMaskAsOutgoing = [self.senderId isEqualToString:message.senderId];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            
        });

    }];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    
    JSQMessage *jsqMessage = self.dataModel.messages[indexPath.row];
    if (jsqMessage.isMediaMessage) {
        JSQMediaItem *mediaItem = (JSQMediaItem*)jsqMessage.media;
        if ([mediaItem isKindOfClass:[JSQPhotoMediaItem class]]) {
            JSQPhotoMediaItem *photoMedia = (JSQPhotoMediaItem*)mediaItem;
            NSArray *photos = [IDMPhoto photosWithImages:@[photoMedia.image]];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
            [self presentViewController:browser animated:YES completion:nil];

        }else if ([mediaItem isKindOfClass:[JSQAudioMediaItem class]]){
            JSQAudioMediaItem *audioMedia = (JSQAudioMediaItem*)mediaItem;
            [audioMedia startPlay];
        }else if ([mediaItem isKindOfClass:[JSQSystemMediaItem class]]){
            JSQSystemMediaItem *systemMedia = (JSQSystemMediaItem*)mediaItem;
            PUSH(@"Relatives", @"PointsVC", @"", @{@"urlString":systemMedia.contentUrl}, YES);
        }
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [NSPublic shareInstance].isPlayingSound = NO;
    [[UUAVAudioPlayer sharedInstance] stopSound];
    [self.dataModel.messageService clearCountWithConverationId:self.roomId];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title = self.room.roomName;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.dataModel.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark- 选择图片
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}
#define ThisRedColor  [UIColor colorWithRed:233/255.0 green:59/255.0 blue:60/255.0 alpha:1]
-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.navigationBar.barTintColor = ThisRedColor;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        
        //1、添加到界面 --》 2、将图片转为base64字符串 --》 3、保存到数据库 --》4、发送到服务器
        
        //1、添加到界面
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:editImage];
        JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                       displayName:self.senderDisplayName
                                                             media:photoItem];
        [self.dataModel.messages addObject:photoMessage];
        [self finishSendingMessageAnimated:YES];
        
        dispatch_async(kBgQueue, ^{
            //2、将图片转为字符串
            NSString *userImageStr = [Base64 stringByEncodingData:[self compressImage:editImage toMaxFileSize:40*1024]];
           // NSString *userImageStr = [Base64 stringByEncodingData:UIImageJPEGRepresentation(editImage, 0.5)];
            
            //3、4 保存本地并发送
            [self.dataModel.messageService saveSentMessage:@[userImageStr,[NSDate date],@(0),self.roomId,self.senderId,@(3)]];
        });
        
        
    }];
}

- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
