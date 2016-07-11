/********************************************************************
 文件名称 : NSPublic 实现文件
 作    者 : 张文夫
 创建时间 : 2011-08-13
 文件描述 : 初始化配置信息
 版权声明 : Copyright (C) 2011 武汉捷讯信息技术有限公司
 修改历史 : 2011-08-15      1.00    初始
 *********************************************************************/

#import "DataPublic.h"
#import "ASIHTTPRequest.h"
#import "sys/utsname.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "tooles.h"
#import "CJSONDeserializer.h"
#import "CHTermUser.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "GlobalDefine.h"

static DataPublic* kDataUtil = nil;

@implementation DataPublic
NSDictionary *heatRateDic;
NSDictionary *sportDic;
NSDictionary *locationDic;
NSDictionary *bloodPressureDic;


+ (DataPublic *)shareInstance
{
    @synchronized(self)
    {
        if (kDataUtil == nil)
        {
            kDataUtil = [[DataPublic alloc] init];
        }
    }
    return kDataUtil;
}


- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}




//1、亲人信息
-(NSString *)getRelativesInfo
{
    NSString *returnValue = @"1";
    NSArray *array0 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getUserName],nil];
    NSDictionary *dictionary0  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"getAllRelativeVt.do"] with:array0 with:@"getAllRelativeVt.do"];
    NSDictionary *userDict = [dictionary0 objectForKey:@"data"];
    NSMutableArray *termUserArray =  [[NSMutableArray alloc] init];
    if ([userDict isKindOfClass:[NSString class]]) {
        [ProgressHUD showError:@"请求过于频繁！" Interaction:YES];
        return @"1";
    }
    for (id key in userDict)
    {   //获取一个user imei的信息
        CHTermUser *termUser = [CHTermUser termUserWithDict:key];
        [termUserArray addObject:termUser];
        
        NSString *focusedImei = [[NSUserDefaults standardUserDefaults] objectForKey:@"focusedPersionImei"];
        if ([focusedImei isEqualToString:termUser.imei]) {
            [[NSPublic shareInstance]setImei:[key objectForKey:@"imei"]];
            [[NSPublic shareInstance]setname:[key objectForKey:@"name"]];
            [[NSPublic shareInstance]setrelative:[key objectForKey:@"relative"]];
            [[NSPublic shareInstance]setsim:[key objectForKey:@"sim"]];
            [[NSPublic shareInstance]setsex:[key objectForKey:@"sex"]];
            [[NSPublic shareInstance]setimage:[key objectForKey:@"image"]];
            [[NSPublic shareInstance]setMcard:[key objectForKey:@"mcard"]];
            [[NSPublic shareInstance]setUserId:[key objectForKey:@"userId"]];
        }

        returnValue = @"0";
    }
    [[NSPublic shareInstance] setTermUserArray:termUserArray];
    return returnValue;
}


//2、获取所有的设置信息
-(NSString *)getSettingInfo
{
    NSString *focusedImei = [[NSUserDefaults standardUserDefaults] objectForKey:@"focusedPersionImei"];
    CHTermUser *currentSelectedUser = [self userWithImei:focusedImei];
    if (currentSelectedUser) {
        NSArray *array1 = [[NSArray alloc] initWithObjects: currentSelectedUser.imei,currentSelectedUser.name,nil];
        NSDictionary *dictionary1  = [[NSPublic shareInstance]postURLInfoJson:[terminalURL stringByAppendingString:@"getAllSetting.do"] with:array1 with:@"getAllSetting.do"];
        NSString *status  =  [NSString stringWithFormat:  @"%@",[dictionary1 objectForKey:@"status"]];
        if ( [status isEqualToString:@"-1"] )
        {
            return @"无终端配置数据";
        }
        if (![status isEqualToString:@"0"] )
        {
            return @"获取终端配置数据失败";
        }
        
        NSDictionary *settingDict = [dictionary1 objectForKey:@"data"];
        [[NSPublic shareInstance]saveUserInfor:[settingDict objectForKey:@"pulseinterval"] with:[settingDict objectForKey:@"gpsinterval"] with:[settingDict objectForKey:@"stepinterval"] with:[settingDict objectForKey:@"pulsemax"] with:[settingDict objectForKey:@"pulsemin"]  with:[settingDict objectForKey:@"stepmax"] with:[settingDict objectForKey:@"radius"]  with:[settingDict objectForKey:@"safelat"] with:[settingDict objectForKey:@"safelon"]  with:[settingDict objectForKey:@"pulsealarm"] with:[settingDict objectForKey:@"stepalarm"]  with:[settingDict objectForKey:@"gpsalarm"] with:[settingDict objectForKey:@"pushtime"]  with:[settingDict objectForKey:@"sos"]
                                          with:[settingDict objectForKey:@"sbpmax"]  with:[settingDict objectForKey:@"sbpmin"]  with:[settingDict objectForKey:@"dbpmin"]  with:[settingDict objectForKey:@"dbpmax"] with:[settingDict objectForKey:@"bloodalarm"]
         ];
        return @"获取配置信息成功";

    }
    return nil;
}

