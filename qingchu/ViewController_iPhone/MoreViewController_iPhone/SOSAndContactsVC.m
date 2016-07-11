//
//  SOSAndContactsVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/19.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "SOSAndContactsVC.h"
#import "UIView+Toast.h"
#import "NSPublic.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "MBProgressHUD.h"

@interface SOSAndContactsVC ()<UITableViewDelegate>

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

@property (weak, nonatomic) IBOutlet UITextField *name6TF;
@property (weak, nonatomic) IBOutlet UITextField *phone6TF;

@property (weak, nonatomic) IBOutlet UITextField *name7TF;
@property (weak, nonatomic) IBOutlet UITextField *phone7TF;

@property (weak, nonatomic) IBOutlet UITextField *name8TF;
@property (weak, nonatomic) IBOutlet UITextField *phone8TF;


@end

@implementation SOSAndContactsVC

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
    
    NSLog(@"%@",contctsString);
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    NSString __block *status = nil;
    
    [HUD showAnimated:YES whileExecutingBlock:^{ // 处理耗时操作的代码块...
        
        NSArray *array0 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getImei],contctsString,[[NSPublic shareInstance]getsid],[[NSPublic shareInstance]getJSESSION],nil];
        NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"updateContactSetting.do"] with:array0 with:@"updateContactSetting.do"];
        status  =  [NSString stringWithFormat:@"%@",[dictionary0 objectForKey:@"status"]];
        
    } completionBlock:^{//回调或者说是通知主线程刷新
        [HUD removeFromSuperview];
        if ([status isEqualToString:@"0" ])
        {
            [ProgressHUD showSuccess:@"指令发送成功!" Interaction:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            [self.view makeToast:@"添加失败！" duration:1.0  position:CSToastPositionCenter ];
            return;
        }
    }];
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (NSArray*)namesArray
{
    return @[self.name1TF,self.name2TF,self.name3TF,self.name4TF,self.name5TF,self.name6TF,self.name7TF,self.name8TF];
}

- (NSArray*)phoneArray
{
    return @[self.phone1TF,self.phone2TF,self.phone3TF,self.phone4TF,self.phone5TF,self.phone6TF,self.phone7TF,self.phone8TF];
}


- (UITextField*)validateContacts
{

    for (int i = 0; i < 8; i ++) {
        
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
        
       // if (phoneTF.text.length > 0 && nameTF.text.length > 0) {
            contractStr = [contractStr stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%d,",phoneTF.text,nameTF.text,i+1]];
       // }//else{
           // contractStr = [contractStr stringByAppendingString:@"33,33,-1,"];
        //}
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
    NSArray *strings = [contactsString componentsSeparatedByString:@","];
    
    for (int i =2; i < strings.count; i+=3) {
         int index = [strings[i] intValue];
        if (index < 0) {
            continue;
        }
        UITextField *nameTF = [self namesArray][index-1];
        UITextField *phoneTF = [self phoneArray][index-1];
        
        nameTF.text = strings[i-1];
        phoneTF.text = strings[i-2];
    }
    
}

@end
