/********************************************************************
 文件名称 : NSPublic 实现文件
 作    者 : 张文夫
 创建时间 : 2011-08-13
 文件描述 : 初始化配置信息
 版权声明 : Copyright (C) 2011 武汉捷讯信息技术有限公司
 修改历史 : 2011-08-15      1.00    初始
 *********************************************************************/

#import "NSPublic.h"
#import "ASIHTTPRequest.h"
#import "sys/utsname.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "tooles.h"
#import "CJSONDeserializer.h"
#import "NSDate+Additions.h"
#import "sys/utsname.h"
#import "MyMD5.h"
#import "ASIFormDataRequest.h"
#import "GlobalDefine.h"

static NSPublic* kPublicUtil = nil;

@implementation NSPublic
NSString * JSESSIONValue;


+ (NSPublic*)shareInstance
{
	@synchronized(self)
	{
		if (kPublicUtil == nil)
		{
			kPublicUtil = [[NSPublic alloc] init]; 
		}
	}
	return kPublicUtil;
}

-(void)setheartCommArray:(NSMutableArray*) array
{
    heartCommArray = [NSMutableArray array];
    [heartCommArray removeAllObjects];
    heartCommArray=array;
}

- (NSString *)getMcard
{
    return  mcard;
}

- (void)setMcard:(NSString *)card
{
    mcard = card;
}

-(NSMutableArray*)getheartCommArray
{
    return heartCommArray;
}


-(void)setTermUserArray:(NSMutableArray*) array
{
    termUserArray = [NSMutableArray array];
    [termUserArray removeAllObjects];
    termUserArray = array;
}

-(NSMutableArray*)getTermUserArray
{
    return termUserArray;
}

-(double)distanceBetweenOrderBy:(double)lat1 :(double)lat2 :(double)lng1 :(double)lng2{
    double dd = M_PI/180;
    double x1=lat1*dd,x2=lat2*dd;
    double y1=lng1*dd,y2=lng2*dd;
    double R = 6367.229;
    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));

    return distance*1000;
    
}



//    NSMutableArray *lowBloodCommArray;
//NSMutableArray *highBloodCommArray;
-(void)setBloodCommArray:(NSMutableArray*) array0 with:(NSMutableArray*) array1
{
    lowBloodCommArray = [NSMutableArray array];
    [lowBloodCommArray removeAllObjects];
    lowBloodCommArray=array0;
    
    highBloodCommArray = [NSMutableArray array];
    [highBloodCommArray removeAllObjects];
    highBloodCommArray=array1;
}


-(NSMutableArray*)getlowBloodCommArray
{
    return lowBloodCommArray;
}

-(NSMutableArray*)gethighBloodCommArray
{
    return highBloodCommArray;
}

-(BOOL)isCHDevice
{
    NSString *prex = [imei substringToIndex:2];
    return [prex isEqualToString:@"88"];
}

