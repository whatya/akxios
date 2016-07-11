//
//  RefreshView.m
//  Testself
//
//  Created by wang song on 12-9-10.
//  Copyright 2012年 . All rights reserved.
//

#import "RefreshView.h"
#import "UIColor+extend.h"

@implementation RefreshView
@synthesize refreshStatusLabel;
@synthesize refreshArrowImageView;
@synthesize isLoading;
@synthesize isDragging;
@synthesize owner;
@synthesize delegate;
float height;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //显示刷新栏当前状态的label
        UILabel *tmpLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.refreshStatusLabel = tmpLable;
        [tmpLable release];
        [refreshStatusLabel setText:REFRESH_LOADING_STATUS];
        [refreshStatusLabel setTextColor:[UIColor whiteColor]];
        [refreshStatusLabel setTextAlignment:NSTextAlignmentCenter];
        [refreshStatusLabel setBackgroundColor:[UIColor clearColor]];

        
        //刷新箭头
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.refreshArrowImageView = tmpImageView;
        [tmpImageView release];
        [refreshArrowImageView setImage:[UIImage imageNamed:@"white_arrow"]];
        
        [self addSubview:refreshStatusLabel];
        [self addSubview:refreshArrowImageView];

    }
    return self;
}

//自动调整label和箭头的位置
- (void)autoSize
{
    NSString *labelStr = REFRESH_PULL_DOWN_STATUS;
    NSDictionary *attribute = @{NSFontAttributeName: [refreshStatusLabel font]};
    CGSize size = [labelStr boundingRectWithSize:CGSizeMake(self.frame.size.width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    refreshStatusLabel.frame = CGRectMake((self.frame.size.width - size.width)/2,10,size.width,40);
    CGRect oldFrame = refreshArrowImageView.frame;
    refreshArrowImageView.frame = CGRectMake((self.frame.size.width - size.width)/2 - oldFrame.size.width - 10,5,oldFrame.size.width,oldFrame.size.height);
}
- (void)setupWithOwner:(UIScrollView *)owner_  delegate:(id)delegate_ 
{
    self.owner = owner_;
    self.delegate = delegate_;
    [owner insertSubview:self atIndex:0];
    height = self.frame.size.height;
    LogInfo(@"===%f",height);
    freshbgColor.backgroundColor = [UIColor getColor:@"ABCEE5"];
    [self autoSize];
}

// refreshView 结束加载动画
- (void)stopLoading {
    // control
    isLoading = NO;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    owner.contentInset = UIEdgeInsetsZero;
    owner.contentOffset = CGPointZero;
    self.refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];

    refreshStatusLabel.text = REFRESH_RELEASED_STATUS;
    refreshArrowImageView.hidden = NO;
}

// refreshView 开始加载动画
- (void)startLoading {
    // control
    isLoading = YES;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    owner.contentOffset = CGPointMake(0, -height);
    owner.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    refreshStatusLabel.text = REFRESH_UPDATE_TIME_PREFIX;
    refreshArrowImageView.hidden = YES;
    [UIView commitAnimations];
}
// refreshView 刚开始拖动时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}
// refreshView 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -height)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -height) {
            refreshStatusLabel.text = REFRESH_RELEASED_STATUS;
            refreshArrowImageView.transform = CGAffineTransformMakeRotation(3.14);
        } else { 
            refreshStatusLabel.text = REFRESH_PULL_DOWN_STATUS;
            refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
        }
        [UIView commitAnimations];
    }
}
// refreshView 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -height) {
        if ([delegate respondsToSelector:@selector(refreshViewDidCallBack)]) {
            [delegate refreshViewDidCallBack];
        }
    }
}

- (void)dealloc 
{
    [refreshArrowImageView release];
    [refreshStatusLabel release];
    [owner release];
    
    [super dealloc];
}
@end
