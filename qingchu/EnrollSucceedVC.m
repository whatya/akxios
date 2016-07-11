//
//  EnrollSucceedVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "EnrollSucceedVC.h"
#import "CommonConstants.h"
#define GloRedCG    [UIColor colorWithRed:232/255.0 green:48/255.0 blue:52/255.0 alpha:1].CGColor
#import "UIViewController+CusomeBackButton.h"
@interface EnrollSucceedVC ()
@property (weak, nonatomic) IBOutlet UIButton *loginBTN;

@end

@implementation EnrollSucceedVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    AddCornerBorder(self.loginBTN, 5, 1, GloRedCG);
    [self setUpBackButton];
}

- (IBAction)toLoginVC:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
