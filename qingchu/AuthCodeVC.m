//
//  AuthCodeVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "AuthCodeVC.h"
#import "AuthcodeView.h"

#import "UIViewController+CusomeBackButton.h"
#import "UIViewController+DataValidation.h"
#import "CommonConstants.h"

@interface AuthCodeVC ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet AuthcodeView *codeView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBTN;

@end

@implementation AuthCodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpBackButton];
    AddCornerBorder(self.nextBTN, 5, 0, nil);
    if (self.phone) {
        self.phoneTF.text = self.phone;
    }

}
- (IBAction)textChanged:(UITextField *)sender
{
    if ([sender isEqual:self.codeTF]) {
        
        if ([self isValidCode:sender.text] && [self isValidPhone:self.phoneTF.text]) {
            [self.view endEditing:YES];
            //[self performSegueWithIdentifier:@"Reset Password Step 2" sender:nil];
        }
    }else{
        if ([self isValidPhone:self.phoneTF.text] && ![self isValidCode:self.codeTF.text]) {
            [self.codeTF becomeFirstResponder];
        }
        
        if ([self isValidPhone:self.phoneTF.text] && [self isValidCode:self.codeTF.text]){
            [self.view endEditing:YES];
           // [self performSegueWithIdentifier:@"Reset Password Step 2" sender:nil];
        }
    }
}

#pragma mark- TableView 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 70;
    }
    return 44;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark- segue 相关方法
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (![self isValidPhone:self.phoneTF.text]) {
        [self shakeAnimationForView:self.phoneTF];
        return NO;
    }
    
    if (![self isValidCode:self.codeTF.text]) {
        [self shakeAnimationForView:self.codeTF];
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
[segue.destinationViewController setValue:self.phoneTF.text forKey:@"phone"];
}

#pragma mark- 数据验证方法：电话验证、验证码验证

- (BOOL)isValidCode:(NSString*)code
{
    return [code caseInsensitiveCompare:self.codeView.authCodeStr] == NSOrderedSame;
}



@end