-(BOOL)getDeviceInfo
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone2,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone4,1"])    return YES;
    if ([deviceString isEqualToString:@"iPad2,2"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,3"])      return YES;
    if ([deviceString isEqualToString:@"iPad3,1"])      return YES;
    if ([deviceString isEqualToString:@"iPad3,2"])      return YES;
    if ([deviceString isEqualToString:@"iPad3,3"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,1"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,2"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,3"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,1"]) return YES;
    if ([deviceString isEqualToString:@"iPad2,2"]) return YES;
    if ([deviceString isEqualToString:@"iPad2,3"]) return YES;
    if ([deviceString isEqualToString:@"iPad2,4"]) return YES;
    if ([deviceString isEqualToString:@"iPad2,5"]) return YES;
    if ([deviceString isEqualToString:@"iPad2,6"]) return YES;
    if ([deviceString isEqualToString:@"iPad2,7"]) return YES;
    if ([deviceString isEqualToString:@"iPad3,1"]) return YES;
    if ([deviceString isEqualToString:@"iPad3,2"]) return YES;
    if ([deviceString isEqualToString:@"iPad3,3"]) return YES;
    if ([deviceString isEqualToString:@"iPad3,4"]) return YES;
    if ([deviceString isEqualToString:@"iPad3,5"]) return YES;
    if ([deviceString isEqualToString:@"iPad3,6"]) return YES;
    if ([deviceString isEqualToString:@"iPad4,1"]) return YES;
    if ([deviceString isEqualToString:@"iPad4,2"]) return YES;
    if ([deviceString isEqualToString:@"iPad4,3"]) return YES;
    if ([deviceString isEqualToString:@"iPad4,4"]) return YES;
    if ([deviceString isEqualToString:@"iPad4,5"]) return YES;
    if ([deviceString isEqualToString:@"iPad4,6"]) return YES;
    if ([deviceString isEqualToString:@"iPad5,1"]) return YES;
    if ([deviceString isEqualToString:@"iPad5,2"]) return YES;
    if ([deviceString isEqualToString:@"iPad5,3"]) return YES;
    if ([deviceString isEqualToString:@"iPad5,4"]) return YES;
    if ([deviceString isEqualToString:@"iPad5,5"]) return YES;
    if ([deviceString isEqualToString:@"iPad5,6"]) return YES;
    if ([deviceString isEqualToString:@"x86_64"])      return YES;
    return NO;
}

- (id)init
{
	if (self = [super init]) 
	{
         
	}
	return self;
}




-(void)setCommArray:(NSArray *)arr
{
    commArray = arr;
}


-(NSArray *)getCommArray
{
    return  commArray  ;
}

-(int)compsDays:(NSDate *)fromdate with:(NSDate *)todate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:fromdate  toDate:todate  options:0];
    int days = [comps day];
    return days;
}


//从HTTP提交参数后，返回Json格式数据 pageIndex=页码&pageSize=行数
-(NSData *)getURLInfoJson:(NSString *)url
{
    url =  [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
    NSURL *requestURL = [NSURL URLWithString:url];//
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:requestURL];
    //开始同步请求
    request.delegate = self;
    [request startSynchronous];
    
    NSData *data =[request responseData]; 
    return data;
    
}



//从HTTP Post提交
-(NSDictionary *)postURLInfoJson:(NSString *)urlString with:(NSArray *)array with:(NSString *)keyValue
{
    ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSArray *propArray = [self getSubmitProperty:keyValue];
 
    NSLog(@"\n");
    NSLog(@"--------------------------------------------%@:",keyValue);
    NSLog(@"请求参数：");
    NSLog(@"{");
    for (int i=0; i<[array count]; i++) {
    
        [requestForm setPostValue:[array objectAtIndex:i] forKey:  [propArray objectAtIndex:i]];
         NSLog(@"   %@  :  %@",[propArray objectAtIndex:i],[array objectAtIndex:i]);
        
    }
    NSLog(@"}");
    [requestForm startSynchronous];
    
     //得到JSESSIONID值
    NSDictionary *cookieDict = requestForm.responseHeaders;
    NSString * cookieStr = [cookieDict objectForKey:@"Set-Cookie"];
    if (cookieDict!=nil) {
        NSArray *_arr0 = [cookieStr componentsSeparatedByString:@";"];
        NSString * JSESSIONID = [_arr0 objectAtIndex:0];
        NSArray *_arr1 = [JSESSIONID componentsSeparatedByString:@"="];
        if(JSESSIONValue == nil)
        {
           JSESSIONValue = [_arr1 objectAtIndex:1]; 
        }
    }
    
    NSData *data =[requestForm responseData];
    
    
    
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
    
    //判读如果超时则重新登录
    NSString *status  =  [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"status"]];
    
    if (!dictionary) {
        NSString *resultString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSLog(@"请求出错：%@",resultString);
    }
    
    NSLog(@"状态值:%@",status);
    
     
    if ([status isEqualToString:@"-19"] || [status isEqual: [NSNull null]])
    {
        NSArray *arraytmp = [[NSArray alloc] initWithObjects:[self getUserName], [MyMD5 md5:[self getPwd]],[[NSPublic shareInstance]getUserTXId],  @"fbd394e2ccc5c8c0ed2ac0a0",@"21f606e2aef6e3cbcb5fe086",@"4",nil];
         [[NSPublic shareInstance]postURLInfoJson02:[userURL stringByAppendingString:@"login.do"] with:arraytmp with:@"login.do"];
        return  [[NSPublic shareInstance]postURLInfoJson:urlString  with:array with:keyValue];
        
    }
    return dictionary;
}


