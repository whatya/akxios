

#import "UIExtScrollView.h"


@implementation UIExtScrollView

@synthesize viewDelegate;
@synthesize viewDataSource;
@synthesize scrollType;
@synthesize extViewType;
@synthesize distanceToBounds;
@synthesize separator;
@synthesize rowspace;
@synthesize extViewDelegate;
@synthesize extViewDataSource;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    if (self) 
    {
        self.exclusiveTouch=YES;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        
        onScreenViewDic = [[NSMutableDictionary alloc] init];
        offScreenViewDic = [[NSMutableDictionary alloc] init];
        
        originPointList = [[NSMutableArray alloc] init];
        
        numberOfColumns = 0;
        numberOfRows    = 0;
        
        startIndex = 0;
        endIndex = 0;
        
        scrollType = SCROLL_VERTICAL;
        
        extViewType = SCROLL_EXTVIEW_NONE;
    }
    
    return self;
}

#pragma mark -
#pragma mark Public method implementation
- (UIExtView *)dequeueReusableCellWithIdentifier:(NSString *)identifier 
{
    if ([[offScreenViewDic allKeys] containsObject:identifier]) 
    {
        NSMutableSet *cacheSet = (NSMutableSet *)[offScreenViewDic objectForKey:identifier];
        id reused = [cacheSet anyObject];
        if (reused != nil) 
        {
            [[reused retain] autorelease];
            [cacheSet removeObject:reused];
            
            return (UIExtView *)reused;
        }
    }
    return nil;
}

#pragma mark -
- (float)contentSizeWidth 
{
    float width = distanceToBounds;
    
    numberOfColumns = viewDataSource == nil ? 0 : [viewDataSource numberOfColumnsInExtScrollView:self];
    for (int i = 0; i < numberOfColumns; i++) 
    {
        if(0 != i)
        {
            width += separator;
        }
        float itemWidth = [viewDelegate extScrollView:self widthForColumnAtIndex:i];
        width += itemWidth;
    }
    
    if(SCROLL_EXTVIEW_RIGHT == extViewType)
    {
        width += separator;
        width += viewDelegate == nil ? 0 : [extViewDelegate extScrollView:self
                                         widthForExtViewWithScrollType:extViewType];
    }

    return width;
}

- (float)contentSizeHeigt 
{
    float height = distanceToBounds + rowspace;
    
    numberOfRows = viewDataSource == nil ? 0 : [viewDataSource numberOfRowsInExtScrollView:self];
    for (int i = 0; i < numberOfRows; i++) 
    {
        float itemHeigth = [viewDelegate extScrollView:self heightForRowAtIndex:i];
        height += itemHeigth + rowspace;
    }
    
    if(SCROLL_EXTVIEW_DOWN == extViewType)
    {
        height += viewDelegate == nil ? 0 : [extViewDelegate extScrollView:self
                                         heightForExtViewWithScrollType:extViewType];
    }
    else 
    {
        height -= rowspace;
    }

    return height;
}

- (void)calculateAllItemsOrigin 
{
    float viewOrigin = distanceToBounds;
    
    if(0 != [originPointList count])
    {
        [originPointList removeAllObjects];
    }
    
    switch(scrollType)
    {
        case SCROLL_VERTICAL:
            for (int i = 0; i < numberOfRows; i++) 
            {
                [originPointList addObject:[NSNumber numberWithFloat:viewOrigin]];
                viewOrigin += [viewDelegate extScrollView:self heightForRowAtIndex:i] + rowspace;
            }
            
            if(SCROLL_EXTVIEW_DOWN == extViewType)
            {
                [originPointList addObject:[NSNumber numberWithFloat:viewOrigin]];
            }
            break;
            
        case SCROLL_HORIZONTAL:
            for (int i = 0; i < numberOfColumns; i++) {
                [originPointList addObject:[NSNumber numberWithFloat:viewOrigin]];
                viewOrigin += [viewDelegate extScrollView:self widthForColumnAtIndex:i] + separator;
            }
            
            if(SCROLL_EXTVIEW_RIGHT == extViewType)
            {
                [originPointList addObject:[NSNumber numberWithFloat:viewOrigin]];
            }
            break;
            
        default:
            LogInfo(@"UIExtScrollView scrollType error");
            break;
    }
}

