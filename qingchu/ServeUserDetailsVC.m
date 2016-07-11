//
//  ServeUserDetailsVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ServeUserDetailsVC.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "NSPublic.h"
#import "V2LoginTVC.h"
#import "Order.h"
#import "ServeCashVC.h"
#import "SkillShareParam.h"
@interface ServeUserDetailsVC ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *realNameLB;
@property (weak, nonatomic) IBOutlet UILabel *rankLB;
@property (weak, nonatomic) IBOutlet UILabel *sexLB;
@property (weak, nonatomic) IBOutlet UILabel *addressLB;
@property (weak, nonatomic) IBOutlet UILabel *majorLB;
@property (weak, nonatomic) IBOutlet UILabel *yearLB;
@property (weak, nonatomic) IBOutlet UITextView *information;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *numsLB;

@end

//doctor@getDoctorInfo获取医生（健康管理师）个人信息

#define SUser_userType             @"userType"
#define SUser_user                 @"user"
#define SUser_real                 @"real"
#define SUser_sex                  @"sex"
#define SUser_birthday             @"birthday"
#define SUser_area                 @"area"
#define SUser_address              @"address"
#define SUser_imageUrl             @"imageUrl"
#define SUser_credeimageUrl        @"credeimageUrl"
#define SUser_major                @"major"
#define SUser_introduce            @"introduce"
#define SUser_allUsers             @"allUsers"
#define SUser_currentUsers         @"currentUsers"
#define SUser_data                 @"data"



@implementation ServeUserDetailsVC



- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self serveUserInformationWithUser:self.username];
    if (_hide==YES) {
        _nextBtn.hidden = YES;
        _nextBtn.userInteractionEnabled = NO;
    }
    _userImage.layer.cornerRadius = 50;
    _userImage.layer.masksToBounds = YES;
}

#pragma mark - 获取医生（健康管理师）个人信息
- (void)serveUserInformationWithUser:(NSString *)user{

    NSArray *keys = @[@"user"];
    NSArray *values = @[user];
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/doctor@getDoctorInfo.do";
     //NSString * apiString = @"appservice.mtkjybm.com/doctor@getDoctorInfo.do";
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (!error) {
            //value	__NSCFString *	@"17771774007"	0x00007f83b5cb1190
            if (IsSuccessful(jsonData)) {
                
               NSDictionary *data = jsonData[SUser_data];
                int  userType = [data[SUser_userType] floatValue];
                NSString *realname = data[SUser_real];
                NSString *sex      = data[SUser_sex];
                NSString *imageUrl = data[SUser_imageUrl];
                double    year     = [data[SUser_birthday] floatValue];
                NSString *address  = data[SUser_address];
                NSString *area     = data[SUser_area];
                int       major    = [data[SUser_major] floatValue];
                NSString *introduce  = data[SUser_introduce];
               // NSString *allUser   = data[SUser_allUsers];
                 int  currentUsers = [data[SUser_currentUsers] floatValue];
                
                [self.userImage sd_setImageWithURL:URL(imageUrl) placeholderImage:[UIImage imageNamed:@"profileUserAvatar"]];
                self.realNameLB.text = realname;
                
                if (userType == 2) {
                    
                    self.rankLB.text = @"医生";
                }
                if (userType == 3) {
                    
                    self.rankLB.text = @"健康管理师";
                }

                
                if (major == 1) {
                    
                    self.majorLB.text = @"全科";
                }
                if (major == 2) {
                    
                    self.majorLB.text = @"心脑血管";
                }
                if (major == 3) {
                    
                    self.majorLB.text = @"糖尿病";
                }

                self.sexLB.text = sex;
                
                self.yearLB.text = [NSString stringWithFormat:@"%.f岁",(20161212-year)*0.0001];
                
                self.addressLB.text = [NSString stringWithFormat:@"%@ %@",area,address];
                self.numsLB.text  = [NSString stringWithFormat:@"已服务%d人",currentUsers];
                self.information.text = introduce;
            }else{
                [[Alert sharedAlert] showMessage:ErrorString(jsonData)];
            }

        }else{
            [[Alert sharedAlert] showMessage:@"连接失败，请稍后再试喔！"];
        }

    }];
}
-(IBAction)nextBtn:(id)sender
{
    [[NSPublic shareInstance] saveDocotorName:self.realNameLB.text];
    ServeCashVC *serveDetailVC = [[UIStoryboard storyboardWithName:@"Service" bundle:nil] instantiateViewControllerWithIdentifier:@"ServeCashVC"];
    
    serveDetailVC.inputServeOrder = [SkillShareParam sharedSkill].order;
    [self.navigationController pushViewController:serveDetailVC animated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(UIStoryboardSegue *) segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ServeCashVC"]) {
        
        if ([[NSPublic shareInstance]getUserName].length == 0) {
            
            UINavigationController *VC = VCFromStoryboard(@"AppEntrance", @"LoginVCNav");
            V2LoginTVC *loginVC = VC.viewControllers.firstObject;
            loginVC.shouldShowBackBtn = YES;
            [self presentViewController:VC animated:YES completion:NULL];
            
            return NO;
        }
        
        return YES;
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
