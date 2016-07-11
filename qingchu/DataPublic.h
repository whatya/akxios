/********************************************************************
 文件名称 : NSPublic 文件
 作    者 : 张文夫
 创建时间 : 2011-08-13
 文件描述 : 初始化配置信息
 版权声明 : Copyright (C) 2001-2011 武汉捷讯信息技术有限公司
 修改历史 : 2011-08-15      1.00    初始
 *********************************************************************/
  

@interface DataPublic : NSObject  <UIApplicationDelegate>
{
 
}
-(NSString *)getSettingInfo;
-(NSString *)getUserInfo;
-(NSDictionary*)getHeatRateInfo:(int)dayValue;
-(NSDictionary*)getLocationInfo:(NSString *)dateLoc with:(NSString *)dateLoc1;
-(NSDictionary*)getSportInfo:(int)dayValue;
-(NSString *)getRelativesInfo;
-(NSDictionary*)getBloodInfo:(NSString *)pageIndex;
+(DataPublic *)shareInstance;

@end