- (CHTermUser*)userWithImei:(NSString*)imei
{
    NSArray *users = [[NSPublic shareInstance] getTermUserArray];
    for (CHTermUser *user in users){
        if ([imei isEqualToString:user.imei]) {
            return user;
        }
    }
    return nil;
}

//获取用户信息
-(NSString *)getUserInfo
{
    NSArray *array1 = [[NSArray alloc] initWithObjects: [[NSPublic shareInstance]getUserName],[[NSPublic shareInstance]getJSESSION],nil];
    NSDictionary *dictionary1  = [[NSPublic shareInstance]postURLInfoJson:[userURL stringByAppendingString:@"getUserInfo.do"] with:array1 with:@"getUserInfo.do"];
    NSString *status  =  [NSString stringWithFormat:  @"%@",[dictionary1 objectForKey:@"status"]];
    if ( [status isEqualToString:@"-1"] )
    {
        return @"系统异常";
    }
    
    NSDictionary *userDict = [dictionary1 objectForKey:@"data"];
    [[NSPublic shareInstance]saveUserInfo:[userDict objectForKey:@"real"] with:[userDict objectForKey:@"sign"] with:[userDict objectForKey:@"idcard"] with:[userDict objectForKey:@"sex"] with:[userDict objectForKey:@"image"]
     ];
    return @"获取配置信息成功";
}

//3、定时心率数据获取

-(NSDictionary*)getHeatRateInfo:(int)dayValue
{
    NSArray *array2 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getImei], [[NSPublic shareInstance]getDate:dayValue] , [[NSPublic shareInstance]getDate:dayValue], [[NSPublic shareInstance]getJSESSION],nil];
   heatRateDic  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"getPulseData.do"] with:array2 with:@"getPulseData.do"];
   return heatRateDic;
}

//4、定时定位数据获取
-(NSDictionary*)getLocationInfo:(NSString *)dateLoc with:(NSString *)dateLoc1
{
    NSArray *array3 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getImei], dateLoc , dateLoc1, [[NSPublic shareInstance]getJSESSION],nil];
    locationDic  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"getLocData.do"] with:array3 with:@"getLocData.do"];
    return locationDic;
}

//5、定时计步数据获取
-(NSDictionary*)getSportInfo:(int)dayValue
{
    NSArray *array4 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getImei], [[NSPublic shareInstance]getDate:dayValue] , [[NSPublic shareInstance]getDate:dayValue], [[NSPublic shareInstance]getJSESSION],nil];
    sportDic  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"getStepData.do"] with:array4 with:@"getStepData.do"];
    return sportDic;
}


//6、血压数据获取
-(NSDictionary*)getBloodInfo:(NSString *)pageIndex
{
    NSArray *array4 = [[NSArray alloc] initWithObjects:[[NSPublic shareInstance]getImei],pageIndex,@"15",nil];
    bloodPressureDic  = [[NSPublic shareInstance]postURLInfoJson:[dataURL stringByAppendingString:@"getBloodData.do"] with:array4 with:@"getBloodData.do"];
    return bloodPressureDic;
    
}
- (void)applicationTerminated
{
}


@end
