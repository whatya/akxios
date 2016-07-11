

#import "UIExtView.h"

static NSString * defaultReuseIdentifier = nil;


@implementation UIExtView

@synthesize m_ReuseIdentifier;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) 
    {
        if(nil == self.m_ReuseIdentifier)
        {
            if(nil == defaultReuseIdentifier)
            {
                defaultReuseIdentifier = [[NSString alloc] initWithString:@"m_ReuseIdentifier"]; 
            }
            self.m_ReuseIdentifier = defaultReuseIdentifier;
        }
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        if(nil == self.m_ReuseIdentifier)
        {
            self.m_ReuseIdentifier = @"m_ReuseIdentifier";
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if(self)
    {
        self.m_ReuseIdentifier = reuseIdentifier;
    }
    
    return self;
}

#pragma mark -
#pragma mark dealloc
- (void)dealloc 
{
    [m_ReuseIdentifier release];
    
    [super dealloc];
}


@end