//从HTTP Post提交
-(void)postURLInfoJson02:(NSString *)urlString with:(NSArray *)array with:(NSString *)keyValue
{
    ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSArray *propArray = [self getSubmitProperty:keyValue];
    
    for (int i=0; i<[array count]; i++) {
        
        [requestForm setPostValue:[array objectAtIndex:i] forKey:  [propArray objectAtIndex:i]];
        //NSLog(@"%@--%@",[propArray objectAtIndex:i],[array objectAtIndex:i]);
        
    }
    [requestForm startSynchronous];
    
}




// NSString值为Unicode格式的字符串编码(如\u7E8C)转换成中文
//unicode编码以\u开头

-(NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable
                                                                    format:NULL errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}


-(NSString *)getJSESSION
{
    return JSESSIONValue;
}


//pageIndex

-(NSString *)getpageIndex
{
    return pageIndex ;
}

-(void)setpageIndex:(NSString *)parampageIndex
{
    pageIndex =parampageIndex;
}


-(NSString *)getsendPageIndex
{
    return sendPageIndex ;
}

-(void)setsendPageIndex:(NSString *)paramsendPageIndex
{
    sendPageIndex =paramsendPageIndex;
}





-(NSString *)getImei
{
    return imei ;
}

-(void)setImei:(NSString *)paramImei
{
    imei =paramImei;
}

-(void)setrelative:(NSString *)paramrelative
{
    relative =paramrelative;
}


-(void)setimage:(NSString *)imageparam
{
    image = imageparam;
}


-(NSString *)getimage
{
    return  image;
}



-(void)setsex:(NSString *)sexparam
{
    sex = sexparam;
}
 

-(NSString *)getsex
{
    return  sex;
}

-(void)setname:(NSString *)paramname
{
    name =paramname;
}


-(void)setsim:(NSString *)paramsim
{
    sim = paramsim;
}

-(NSString *)getsim
{
    return sim;
}


-(NSString *)getname
{
    return name ;
}

-(NSString *)getrelative
{
    return relative ;
}


-(void)saveUserNameAndPwd:(NSString *)userName andPwd:(NSString *)pwd with:(NSString *)isShowLoginInfo with:(NSString *)isAutoLogin
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"UserName"];
    [settings removeObjectForKey:@"Password"];
    [settings removeObjectForKey:@"isShowLoginInfo"];
    [settings removeObjectForKey:@"isAutoLogin"];
    
    [settings setObject:userName forKey:@"UserName"];
    [settings setObject:pwd forKey:@"Password"];
    [settings setObject:isShowLoginInfo forKey:@"isShowLoginInfo"];
    [settings setObject:isAutoLogin forKey:@"isAutoLogin"];
    [settings synchronize];
}



-(void)saveUserNameAndPwd:(NSString *)userName andPwd:(NSString *)pwd  
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"UserName"];
    [settings removeObjectForKey:@"Password"];
    
    [settings setObject:userName forKey:@"UserName"];
    [settings setObject:pwd forKey:@"Password"];
    [settings synchronize];
}


-(NSString *)getAutoLogin
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"isAutoLogin"];
}

-(NSString *)getShowLoginInfo
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"isShowLoginInfo"];
}

-(NSString *)getUserImage
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"userImage"];
}

- (void)setUserImage:(NSString*)userImage
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:userImage forKey:@"userImage"];
    [settings synchronize];
}

