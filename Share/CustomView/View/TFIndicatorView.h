
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TFIndicatorView : UIView

@property (nonatomic,assign) NSUInteger numOfObjects;
@property (nonatomic,assign) CGSize objectSize;
@property (nonatomic,retain) UIColor *color;

-(void)startAnimating;
-(void)stopAnimating;

@end