- (void)reloadData 
{
    switch(scrollType)
    {
        case SCROLL_VERTICAL:
            self.contentSize = CGSizeMake(self.bounds.size.width, [self contentSizeHeigt]);
            
            [self calculateAllItemsOrigin];
            break;
            
        case SCROLL_HORIZONTAL:
            self.contentSize = CGSizeMake([self contentSizeWidth], self.bounds.size.height);
            
            [self calculateAllItemsOrigin];
            break;
            
        default:
            LogInfo(@"UIExtScrollView scrollType error");
            break;
    }
}

- (void)loadView
{
    if(viewDataSource == nil 
       || NO == [(id)viewDataSource respondsToSelector:@selector(numberOfColumnsInExtScrollView:)]
       || NO == [(id)viewDataSource respondsToSelector:@selector(numberOfRowsInExtScrollView:)])
    {
        LogInfo(@"Set data source error");
        return;
    }
    
    if(viewDelegate == nil 
       || NO == [(id)viewDelegate respondsToSelector:@selector(extScrollView:heightForRowAtIndex:)]
       || NO == [(id)viewDelegate respondsToSelector:@selector(extScrollView:widthForColumnAtIndex:)])
    {
        LogInfo(@"Set delegate error");
        return;
    }
    
    if(extViewType != SCROLL_EXTVIEW_NONE)
    {
        if(extViewDelegate == nil 
           || NO == [(id)extViewDelegate respondsToSelector:@selector(extScrollView:widthForExtViewWithScrollType:)]
           || NO == [(id)extViewDelegate respondsToSelector:@selector(extScrollView:heightForExtViewWithScrollType:)])
        {
            LogInfo(@"Set delegate for additional view error");
            return;
        }
        
        if(extViewDataSource == nil 
           || NO == [(id)extViewDataSource respondsToSelector:@selector(extScrollView:extViewWithScrollType:)])
        {
            LogInfo(@"Set data source for additional view error");
            return;
        }
    }
    
    numberOfColumns = [viewDataSource numberOfColumnsInExtScrollView:self];
    numberOfRows = [viewDataSource numberOfRowsInExtScrollView:self];
    
    [self moveAllViewsOnScreen];
    
    switch(scrollType)
    {
        case SCROLL_VERTICAL:
            self.contentSize = CGSizeMake(self.bounds.size.width, [self contentSizeHeigt]);
            break;
            
        case SCROLL_HORIZONTAL:
            self.contentSize = CGSizeMake([self contentSizeWidth], self.bounds.size.height);
            break;
            
        default:
            LogInfo(@"UIExtScrollView scrollType error");
            break;
    }
    
    [self calculateAllItemsOrigin];
    
    [self setNeedsLayout];
//    [self layoutIfNeeded];
    LogInfo(@"loadView");
}

- (void)calculateItemIndexRange 
{
    float lowerBound = 0.0f;
    float upperBound = 0.0f;
    
    startIndex    = 0;
    endIndex    = 0;
    
    switch(scrollType)
    {
        case SCROLL_VERTICAL:
        {
            lowerBound = MAX(self.contentOffset.y, 0);
            upperBound = MIN(self.contentOffset.y + self.bounds.size.height, self.contentSize.height);

            int i = 0;
            
            for (i = 0; i < numberOfRows; i++) 
            {
                    //LogInfo(@"originPointlist:%f", [[originPointList objectAtIndex:i] floatValue]);
                if ([[originPointList objectAtIndex:i] floatValue] <= lowerBound) 
                {
                    startIndex = i;
                }
                
                if ([[originPointList objectAtIndex:i] floatValue] < upperBound) 
                {
                    endIndex = i;
                }
            }
            
            if(SCROLL_EXTVIEW_DOWN == extViewType)
            {
                if ([[originPointList objectAtIndex:i] floatValue] <= lowerBound) 
                {
                    startIndex = i;
                }
                
                if ([[originPointList objectAtIndex:i] floatValue] < upperBound) 
                {
                    endIndex = i;
                }
            }
            
            break;
        }
            
        case SCROLL_HORIZONTAL:
        {
            lowerBound = MAX(self.contentOffset.x, 0);
            upperBound = MIN(self.contentOffset.x + self.bounds.size.width, self.contentSize.width);
            int i = 0;
            
            for (i = 0; i < numberOfColumns; i++) 
            {
                if ([[originPointList objectAtIndex:i] floatValue] <= lowerBound) 
                {
                    startIndex = i;
                }
                
                if ([[originPointList objectAtIndex:i] floatValue] < upperBound) 
                {
                    endIndex = i;
                }
            }
            
            if(SCROLL_EXTVIEW_RIGHT == extViewType)
            {
                if ([[originPointList objectAtIndex:i] floatValue] <= lowerBound) 
                {
                    startIndex = i;
                }
                
                if ([[originPointList objectAtIndex:i] floatValue] < upperBound) 
                {
                    endIndex = i;
                }
            }
            break;
        }
            
        default:
            LogInfo(@"UIExtScrollView scrollType error");
            break;
    }
}