-(void)saveUserInfor:(NSString *)pulseinterval with:(NSString *)gpsinterval with:(NSString *)stepinterval with:(NSString *)pulsemax with:(NSString *)pulsemin  with:(NSString *)stepmax with:(NSString *)radius  with:(NSString *)safelat with:(NSString *)safelon  with:(NSString *)pulsealarm with:(NSString *)stepalarm  with:(NSString *)gpsalarm with:(NSString *)pushtime  with:(NSString *)sos
                with:(NSString *)sbpmax with:(NSString *)sbpmin with:(NSString *)dbpmin with:(NSString *)dbpmax with:(NSString *)bloodalarm
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"sbpmax"];
    [settings removeObjectForKey:@"sbpmin"];
    [settings removeObjectForKey:@"dbpmin"];
    [settings removeObjectForKey:@"dbpmax"];
    
    [settings removeObjectForKey:@"pulseinterval"];
    [settings removeObjectForKey:@"gpsinterval"];
    [settings removeObjectForKey:@"stepinterval"];
    [settings removeObjectForKey:@"pulsemax"];
    [settings removeObjectForKey:@"pulsemin"];
    [settings removeObjectForKey:@"stepmax"];
    [settings removeObjectForKey:@"radius"];
    [settings removeObjectForKey:@"safelat"];
    [settings removeObjectForKey:@"safelon"];
    [settings removeObjectForKey:@"pulsealarm"];
    [settings removeObjectForKey:@"stepalarm"];
    [settings removeObjectForKey:@"gpsalarm"];
    [settings removeObjectForKey:@"pushtime"];
    [settings removeObjectForKey:@"sos"];
    [settings removeObjectForKey:@"bloodalarm"];
    
    
    [settings setObject:sbpmax forKey:@"sbpmax"];
    [settings setObject:sbpmin forKey:@"sbpmin"];
    [settings setObject:dbpmax forKey:@"dbpmax"];
    [settings setObject:dbpmin forKey:@"dbpmin"];
    
    [settings setObject:pulseinterval forKey:@"pulseinterval"];
    [settings setObject:gpsinterval forKey:@"gpsinterval"];
    [settings setObject:pulsemax forKey:@"stepinterval"];
    [settings setObject:pulsemax forKey:@"pulsemax"];
    [settings setObject:pulsemin forKey:@"pulsemin"];
    [settings setObject:stepmax forKey:@"stepmax"];
    [settings setObject:radius forKey:@"radius"];
    [settings setObject:safelat forKey:@"safelat"];
    
   
    [settings setObject:safelon forKey:@"safelon"];
    [settings setObject:pulsealarm forKey:@"pulsealarm"];
    [settings setObject:stepalarm forKey:@"stepalarm"];
    [settings setObject:gpsalarm forKey:@"gpsalarm"];
    [settings setObject:bloodalarm forKey:@"bloodalarm"];
    
    [settings setObject:pushtime forKey:@"pushtime"];
    [settings setObject:sos forKey:@"sos"];
    [settings synchronize];
}

-(void)saveUserInfo:(NSString *)real with:(NSString *)sign with:(NSString *)idcard with:(NSString *)userSex with:(NSString *)userImage
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"real"];
    [settings removeObjectForKey:@"sign"];
    [settings removeObjectForKey:@"idcard"];
    [settings removeObjectForKey:@"userSex"];
    [settings removeObjectForKey:@"userImage"];
    
    [settings setObject:real forKey:@"real"];
    [settings setObject:sign forKey:@"sign"];
    [settings setObject:idcard forKey:@"idcard"];
    [settings setObject:userSex forKey:@"userSex"];
    [settings setObject:userImage forKey:@"userImage"];
    
    [settings synchronize];
}

//with:(NSString *)sbpmax with:(NSString *)sbpmin with:(NSString *)dbpmin with:(NSString *)dbpmax

-(NSString *)getdbpmin
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"dbpmin"];
}


-(NSString *)getbloodalarm
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"bloodalarm"];
}

-(NSString *)getdbpmax
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"dbpmax"];
}

-(NSString *)getsbpmax
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"sbpmax"];
}

-(NSString *)getsbpmin
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"sbpmin"];
}


-(NSString *)getpulseinterval
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"pulseinterval"];
}


-(NSString *)getgpsinterval
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"gpsinterval"];
}
-(NSString *)getpulsemax
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"pulsemax"];
}
-(NSString *)getstepinterval
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"stepinterval"];
}
-(NSString *)getpulsemin
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"pulsemin"];
}
-(NSString *)getstepmax
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"stepmax"];
}


-(NSString *)getradius
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"radius"];
}

-(NSString *)getsafelat
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"safelat"];
}

-(NSString *)getsafelon
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"safelon"];
}

-(NSString *)getpulsealarm
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
 
    return [settings objectForKey:@"pulsealarm"];
}

-(NSString *)getstepalarm
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"stepalarm"];
}



-(NSString *)getgpsalarm
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
 ;
    return [settings objectForKey:@"gpsalarm"];
}

