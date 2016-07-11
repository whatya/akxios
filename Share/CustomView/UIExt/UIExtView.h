


#import <UIKit/UIKit.h>


@interface UIExtView : UIView {
    
    NSString * m_ReuseIdentifier;

}

@property (nonatomic,retain)NSString * m_ReuseIdentifier;

- initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