- (void)moveAllViewsOnScreen
{
        //LogInfo(@"moveAllViewsOnScreen");
    
     for (NSNumber *key in [onScreenViewDic allKeys])
     {
         LogInfo(@"remove view from screen");
         
         UIExtView *view = [onScreenViewDic objectForKey:key];
         if ([[offScreenViewDic allKeys] containsObject:view.m_ReuseIdentifier]) 
         {
             NSMutableSet *viewSet = [offScreenViewDic objectForKey:view.m_ReuseIdentifier];
             [viewSet addObject:view];
         }
         else 
         {
             NSMutableSet *newSet = [NSMutableSet setWithObject:view];
             [offScreenViewDic setObject:newSet forKey:view.m_ReuseIdentifier];
         }
         
         [onScreenViewDic removeObjectForKey:key];
         [view removeFromSuperview];
     }
}

- (void)addSubviewsOnScreen 
{
    [self calculateItemIndexRange];
    
    if (0 == numberOfRows) 
    {
        return;
    }
    
    for (NSNumber *key in [onScreenViewDic allKeys]) 
    {
        int index = 0;
        
        switch(scrollType)
        {
            case SCROLL_VERTICAL:
                index = [key intValue] / numberOfColumns;
                break;
                
            case SCROLL_HORIZONTAL:
                index = [key intValue] / numberOfRows;
                break;
                
            default:
                break;
        }
        
        if (index < startIndex || index > endIndex) 
        {
            UIExtView *view = [onScreenViewDic objectForKey:key];
            
            if ([[offScreenViewDic allKeys] containsObject:view.m_ReuseIdentifier]) 
            {
                NSMutableSet *viewSet = [offScreenViewDic objectForKey:view.m_ReuseIdentifier];
                [viewSet addObject:view];
            }
            else 
            {
                NSMutableSet *newSet = [NSMutableSet setWithObject:view];
                [offScreenViewDic setObject:newSet forKey:view.m_ReuseIdentifier];
            }
            
            [onScreenViewDic removeObjectForKey:key];
            [view removeFromSuperview];
        }
    }
    
    numberOfColumns = [viewDataSource numberOfColumnsInExtScrollView:self];
    numberOfRows = [viewDataSource numberOfRowsInExtScrollView:self];
    
    for (int i = startIndex; i < endIndex + 1; i++) 
    {
        switch(scrollType)
        {
            case SCROLL_VERTICAL:
            {
                for(int j = 0; j < numberOfColumns && i != numberOfRows; j++)
                {
                    if (![[onScreenViewDic allKeys] containsObject:[NSNumber numberWithInt:(i * numberOfColumns + j)]])
                    {
                        UIExtView *view = [viewDataSource extScrollView:self 
                                                              viewAtRow:i 
                                                                 column:j];
                        
                        if(nil != view)
                        {
                            [onScreenViewDic setObject:view forKey:[NSNumber numberWithInt:(i * numberOfColumns + j)]];
                            
                            float viewWidth        = [viewDelegate extScrollView:self widthForColumnAtIndex:j];
                            float viewHeigth    = [viewDelegate extScrollView:self heightForRowAtIndex:i];

                            float viewOrigin = [[originPointList objectAtIndex:i] floatValue];
                            view.frame = CGRectMake(distanceToBounds + j * (viewWidth + separator), viewOrigin, viewWidth, viewHeigth);
                            [self addSubview:view];
                        }
                    }
                }
                
                if(i == numberOfRows)//此时有附带的额外显示view
                {
                    if (![[onScreenViewDic allKeys] containsObject:[NSNumber numberWithInt:(i * numberOfColumns + 0)]])
                    {
                        UIExtView *view = [extViewDataSource extScrollView:self 
                                                  extViewWithScrollType:extViewType];
                        
                        if(nil != view)
                        {
                            [onScreenViewDic setObject:view forKey:[NSNumber numberWithInt:(i * numberOfColumns + 0)]];
                            
                            float viewWidth        = [extViewDelegate extScrollView:self widthForExtViewWithScrollType:extViewType];
                            float viewHeigth    = [extViewDelegate extScrollView:self heightForExtViewWithScrollType:extViewType];
                            
                            float viewOrigin = [[originPointList objectAtIndex:i] floatValue];
                            view.frame = CGRectMake((int)(self.bounds.size.width - viewWidth) / 2, viewOrigin, viewWidth, viewHeigth);
                            [self addSubview:view];
                        }
                    }
                }
                break;
            }
                
            case SCROLL_HORIZONTAL:
                for(int j = 0; j < numberOfRows && i != numberOfColumns; j++)
                {
                    if (![[onScreenViewDic allKeys] containsObject:[NSNumber numberWithInt:(i * numberOfRows + j)]])
                    {
                        UIExtView *view = [viewDataSource extScrollView:self 
                                                              viewAtRow:j 
                                                                 column:i];
                        
                        if(nil != view)
                        {
                            [onScreenViewDic setObject:view forKey:[NSNumber numberWithInt:(i * numberOfRows + j)]];
                            
                            float viewWidth        = [viewDelegate extScrollView:self widthForColumnAtIndex:i];
                            float viewHeigth    = [viewDelegate extScrollView:self heightForRowAtIndex:j];
                            
                            float viewOrigin = [[originPointList objectAtIndex:i] floatValue];
                            
                            view.frame = CGRectMake(viewOrigin, distanceToBounds + j * (viewHeigth + rowspace), viewWidth, viewHeigth);
                            
                            [self addSubview:view];
                        }
                    }
                }
                
                if(i == numberOfColumns)//此时有附带的额外显示view
                {
                    if (![[onScreenViewDic allKeys] containsObject:[NSNumber numberWithInt:(i * numberOfRows + 0)]])
                    {
                        UIExtView *view = [extViewDataSource extScrollView:self 
                                                  extViewWithScrollType:extViewType];
                        
                        if(nil != view)
                        {
                            [onScreenViewDic setObject:view forKey:[NSNumber numberWithInt:(i * numberOfRows + 0)]];
                            
                            float viewWidth        = [extViewDelegate extScrollView:self widthForExtViewWithScrollType:extViewType];
                            float viewHeigth    = [extViewDelegate extScrollView:self heightForExtViewWithScrollType:extViewType];
                            
                            float viewOrigin = [[originPointList objectAtIndex:i] floatValue];
                            view.frame = CGRectMake(viewOrigin, (int)(self.bounds.size.height - viewHeigth) / 2, viewWidth, viewHeigth);
                            [self addSubview:view];
                        }
                    }
                }
                break;
                
            default:
                break;
        }
    }
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    if(viewDataSource == nil 
       || NO == [(id)viewDataSource respondsToSelector:@selector(numberOfColumnsInExtScrollView:)]
       || NO == [(id)viewDataSource respondsToSelector:@selector(numberOfRowsInExtScrollView:)])
    {
        LogInfo(@"Set data source error");
        return;
    }
    
    if(viewDelegate == nil 
       || NO == [(id)viewDelegate respondsToSelector:@selector(extScrollView:heightForRowAtIndex:)]
       || NO == [(id)viewDelegate respondsToSelector:@selector(extScrollView:widthForColumnAtIndex:)])
    {
        LogInfo(@"Set delegate error");
        return;
    }
    
    if(extViewType != SCROLL_EXTVIEW_NONE)
    {
        if(extViewDelegate == nil 
           || NO == [(id)extViewDelegate respondsToSelector:@selector(extScrollView:widthForExtViewWithScrollType:)]
           || NO == [(id)extViewDelegate respondsToSelector:@selector(extScrollView:heightForExtViewWithScrollType:)])
        {
            LogInfo(@"Set delegate for additional view error");
            return;
        }
        
        if(extViewDataSource == nil 
           || NO == [(id)extViewDataSource respondsToSelector:@selector(extScrollView:extViewWithScrollType:)])
        {
            LogInfo(@"Set data source for additional view error");
            return;
        }
    }
    
    if (numberOfColumns == 0) 
    {
        numberOfColumns = viewDataSource == nil ? 0: [viewDataSource numberOfColumnsInExtScrollView:self];
    }
    
    if (numberOfRows == 0) 
    {
        numberOfRows = viewDataSource == nil ? 0: [viewDataSource numberOfRowsInExtScrollView:self];
    }
    
    switch(scrollType)
    {
        case SCROLL_VERTICAL:
            if (self.contentSize.height == 0) 
            {
                self.contentSize = CGSizeMake(self.bounds.size.width, [self contentSizeHeigt]);
            }
            break;
            
        case SCROLL_HORIZONTAL:
            if (self.contentSize.width == 0)
            {
                self.contentSize = CGSizeMake([self contentSizeWidth], self.bounds.size.height);
            }
            break;
            
        default:
            LogInfo(@"UIExtScrollView scrollType error");
            break;
    }
    
    if ([originPointList count] == 0 && (numberOfColumns != 0 || numberOfRows != 0)) 
    {
        [self calculateAllItemsOrigin];
    }
    
    [self addSubviewsOnScreen];
}