-(NSString *)getpushtime
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"pushtime"];
}

-(NSString *)getsos
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"sos"];
}

//-----------------------end------------------------


-(NSString *)getUserName
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"UserName"];
}

-(void)saveServerId:(NSString *)serverId{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"serverId"];
    [settings setObject:serverId forKey:@"serverId"];
    [settings synchronize];
}
-(NSString *)getServerId
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"serverId"];
}

-(void)saveReceiverId:(NSString *)receiverId{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"receiverId"];
    [settings setObject:receiverId forKey:@"receiverId"];
    [settings synchronize];
}
-(NSString *)getReceiverId
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"receiverId"];
}

-(void)saveDoctorId:(NSString *)doctorId{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"doctorId"];
    [settings setObject:doctorId forKey:@"doctorId"];
    [settings synchronize];
}
-(NSString *)getDoctorId
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"doctorId"];
}

-(void)savePayNum:(NSString *)payNum{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"payNum"];
    [settings setObject:payNum forKey:@"payNum"];
    [settings synchronize];
}
-(NSString *)getPayNum
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"payNum"];
}

-(void)saveServerUsername:(NSString *)serverUsername{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"serverUsername"];
    [settings setObject:serverUsername forKey:@"serverUsername"];
    [settings synchronize];
}
-(NSString *)getServerUsername
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"serverUsername"];
}

-(void)saveDocotorName:(NSString *)docotorName{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"docotorName"];
    [settings setObject:docotorName forKey:@"docotorName"];
    [settings synchronize];
}
-(NSString *)getDocotorName
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"docotorName"];
}

-(void)saveServerImage:(NSString *)serverImage{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"serverImage"];
    [settings setObject:serverImage forKey:@"serverImage"];
    [settings synchronize];
}
-(NSString *)getServerImage
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"serverImage"];
}

-(void)saveServerName:(NSString *)serverName{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"serverName"];
    [settings setObject:serverName forKey:@"serverName"];
    [settings synchronize];
}
-(NSString *)getServerName
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"serverName"];
}

-(NSString *)getUserTXId
{    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"userTXIdParam"];
}

-(NSString *)getchannelId
{    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"channelIdParam"];
}

-(void)setUserTXId:(NSString *)userTXIdParam
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"userTXIdParam"];
    [settings setObject:userTXIdParam forKey:@"userTXIdParam"];
}

-(void)setchannelId:(NSString *)channelIdParam
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"channelIdParam"];
    [settings setObject:channelIdParam forKey:@"channelIdParam"];
}


-(void)setsos:(NSString *)sosParam
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"sos"];
    [settings setObject:sosParam forKey:@"sos"];
}


-(void)setgps:(NSString *)gpsParam
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"gpsinterval"];
    [settings setObject:gpsParam forKey:@"gpsinterval"];
}


-(void)setpulse:(NSString *)pulseParam
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"pulseinterval"];
    [settings setObject:pulseParam forKey:@"pulseinterval"];
}

- (void)setUserId:(NSString*)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)getUserId
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"UserId"];
}
-(NSString *)getPwd
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * temp = [settings objectForKey:@"Password"]; 
    return  temp  ;
}



-(NSArray *)getSubmitProperty:(NSString *)key
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SubmitProperty"
                                                          ofType:@"plist"];
    // 读取到一个NSDictionary
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *returnArray = [dictionary objectForKey:key]; // 注意这个 key 是以 @ 开头
    return returnArray;
}



 
//得到当期日期
-(NSString *)getCurrDate:(NSDate *)data
{
    NSDate *senddate=data;
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];  
    
    [dateformatter setDateFormat:@"MM月dd日"];  
    NSString *  currDate=[dateformatter stringFromDate:senddate];   
    return currDate;
}

//得到当期日期
-(NSString *)getCurrDate0:(NSDate *)data
{
    NSDate *senddate=data;
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *  currDate=[dateformatter stringFromDate:senddate];
    return currDate;
}




//得到当期日期
-(NSString *)getDate:(int)dayValue
{
    NSDate *senddate=[[NSDate date] dateByAddingDays:dayValue];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMdd"];
    NSString *  currDate=[dateformatter stringFromDate:senddate];
    return currDate;
}



