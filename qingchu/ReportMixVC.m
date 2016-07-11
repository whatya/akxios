//
//  ReportMixVC.m
//  qingchu
//
//  Created by 张宝 on 16/4/15.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ReportMixVC.h"
#import "CommonConstants.h"

@interface ReportMixVC ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *banners;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic,strong) NSMutableArray *vcs;
@property (nonatomic,assign) int selectedIndex;
@property (nonatomic,strong) UIView *currentView;

@end

@implementation ReportMixVC

#define HealthBtn 1973
#define CheckBtn  1974
#define ReportBtn 1975

#define NormalColor [UIColor colorWithRed:86/255.0 green:87/255.0 blue:89/255.0 alpha:1]
#define SelectedColor [UIColor redColor]

- (void)viewDidLoad {
    [super viewDidLoad];
    UIViewController *vc1 = VCFromStoryboard(@"Home", @"HealthReportChartVC");
    UIViewController *vc2 = VCFromStoryboard(@"Home", @"HealthCheckVC");
    UIViewController *vc3 = VCFromStoryboard(@"Home", @"ReportsListVC");
    self.vcs = [[NSMutableArray alloc] initWithArray:@[vc1,vc2,vc3]];
    [self setBtnTextColors];
    [self toogle:self.buttons.firstObject];
}

- (IBAction)toogle:(UIButton *)sender
{
    self.selectedIndex = (int)sender.tag - 1973;
    UIViewController *selectedVC = self.vcs[self.selectedIndex];
    if ([self.topView.subviews.firstObject isEqual:selectedVC.view]) {
        return;
    }
    
    if (self.currentView) {
        [self.currentView removeFromSuperview];
        [[self.childViewControllers lastObject] removeFromParentViewController];
    }
    selectedVC.view.frame = self.topView.bounds;
    [self.topView insertSubview:selectedVC.view atIndex:0];
    self.currentView = selectedVC.view;
    [self addChildViewController:selectedVC];
    [selectedVC didMoveToParentViewController:self];
    
    [self allBtnsUnselect];
    sender.selected = YES;
    UIView *selectedBanner = self.banners[self.selectedIndex];
    [self allBnnersHidden];
    selectedBanner.hidden = NO;
}

- (void)setBtnTextColors
{
    for (UIButton *btn in self.buttons){
        [btn setTitleColor:NormalColor forState:UIControlStateNormal];
        [btn setTitleColor:SelectedColor forState:UIControlStateSelected];
        [btn setTintColor:[UIColor clearColor]];
    }
}

- (void)allBtnsUnselect
{
    for (UIButton * btn in self.buttons){
        btn.selected = NO;
    }
}

- (void)allBnnersHidden
{
    for (UIView *view in self.banners)
    {
        view.hidden = YES;
    }
}

@end