#pragma mark -
#pragma mark UIEvent Handle method
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view 
{
    if (event.type == UIEventTypeTouches) 
    {
        UITouch *touch = (UITouch *)[touches anyObject];
        
           CGPoint point = [touch locationInView:self];
        
        switch(scrollType)
        {
            case SCROLL_VERTICAL:
            {
                for(int row = 0; row < numberOfRows; row++)
                {
                    float origin = [[originPointList objectAtIndex:row] floatValue];
                    
                    if((point.y >= origin) 
                       && (point.y <= (origin + [viewDelegate extScrollView:self heightForRowAtIndex:row])))
                    {
                        for(int column = 0; column < numberOfColumns; column++)
                        {
                            float ViewWidth = [viewDelegate extScrollView:self widthForColumnAtIndex:row];
                            
                            if(point.x >  column * (ViewWidth + separator)
                               && point.x < (column + 1) * (ViewWidth + separator) - separator)
                            {
                                if(YES == [(id)viewDelegate respondsToSelector:@selector(extScrollView:didSelectAtRow:column:)])
                                {
                                    [viewDelegate extScrollView:self didSelectAtRow:row column:column];
                                }
                                break;
                            }
                        }
                    }
                }
                break;
            }
                
            case SCROLL_HORIZONTAL:
            {
                for(int column = 0; column < numberOfColumns; column++)
                {
                    float origin = [[originPointList objectAtIndex:column] floatValue];
                    
                    if(point.x >= origin 
                       && (point.x <= (origin + [viewDelegate extScrollView:self widthForColumnAtIndex:column])))
                    {
                        for(int row = 0; row < numberOfRows; row++)
                        {
                            float viewHeigth = [viewDelegate extScrollView:self heightForRowAtIndex:row];
                            /*start modify by diaoyinghu to set the rowspace of scrollview  20120109*/
                            if(point.y >=  row * (viewHeigth + rowspace)
                               && point.y <= (column + 1) * (viewHeigth + rowspace) - rowspace)
                            {
                                if(YES == [(id)viewDelegate respondsToSelector:@selector(extScrollView:didSelectAtRow:column:)])
                                {
                                    [viewDelegate extScrollView:self didSelectAtRow:row column:column];
                                }
                                break;
                            }
                            /*end modify by diaoyinghu to set the rowspace of scrollview  20120109*/
                        }
                    }
                }
                break;
            }
                
            default:
                break;
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

#pragma mark -
#pragma mark dealloc
- (void)dealloc 
{
    [onScreenViewDic removeAllObjects];
    [offScreenViewDic removeAllObjects];
    
    [onScreenViewDic release];
    [offScreenViewDic release];
    
    [originPointList release];
    
    [super dealloc];
}


@end
