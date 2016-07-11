
#import "TFIndicatorView.h"

@interface TFIndicatorView()
{
    NSTimer *animateTimer;
    NSMutableArray *sviews;
}
@end

@implementation TFIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        sviews = [[NSMutableArray alloc] initWithCapacity:0];
        self.backgroundColor = [UIColor clearColor];
        _color = [UIColor whiteColor];
    }
    return self;
}

-(void)setNumOfObjects:(NSUInteger)numOfObjects
{
    _numOfObjects = numOfObjects;
    [sviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [sviews removeAllObjects];
    for (int i=0; i<_numOfObjects; ++i)
    {
        UIView *sview = [[UIView alloc] init];
        sview.tag = i;
        [sviews addObject:sview];
        [self addSubview:sview];
        [sview release];
    }
}

-(void)setObjectSize:(CGSize)objectSize1
{
    _objectSize = objectSize1;
    float r = MIN(self.frame.size.width, self.frame.size.height)/2;
    float wh = MAX(_objectSize.width, _objectSize.height);

    for (int i=0; i<sviews.count; ++i)
    {
        UIView *subview = sviews[i];
        subview.frame = CGRectMake(0, 0, _objectSize.width, _objectSize.height);
        subview.layer.cornerRadius = 5.0f;
        subview.center = [self pointWithDistance:(r-wh/2) Angel:M_PI_4+ M_PI*2/_numOfObjects * i];
    }
}

-(CGPoint)pointWithDistance:(float)r  Angel:(float)angel
{
    CGPoint c = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    float dy = r*sin(angel);
    float dx = r*cos(angel);
    return CGPointMake(c.x+dx, c.y+dy);
}

-(void)startAnimating
{
    if (animateTimer==nil)
    {
        animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5/(_numOfObjects/2.0) target:self selector:@selector(next) userInfo:nil repeats:YES];
    }
    self.hidden = NO;
}

-(void)stopAnimating
{
    [animateTimer invalidate];
    animateTimer = nil;
    self.hidden = YES;
}

-(void)next
{
    for (int i=0; i<sviews.count; ++i)
    {
        UIView *subview = sviews[i];
        subview.tag = subview.tag-1;
        if (subview.tag<0)
        {
            subview.tag = _numOfObjects-1;
        }
        
        float alpha = (subview.tag-_numOfObjects/4.+1)/((float)_numOfObjects);
        if (alpha<0)
        {
            alpha = 0;
        }
        subview.alpha = alpha;
        subview.backgroundColor = _color;
    }
}

- (void)dealloc
{
    [sviews release];
    [super dealloc];
}

@end
