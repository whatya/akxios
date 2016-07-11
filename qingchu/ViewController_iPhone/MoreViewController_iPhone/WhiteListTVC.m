//
//  WhiteListTVC.m
//  qingchu
//
//  Created by 张宝 on 15/11/1.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "WhiteListTVC.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "UIView+Toast.h"
#import "HttpManager.h"

@interface WhiteListTVC ()

@property (weak, nonatomic) IBOutlet UITextField *name1TF;
@property (weak, nonatomic) IBOutlet UITextField *phone1TF;


@property (weak, nonatomic) IBOutlet UITextField *name2TF;
@property (weak, nonatomic) IBOutlet UITextField *phone2TF;

@property (weak, nonatomic) IBOutlet UITextField *name3TF;
@property (weak, nonatomic) IBOutlet UITextField *phone3TF;

@property (weak, nonatomic) IBOutlet UITextField *name4TF;
@property (weak, nonatomic) IBOutlet UITextField *phone4TF;

@property (weak, nonatomic) IBOutlet UITextField *name5TF;
@property (weak, nonatomic) IBOutlet UITextField *phone5TF;

@end

@implementation WhiteListTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self fetchMyContacts];
}

- (IBAction)savePhone:(UIBarButtonItem *)sender
{
    if (![self isOrderCorrect]) {
        [ProgressHUD showError:@"请按顺序输入联系人信息！" Interaction:YES];
        return;
    }
    
    
    UITextField *nameOrPhone = [self validateContacts];
    if (nameOrPhone) {
        [ProgressHUD showError:@"请输入正确的用户名和和电话号码！" Interaction:YES];
        [nameOrPhone becomeFirstResponder];
        return;
    }
    
    NSString *contctsString = [self connectContactsString];
    if (!contctsString) {
        return;
    }
    [ProgressHUD show:@"提交数据中..." Interaction:YES];
    NSArray *keys = @[@"imei",@"sid",@"contacts" ];
    NSArray *values = @[[[NSPublic shareInstance] getImei],
                        [[NSPublic shareInstance] getsid],
                        contctsString];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/terminal@updateContactSetting.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (!error) {
            if (IsSuccessful(jsonData)) {
                [ProgressHUD showSuccess:@"指令发送成功！"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [ProgressHUD dismiss];
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }
        }else{
            [ProgressHUD dismiss];
            [[Alert sharedAlert] showMessage:@"连接失败，请稍候再试喔！"];
        }
    }];

    
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (NSArray*)namesArray
{
    return @[self.name1TF,self.name2TF,self.name3TF,self.name4TF,self.name5TF];
}

- (NSArray*)phoneArray
{
    return @[self.phone1TF,self.phone2TF,self.phone3TF,self.phone4TF,self.phone5TF];
}


- (UITextField*)validateContacts
{
    
    for (int i = 0; i < 5; i ++) {
        
        UITextField *nameTF = [self namesArray][i];
        UITextField *phoneTF = [self phoneArray][i];
        
        if (nameTF.text.length > 0) {
            if (phoneTF.text.length < 3 || phoneTF.text.length > 12) {
                return  phoneTF;
            }
            
        }
        
        if (phoneTF.text.length > 0) {
            if (phoneTF.text.length < 3 || phoneTF.text.length > 12) {
                return  phoneTF;
            }
            if (nameTF.text.length == 0) {
                return nameTF;
            }
        }
        
    }
    return nil;
}

- (BOOL)isOrderCorrect
{
    for (int i = 0; i < [self namesArray].count; i ++) {
        for (int j = i+1; j < [self namesArray].count; j++) {
            UITextField *firstNameTF = [self namesArray][i];
            UITextField *firstPhoneTF = [self phoneArray][i];
            
            UITextField *thirdNameTF = [self namesArray][j];
            UITextField *thirdPhoneTF = [self phoneArray][j];
            
            if (firstNameTF.text.length == 0 || firstPhoneTF.text.length == 0) {
                if (thirdNameTF.text.length > 0 || thirdPhoneTF.text.length > 0) {
                    return NO;
                }
            }
            
        }
    }
    
    return YES;
}

- (UITextField*)validateContactWith:(NSInteger)index
{
    NSInteger realIndex = index;
    UITextField *nameTF = [self namesArray][realIndex];
    
    UITextField *phoneTF = [self phoneArray][realIndex];
    
    if (nameTF.text.length == 0) {
        return nameTF;
    }
    
    if (phoneTF.text.length == 0 || phoneTF.text.length != 11) {
        return phoneTF;
    }
    return nil;
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


- (NSString*)connectContactsString
{
    NSString *contractStr = @"";
    for (int i = 0; i < [self phoneArray].count; i ++) {
        UITextField *phoneTF = [self phoneArray][i];
        UITextField *nameTF = [self namesArray][i];
        if (nameTF.text.length > 0) {
            contractStr = [contractStr stringByAppendingString:[NSString stringWithFormat:@"%@,|%@|;",phoneTF.text,nameTF.text]];
        }
    }
    
    if (contractStr.length > 0) {
        return [contractStr substringToIndex:contractStr.length-1];
    }else{
        return nil;
    }
}

#pragma mark- 获取常用联系人列表
- (void)fetchMyContacts
{
    NSString *url = @"chunhui/m/terminal@getContactsSetting.do";
    NSString *queryString = [NSString stringWithFormat:@"imei=%@",[[NSPublic shareInstance] getImei]];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        [self formatData:jsonData];
    }];
}

- (void)formatData:(id)data
{
    NSDictionary *contactsDictionary = data[@"data"];
    NSString *contactsString = contactsDictionary[@"contacts"];
    NSArray *namesAndPhones = [contactsString componentsSeparatedByString:@";"];
    
    for (int i = 0; i < namesAndPhones.count; i++) {
        NSString *tempStr = namesAndPhones[i];
        NSArray *nameAndPhone = [tempStr componentsSeparatedByString:@","];
        if (nameAndPhone.count >= 2) {
            NSString *phone = nameAndPhone[0];
            NSString *unHandleName = nameAndPhone[1];
            NSString *realName = [unHandleName stringByReplacingOccurrencesOfString:@"|" withString:@""];
            
            UITextField *phoneTF = [self phoneArray][i];
            UITextField *nameTF  = [self namesArray][i];
            phoneTF.text = phone;
            nameTF.text  = realName;
        }
    }
}



@end
