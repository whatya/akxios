//
//  JSQAudioMediaItem.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/27.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "JSQAudioMediaItem.h"

#import "AppConstant.h"
#import "amrFileCodec.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UUAVAudioPlayer.h"
#import "Base64.h"
#import "NSPublic.h"

@interface JSQAudioMediaItem ()

@property (strong, nonatomic) UIImageView *cachedAudioImageView;
@property (strong, nonatomic) UILabel *countDownLabel;
@property (strong, nonatomic) NSTimer *countDownTimer;
@property (nonatomic) int playDuration;
@property (strong, nonatomic) UIImageView *iconView;

@end

@implementation JSQAudioMediaItem

#pragma mark - Initialization

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithFileURL:(NSURL *)fileURL Duration:(NSNumber *)duration
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super init];
    if (self)
    {
        _fileURL = [fileURL copy];
        _duration = duration;
        _playDuration = [duration intValue];
        _cachedAudioImageView = nil;
    }
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    _fileURL = nil;
    _cachedAudioImageView = nil;
}

#pragma mark - Setters

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setFileURL:(NSURL *)fileURL
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    _fileURL = [fileURL copy];
    _cachedAudioImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setDuration:(NSNumber *)duration
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    _duration = duration;
    _cachedAudioImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedAudioImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIView *)mediaView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    	if (self.status == STATUS_LOADING)
    	{
    		return nil;
    	}
    	//---------------------------------------------------------------------------------------------------------------------------------------------
    	if ((self.status == STATUS_FAILED) && (self.cachedAudioImageView == nil))
    	{
    		CGSize size = [self mediaViewDisplaySize];
    		BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;
    
    		UIImage *icon = [UIImage imageNamed:@"audiomediaitem_reload"];
    		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    		CGFloat ypos = (size.height - icon.size.height) / 2;
    		CGFloat xpos = (size.width - icon.size.width) / 2;
    		iconView.frame = CGRectMake(xpos, ypos, icon.size.width, icon.size.height);
    
    		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    		imageView.backgroundColor = [UIColor lightGrayColor];
    		imageView.clipsToBounds = YES;
    		[imageView addSubview:iconView];
    
    		[JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:outgoing];
    		self.cachedAudioImageView = imageView;
    	}
    	//---------------------------------------------------------------------------------------------------------------------------------------------
    	if ((self.status == STATUS_SUCCEED) && (self.cachedAudioImageView == nil))
    	{
    CGSize size = [self mediaViewDisplaySize];
    BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;
    UIColor *colorBackground = outgoing ? [UIColor jsq_messageBubbleLightGrayColor] : [UIColor colorWithRed:232/255.0 green:51/255.0 blue:52/255.0 alpha:1];
    UIColor *colorContent = outgoing ? [UIColor grayColor] : [UIColor whiteColor];
    
    UIImage *icon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:colorContent];
    self.iconView = [[UIImageView alloc] initWithImage:icon];
    CGFloat ypos = (size.height - icon.size.height) / 2;
    CGFloat xpos = outgoing ? ypos : ypos + 6;
    self.iconView.frame = CGRectMake(xpos, ypos, icon.size.width, icon.size.height);
    
    CGRect frame = outgoing ? CGRectMake(45, 10, 60, 20) : CGRectMake(51, 10, 60, 20);
    self.countDownLabel = [[UILabel alloc] initWithFrame:frame];
    self.countDownLabel.textAlignment = NSTextAlignmentRight;
    self.countDownLabel.textColor = colorContent;
    int minute	= [self.duration intValue] / 60;
    int second	= [self.duration intValue] % 60;
    self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    imageView.backgroundColor = colorBackground;
    imageView.clipsToBounds = YES;
    [imageView addSubview:self.iconView];
    [imageView addSubview:self.countDownLabel];
    
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:outgoing];
    self.cachedAudioImageView = imageView;
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return self.cachedAudioImageView;
}

- (void)startPlay
{
    NSLog(@"%@",self.voiceContent);
    if (!self.isPlaying && [self.duration intValue] > 0) {
        NSData *voiceData = [Base64 decodeString:self.voiceContent];
        NSData *waveData = DecodeAMRToWAVE(voiceData);
        if (![NSPublic shareInstance].isPlayingSound) {
            [NSPublic shareInstance].isPlayingSound = YES;
            BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;
            UIColor *colorContent = outgoing ? [UIColor grayColor] : [UIColor whiteColor];
            UIImage *icon = [[UIImage jsq_defaultStopImage] jsq_imageMaskedWithColor:colorContent];
            self.iconView.image = icon;
            
            [[UUAVAudioPlayer sharedInstance] playSongWithData:waveData];
            self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLabelAndPlayAudio) userInfo:nil repeats:YES];
        }
    }
}


- (void)updateLabelAndPlayAudio
{
    self.isPlaying = YES;
    self.playDuration = self.playDuration - 1;
    int minute	= self.playDuration / 60;
    int second	= self.playDuration % 60;
    self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    if (self.playDuration == 0) {
        [self.countDownTimer invalidate];
        self.isPlaying = NO;
        self.playDuration = [self.duration intValue];
        int minute	= [self.duration intValue] / 60;
        int second	= [self.duration intValue] % 60;
        self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
        [NSPublic shareInstance].isPlayingSound = NO;
        
        BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;
        UIColor *colorContent = outgoing ? [UIColor grayColor] : [UIColor whiteColor];
        UIImage *icon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:colorContent];
        self.iconView.image = icon;
    }
    
}

- (void)stopPlay
{
    self.isPlaying = NO;
    [self.countDownTimer invalidate];
    self.playDuration = [self.duration intValue];
    int minute	= [self.duration intValue] / 60;
    int second	= [self.duration intValue] % 60;
    self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGSize)mediaViewDisplaySize
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        return CGSizeMake(120.0f, 40.0f);
    }
    
    return CGSizeMake(120.0f, 40.0f);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)mediaHash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return self.hash;
}

#pragma mark - NSObject

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (![super isEqual:object])
    {
        return NO;
    }
    
    JSQAudioMediaItem *audioItem = (JSQAudioMediaItem *)object;
    
    return [self.fileURL isEqual:audioItem.fileURL] && [self.duration isEqualToNumber:audioItem.duration];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)hash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return super.hash ^ self.fileURL.hash;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)description
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, duration=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, self.duration, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _duration = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(duration))];
    }
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)encodeWithCoder:(NSCoder *)aCoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeObject:self.duration forKey:NSStringFromSelector(@selector(duration))];
}

#pragma mark - NSCopying

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)copyWithZone:(NSZone *)zone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQAudioMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL Duration:self.duration];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}





@end