//得到当期日期
-(NSDate *)getDate0:(int)dayValue
{
   return [[NSDate date] dateByAddingDays:dayValue];
   
}


//得到SID
-(NSString *)getsid
{
    NSRange rangeMM = NSMakeRange(6, 4);
    NSString *tel = [[self getUserName] substringWithRange:rangeMM];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currDate=[dateformatter stringFromDate:[NSDate date]];
    return [currDate stringByAppendingString:tel];
}



//日期转换
-(NSDate *)stringToDate:(NSString *)dateString
{
    NSRange rangeYYYY = NSMakeRange(0, 4); //location（索引位置）、length（截取的長度）
    NSString *strYYYY = [dateString substringWithRange:rangeYYYY];//包含該索引的位置
    NSRange rangeMM = NSMakeRange(4, 2); //location（索引位置）、length（截取的長度）
    NSString *strMM= [dateString substringWithRange:rangeMM];//包含該索引的位置
    NSRange rangeDD = NSMakeRange(6, 2); //location（索引位置）、length（截取的長度）
    NSString *strDD= [dateString substringWithRange:rangeDD];//包含該索引的位置
    
    NSRange rangeHH = NSMakeRange(8, 2); //location（索引位置）、length（截取的長度）
    NSString *strHH= [dateString substringWithRange:rangeHH];//包含該索引的位置
    NSRange rangemm = NSMakeRange(10, 2); //location（索引位置）、length（截取的長度）
    NSString *strmm= [dateString substringWithRange:rangemm];//包含該索引的位置
    NSRange rangeSS = NSMakeRange(12, 2); //location（索引位置）、length（截取的長度）
    NSString *strSS= [dateString substringWithRange:rangeSS];//包含該索引的位置
    
    dateString = @"";
    NSString *tmpString = [dateString stringByAppendingFormat:@"%@-%@-%@ %@:%@:%@",strYYYY,strMM,strDD,strHH,strmm,strSS];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[formatter dateFromString:tmpString];
    return date;
}


//日期转换
-(NSString *)stringToDate2:(NSString *)dateString
{
    NSRange rangeYYYY = NSMakeRange(0, 4); //location（索引位置）、length（截取的長度）
    NSString *strYYYY = [dateString substringWithRange:rangeYYYY];//包含該索引的位置
    NSRange rangeMM = NSMakeRange(4, 2); //location（索引位置）、length（截取的長度）
    NSString *strMM= [dateString substringWithRange:rangeMM];//包含該索引的位置
    NSRange rangeDD = NSMakeRange(6, 2); //location（索引位置）、length（截取的長度）
    NSString *strDD= [dateString substringWithRange:rangeDD];//包含該索引的位置
    
    NSRange rangeHH = NSMakeRange(8, 2); //location（索引位置）、length（截取的長度）
    NSString *strHH= [dateString substringWithRange:rangeHH];//包含該索引的位置
    NSRange rangemm = NSMakeRange(10, 2); //location（索引位置）、length（截取的長度）
    NSString *strmm= [dateString substringWithRange:rangemm];//包含該索引的位置
    NSRange rangeSS = NSMakeRange(12, 2); //location（索引位置）、length（截取的長度）
    NSString *strSS= [dateString substringWithRange:rangeSS];//包含該索引的位置
    
    dateString = @"";
    NSString *tmpString = [dateString stringByAppendingFormat:@"%@-%@-%@ %@:%@:%@",strYYYY,strMM,strDD,strHH,strmm,strSS];
    
    
    return tmpString;
}

//日期转换
-(NSString *)stringToDate0:(NSString *)dateString
{
 
    NSRange rangeMM = NSMakeRange(4, 2); //location（索引位置）、length（截取的長度）
    NSString *strMM= [dateString substringWithRange:rangeMM];//包含該索引的位置
    NSRange rangeDD = NSMakeRange(6, 2); //location（索引位置）、length（截取的長度）
    NSString *strDD= [dateString substringWithRange:rangeDD];//包含該索引的位置
    
    dateString = @"";
    NSString *tmpString = [dateString stringByAppendingFormat:@"%@月%@日",strMM,strDD];
   
    return tmpString;
}



- (void)applicationTerminated
{
}


@end
