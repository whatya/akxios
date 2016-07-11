

#import <Foundation/Foundation.h>
#import "UIExtView.h"

@protocol UIExtScrollViewDelegate;
@protocol UIExtScrollViewDataSource;
@protocol UIExtScrollViewExtViewDelegate;
@protocol UIExtScrollViewExtViewDataSource;

#define SCROLL_VERTICAL            (0)        //垂直滚动
#define SCROLL_HORIZONTAL        (1)        //水平滚动

#define SCROLL_EXTVIEW_NONE        (0)        //没有额外视图
#define SCROLL_EXTVIEW_DOWN        (1)        //额外视图在下面
#define SCROLL_EXTVIEW_RIGHT    (2)        //额外视图在右边

@interface UIExtScrollView : UIScrollView <UIScrollViewDelegate>
{
    NSMutableDictionary                        *onScreenViewDic;    //cache for all cells shown on screen
    NSMutableDictionary                        *offScreenViewDic;    //cache for all cells that can be reused
    
    NSUInteger                                numberOfColumns;    //total count of columns of column view
    NSUInteger                                numberOfRows;        //total count of rows of column view
    
    NSUInteger                                startIndex;            //current start index of column or row on screen
    NSUInteger                                endIndex;            //current end index of column or row on screen
    
    NSUInteger                                distanceToBounds;     // 海报区域与左右和上面的间隔
    NSUInteger                                separator;            //cell之间的间隔值

    NSUInteger                                rowspace;            //两行之间的间隔值

    id<UIExtScrollViewDelegate>                viewDelegate;        //scrollView的委托
    id<UIExtScrollViewDataSource>            viewDataSource;        //scrollView的数据源
    
    id<UIExtScrollViewExtViewDelegate>        extViewDelegate;    //scrollView中的额外视图的委托
    id<UIExtScrollViewExtViewDataSource>    extViewDataSource;    //scrollView中的额外视图的数据源
    
    NSInteger                                scrollType;            //滚动方式 0:垂直滚动 1:水平滚动
    NSInteger                                extViewType;        //增加额外视图的类型
    
    NSMutableArray                            *originPointList;    //store the view cell's left origin or top origin for all view cells
    

}

@property (nonatomic,assign)id<UIExtScrollViewDelegate>                viewDelegate;
@property (nonatomic,assign)id<UIExtScrollViewDataSource>            viewDataSource;
@property (nonatomic,assign)id<UIExtScrollViewExtViewDelegate>        extViewDelegate;
@property (nonatomic,assign)id<UIExtScrollViewExtViewDataSource>    extViewDataSource;

@property (nonatomic,assign)NSUInteger    distanceToBounds;
@property (nonatomic,assign)NSUInteger    separator;
@property (nonatomic,assign)NSUInteger    rowspace;
@property (nonatomic,assign)NSInteger    extViewType;
@property (nonatomic,assign)NSInteger    scrollType;


- (UIExtView *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)moveAllViewsOnScreen;

- (void)loadView;


@end

@protocol UIExtScrollViewDelegate <NSObject>

@optional
- (void)extScrollView:(UIExtScrollView *)columnView didSelectAtRow:(NSUInteger)row column:(NSUInteger)column;

- (CGFloat)extScrollView:(UIExtScrollView *)columnView widthForColumnAtIndex:(NSUInteger)index;

- (CGFloat)extScrollView:(UIExtScrollView *)columnView heightForRowAtIndex:(NSUInteger)index;

@end


@protocol UIExtScrollViewDataSource <NSObject>

@optional
- (NSUInteger)numberOfColumnsInExtScrollView:(UIExtScrollView *)extScrollView;

- (NSUInteger)numberOfRowsInExtScrollView:(UIExtScrollView *)extScrollView;

- (UIExtView *)extScrollView:(UIExtScrollView *)extScrollView viewAtRow:(NSUInteger)row column:(NSUInteger)column;

@end


@protocol UIExtScrollViewExtViewDelegate <NSObject>

@optional
- (CGFloat)extScrollView:(UIExtScrollView *)columnView widthForExtViewWithScrollType:(NSUInteger)scrollType;

- (CGFloat)extScrollView:(UIExtScrollView *)columnView heightForExtViewWithScrollType:(NSUInteger)scrollType;

@end

@protocol UIExtScrollViewExtViewDataSource <NSObject>

@optional

- (UIExtView *)extScrollView:(UIExtScrollView *)extScrollView extViewWithScrollType:(NSUInteger)scrollType;

@end


