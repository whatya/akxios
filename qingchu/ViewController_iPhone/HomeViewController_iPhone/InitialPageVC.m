//
//  InitialPageVC.m
//  Aitu
//
//  Created by 张宝 on 15/5/7.
//  Copyright (c) 2015年 zhangbao. All rights reserved.
//

#import "InitialPageVC.h"
#import "CommonConstants.h"

@interface InitialPageVC ()<
UIScrollViewDelegate>

#pragma mark- Properties list
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *enterBtn;

@property (nonatomic) CGFloat formerOffsetX;
//遮盖图片下方小点的空白视图的约束（图片过多，没让设计师改）
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverViewHeightConstrain;

@end

@implementation InitialPageVC

#pragma mark- VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    //页面加载的时候在userdefaults中添加标记（页面首次加载显示该页面，在appdelegate中判断）
    [[NSUserDefaults standardUserDefaults] setObject:@"used" forKey:@"firstLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self makeInitialPage];
}

#pragma mark- Deletage Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int offset = (int)scrollView.contentOffset.x;
    if (offset > Screen_Width) {
        int distance = offset - Screen_Width;
        float opacityValue = ((float)distance)/((float)Screen_Width);
        self.enterBtn.alpha = opacityValue;
    }
}


#pragma mark- Target Actions
//进入主界面
- (IBAction)enter:(UIButton *)sender {
    UIViewController *VC = VCFromStoryboard(@"Home", @"GridHomeNav");
    self.view.window.rootViewController = VC;
}


#pragma mark- Other Methods
//生成导图scrollView视图
- (void)makeInitialPage
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat contentWidth = screenSize.width * 3;
    CGFloat contentHeight = screenSize.height;
    
    self.enterBtn.alpha = 0;

    
    self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    for (int i = 0; i < 3; i++){
        NSString *imageName = [NSString stringWithFormat:@"%d%d",[self version],i];
        UIImageView *temp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        CGRect pageFrame = CGRectMake(i * screenSize.width, 0, screenSize.width, screenSize.height);
        temp.frame = pageFrame;
        [self.scrollView addSubview:temp];
    }
}

//根据屏幕高度判断设备型号
- (int)version
{
    CGRect rect = [UIScreen mainScreen].bounds;
    int screenHeight = rect.size.height;
    
    switch (screenHeight) {
        case 480:return 4;break;
        case 568:return 5;break;
        case 667:return 6;break;
        case 736:return 61;break;
        default: return 61;break;
    }
}



@end
