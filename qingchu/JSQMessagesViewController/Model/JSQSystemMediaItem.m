//
//  JSQSystemMediaItem.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "JSQSystemMediaItem.h"
#import "UIColor+JSQMessages.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIImage+JSQMessages.h"

@interface JSQSystemMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;

@end

@implementation JSQSystemMediaItem

#pragma mark - Initialization
- (instancetype)initWithContentUrl:(NSString *)url contentTitle:(NSString *)title contentText:(NSString *)content
{
    self = [super init];
    if (self) {
        _contentTitle       =  [title copy];
        _contentUrl         =  [url copy];
        _content            =  [content copy];
        _cachedImageView    =  nil;
    }
    return self;
}

- (void)dealloc
{
    _contentUrl     = nil;
    _contentTitle   = nil;
    _cachedImageView= nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters
- (void)setContentTitle:(NSString *)contentTitle
{
    _contentTitle = [contentTitle copy];
    _cachedImageView = nil;
}

- (void)setContentUrl:(NSString *)contentUrl
{
    _contentUrl = [contentUrl copy];
    _cachedImageView = nil;
}

- (void)setContent:(NSString *)content
{
    _content = [content copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol
- (UIView *)mediaView
{
    if (self.contentUrl == nil) {
        return nil;
    }
    
    if (self.cachedImageView == nil) {
        BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;
        UIColor *colorBackground = outgoing ? [UIColor jsq_messageBubbleLightGrayColor] : [UIColor colorWithRed:232/255.0 green:51/255.0 blue:52/255.0 alpha:1];
        CGSize size = [self mediaViewDisplaySize];
        //左侧图标
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nurse"]];
        leftImageView.frame = CGRectMake(16, 40, 60, 60);
        leftImageView.clipsToBounds = YES;
        leftImageView.clipsToBounds = YES;
        leftImageView.layer.cornerRadius = 5.0;
        //顶部标题
        UILabel *rightLB = [[UILabel alloc] init];
        rightLB.text = self.contentTitle;
        rightLB.frame = CGRectMake(16, 2, size.width - 16, 30);
        rightLB.textColor = [UIColor whiteColor];
        //右侧文本
        UITextView *tv = [[UITextView alloc] init];
        tv.editable = NO;
        tv.text = self.content;
        tv.backgroundColor = [UIColor clearColor];
        tv.textColor =[UIColor whiteColor];
        tv.frame = CGRectMake(82, 30, size.width - 90, 56);
        
        UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        tempImageView.backgroundColor = colorBackground;
        self.cachedImageView = tempImageView;
        
        [tempImageView addSubview:leftImageView];
        [tempImageView addSubview:rightLB];
        [tempImageView addSubview:tv];
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:tempImageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = tempImageView;
    }
    return self.cachedImageView;
}

- (CGSize)mediaViewDisplaySize
{
    return CGSizeMake(240, 120);
}

//- (NSUInteger)mediaHash
//{
//    return self.hash;
//}
//
//- (NSUInteger)hash
//{
//    return self.hash;
//}

#pragma mark- NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _contentTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(contentTitle))];
        _contentUrl   = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(contentUrl))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.contentUrl forKey:NSStringFromSelector(@selector(contentUrl))];
    [aCoder encodeObject:self.contentTitle forKey:NSStringFromSelector(@selector(contentTitle))];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    JSQSystemMediaItem *copy = [[[self class] allocWithZone:zone] initWithContentUrl:self.contentUrl contentTitle:self.contentTitle contentText:self.content];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
