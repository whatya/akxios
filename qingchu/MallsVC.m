//
//  MallsVC.m
//  qingchu
//
//  Created by 张宝 on 16/5/25.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "MallsVC.h"
#import "UIViewController+CusomeBackButton.h"
#import "CommonConstants.h"

@interface MallsVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerLeftCST;
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIView *btnsContainerView;
@property (strong,nonatomic) NSArray *vcs;
@property (nonatomic,assign) int selectedIndex;
@property (nonatomic,strong) UIView *currentView;

@end

@implementation MallsVC

#define ProductBtn 1973
#define ServiceBtn 1974

- (void)viewDidLoad {
    [super viewDidLoad];
    //生成右边占位按钮与左边尺寸相同，保证中间视图居中
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(0, 0, 44, 44);
//    backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 16);
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
//    self.navigationItem.rightBarButtonItem = backItem;

    [self setUpBackButton];
    
    //初始化子控制器
    UIViewController *vc1 = VCFromStoryboard(@"Mall", @"ItemsVC");
    UIViewController *vc2 = VCFromStoryboard(@"Mall", @"SkillVC");
    self.vcs = @[vc1,vc2];
    
    UIButton *temp = [[UIButton alloc] init];
    temp.tag = ProductBtn;
    [self toogle:temp];
    
}
- (IBAction)search:(UIBarButtonItem *)sender
{
    NSString *searchType = self.selectedIndex == 0 ? @"商品" : @"服务";
    UIViewController *searchVC  = VCFromStoryboard(@"Mall", @"MallSearchVC");
    [searchVC setValue:searchType forKey:@"searchType"];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:searchNav animated:YES completion:NULL];
}

- (IBAction)toogle:(UIButton *)sender
{
    
    CGFloat leading = sender.tag == ProductBtn ? 0.0 : self.bannerView.width;
    self.bannerLeftCST.constant = leading;
    [UIView animateWithDuration:0.3 animations:^{
        [self.btnsContainerView layoutIfNeeded];
    }];
    
    //控制器切换
    self.selectedIndex = (int)sender.tag - 1973;
    UIViewController *selectedVC = self.vcs[self.selectedIndex];
    if ([self.view.subviews.firstObject isEqual:selectedVC.view]) {
        return;
    }
    
    if (self.currentView) {
        [self.currentView removeFromSuperview];
        [[self.childViewControllers lastObject] removeFromParentViewController];
    }
    selectedVC.view.frame = self.view.bounds;
    [self.view insertSubview:selectedVC.view atIndex:0];
    self.currentView = selectedVC.view;
    [self addChildViewController:selectedVC];
    [selectedVC didMoveToParentViewController:self];

}

@end
