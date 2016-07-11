//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
#import "AppDelegate.h"
#import "CommonConstants.h"
#import "V2LoginTVC.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "MyMD5.h"
#import "NSPublic.h"

@interface WXApiManager ()<UIAlertViewDelegate>

@property (nonatomic,strong) NSString *imei;

@end

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}


#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {

        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSString *code = authResp.code;
        [self fethcWXTokenWithCode:code];

    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate managerDidRecvAddCardResponse:addCardResp];
        }
    }
}

- (void)onReq:(BaseReq *)req {
   if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
       ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
       WXMediaMessage *msg = showMessageReq.message;
       
       NSString *cutStr;
       NSString *imeiTemp = msg.description;
       NSScanner *scanner = [NSScanner scannerWithString:msg.description];
       [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&cutStr];
       
       if (cutStr.length > 0) {
           NSString *imei =[imeiTemp stringByReplacingOccurrencesOfString:cutStr withString:@""];
           
           //跳转到绑定页面
           
           UIViewController *addVC = VCFromStoryboard(@"More", @"AddFocusTVCForWX");
           [addVC setValue:imei forKey:@"imei"];
           
           UIViewController *rootVC =  ((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
           if ([rootVC isKindOfClass:[UINavigationController class]]) {
               UINavigationController *nav = (UINavigationController*)rootVC;
               
               if ([[nav.viewControllers firstObject] isKindOfClass:[V2LoginTVC class]]) {
                   [[Alert sharedAlert] showMessage:@"请先登录!"];
               }else{
                   [((UINavigationController*)rootVC) pushViewController:addVC animated:YES];
               }
               
           }

       }
       
       
       
   }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
    }
}

#define wxid  @"wxa316902ccb966706"
#define wxkey @"887ec5736ebc461e3c47616320e4faa5"

#define wxtoken  @"access_token"
#define wxopenid @"openid"

- (void)fethcWXTokenWithCode:(NSString*)code
{
    if (code.length == 0) {
        NSLog(@"wx code is invalid");
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",wxid,wxkey,code];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithqueryString:url callBack:^(id jsonData, NSError *error) {
        
        if (!error) {
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                NSString *token = jsonData[wxtoken];
                NSString *openid = jsonData[wxopenid];
                [self getUserInfoWithAccessToken:token andOpenId:openid];
            }
        }
        
    }];
}

- (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithqueryString:urlString callBack:^(id jsonData, NSError *error) {
        
        if (!error) {
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                [self wxEnroll:jsonData];
            }
        }
        
    }];
}

#define wxheadimgurl @"headimgurl"
#define wxnickname   @"nickname"
#define wxopenid     @"openid"
#define wxsex        @"sex"
- (void)wxEnroll:(NSDictionary*)dictionary
{
    NSString *iconUrl = dictionary[wxheadimgurl];
    NSString *nickname = dictionary[wxnickname];
    NSString *openid = dictionary[wxopenid];
    NSString *sex = [NSString stringWithFormat:@"%d",[dictionary[wxsex] intValue]];
    
    NSArray *keys = @[@"openId",@"sex",@"nickName",@"headImgUrl"];
    NSArray *vals = @[openid,sex,nickname,iconUrl];
    
    NSString *params = [[HttpManager sharedHttpManager] joinKeys:keys withValues:vals];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:@"chunhui/m/user@wxAppLogin.do" portID:80 queryString:params callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"网络错误！"];
            return ;
        }
        
        if (IsSuccessful(jsonData)) {
            NSString *username = jsonData[@"data"][@"user"];
            NSString *password = @"3chunhui";
            //1.保存用户名和密码
            [[NSPublic shareInstance]saveUserNameAndPwd:username
                                                 andPwd:password
                                                   with:@"0"
                                                   with:@"0"];
            
            ToUserDefaults(@"LoginDerectly", @(YES));
            ([UIApplication sharedApplication].delegate).window.rootViewController = VCFromStoryboard(@"Home", @"GridHomeNav");
            
        }else{
            [ProgressHUD showError:ErrorString(jsonData)];
        }
        
    }];
}

@end
