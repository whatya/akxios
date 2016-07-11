/********************************************************************
 文件名称 : NSPublic 文件
 作    者 : 张文夫
 创建时间 : 2011-08-13
 文件描述 : 初始化配置信息
 版权声明 : Copyright (C) 2001-2011 武汉捷讯信息技术有限公司
 修改历史 : 2011-08-15      1.00    初始
 *********************************************************************/
 

@interface NSPublic : NSObject  <UIApplicationDelegate>
{
    NSMutableDictionary* systemSettingsDict;
    NSMutableDictionary *dict;
    NSString *imei;
    NSArray *commArray;
    NSString *relative;
    NSString *name;
    NSString *sim;
    NSString *channelId;
    NSString *sex;
    NSString *userTXId;
    NSString *pageIndex;
    NSString *sendPageIndex;
   
    NSMutableArray *heartCommArray;
    NSString *image;
    NSString *mcard;
//    NSString *serverId;
//    NSString *receiverId;
//    NSString *doctorId;
//    NSString *payNum;
    
    
    NSMutableArray *lowBloodCommArray;
    NSMutableArray *highBloodCommArray;
    NSMutableArray *termUserArray;
}

//绑定的终端用户列表

@property (nonatomic,assign) BOOL isFromExitPage;

@property (nonatomic,assign) int vcIndex; //0,1 心率；2 定位；3 血压；4 聊天；

@property (nonatomic,assign) BOOL isPlayingSound;

@property (nonatomic,strong) NSDictionary *messageNotificationFromServer;

-(void)setTermUserArray:(NSMutableArray*) array;

-(NSMutableArray*)getTermUserArray;

-(void)setimage:(NSString *)imageparam;

-(NSString *)getimage;
- (void)setMcard:(NSString*)card;
- (NSString*)getMcard;

-(BOOL)isCHDevice;

-(int)compsDays:(NSDate *)fromdate with:(NSDate *)todate;
-(void)setCommArray:(NSArray *)arr; 
-(NSArray *)getCommArray;

-(void)setBloodCommArray:(NSMutableArray*) array0 with:(NSMutableArray*) array1;

-(NSMutableArray*)getlowBloodCommArray;
-(NSMutableArray*)gethighBloodCommArray;
-(void)setheartCommArray:(NSMutableArray*) array;
-(NSMutableArray *)getheartCommArray;
-(double)distanceBetweenOrderBy:(double)lat1 :(double)lat2 :(double)lng1 :(double)lng2;

-(NSString *)getsendPageIndex ;

-(void)setsendPageIndex:(NSString *)paramsendPageIndex;
- (void)setUserId:(NSString*)userId;

-(NSString *)getpageIndex;
-(void)setpageIndex:(NSString *)parampageIndex;
+ (NSPublic *)shareInstance;
-(NSString *)getJSESSION;
-(NSDate *)stringToDate:(NSString *)dateString;
-(NSString *)stringToDate0:(NSString *)dateString;
-(NSString *)getCurrDate:(NSDate *)data;
-(NSData *)getURLInfoJson:(NSString *)url;
-(NSArray *)getSubmitProperty:(NSString *)key;
-(NSDictionary *)postURLInfoJson:(NSString *)urlString with:(NSArray *)array with:(NSString *)keyValue;
-(NSString *)getImei;

-(void)setImei:(NSString *)paramImei;
-(NSString *)getUserImage;

-(void)saveUserInfo:(NSString *)real with:(NSString *)sign with:(NSString *)idcard with:(NSString *)userSex with:(NSString *)userImage;

-(void)saveUserInfor:(NSString *)pulseinterval with:(NSString *)gpsinterval with:(NSString *)stepinterval with:(NSString *)pulsemax with:(NSString *)pulsemin  with:(NSString *)stepmax with:(NSString *)radius  with:(NSString *)safelat with:(NSString *)safelon  with:(NSString *)pulsealarm with:(NSString *)stepalarm  with:(NSString *)gpsalarm with:(NSString *)pushtime  with:(NSString *)sos
                with:(NSString *)sbpmax with:(NSString *)sbpmin with:(NSString *)dbpmin with:(NSString *)dbpmax with:(NSString *)bloodalarm;

-(NSString *)getDate:(int)dayValue;
//保存登录用户名以及密码
-(void)saveUserNameAndPwd:(NSString *)userName andPwd:(NSString *)pwd with:(NSString *)isShowLoginInfo with:(NSString *)isAutoLogin;
-(void)saveUserNameAndPwd:(NSString *)userName andPwd:(NSString *)pwd ;
-(NSString *)getUserName;
-(NSString *)getPwd;

-(NSString *)getUserId;

-(NSString *)getUserTXId;
-(NSString *)getchannelId;
-(NSString *)getCurrDate0:(NSDate *)data;
-(void)setUserTXId:(NSString *)userTXIdParam;
-(void)setUserImage:(NSString*)userImage;
-(void)setchannelId:(NSString *)channelIdParam;

-(void)saveServerId:(NSString *)serverId;
-(NSString *)getServerId;

-(void)saveReceiverId:(NSString *)receiverId;
-(NSString *)getReceiverId;

-(void)saveDoctorId:(NSString *)doctorId;
-(NSString *)getDoctorId;

-(void)savePayNum:(NSString *)payNum;
-(NSString *)getPayNum;

-(void)saveServerUsername:(NSString *)serverUsername;
-(NSString *)getServerUsername;

-(void)saveDocotorName:(NSString *)docotorName;
-(NSString *)getDocotorName;

-(void)saveServerImage:(NSString *)serverImage;
-(NSString *)getServerImage;

-(void)saveServerName:(NSString *)serverName;
-(NSString *)getServerName;


-(NSString *)getpulseinterval;

-(NSString *)getgpsinterval;
-(NSString *)getstepinterval;
-(NSString *)getpulsemax;
-(NSString *)getpulsemin;
-(NSString *)getstepmax;
-(NSString *)getbloodalarm;

-(NSString *)getradius;

-(NSString *)getsafelat;

-(NSString *)getsafelon;

-(NSString *)getpulsealarm;

-(NSString *)getstepalarm;


-(NSString *)getgpsalarm;

-(NSString *)getpushtime;

-(NSString *)getsos;
-(NSString *)getdbpmin;
-(NSString *)getdbpmax;
-(NSString *)getsbpmax;
-(NSString *)getsbpmin;

-(NSString *)getAutoLogin;

-(NSString *)getShowLoginInfo;
-(void)setsos:(NSString *)sosParam;
-(void)setname:(NSString *)paramname;
-(void)setrelative:(NSString *)paramrelative;
-(void)setsim:(NSString *)paramsim;
-(NSString *)stringToDate2:(NSString *)dateString;
-(NSString *)replaceUnicode:(NSString *)unicodeStr;
-(NSString *)getsim;

-(void)setsex:(NSString *)sexparam;
-(void)setgps:(NSString *)gpsParam;
-(void)setpulse:(NSString *)pulseParam;

-(NSString *)getsex;

-(NSString *)getname;

-(NSString *)getsid:(NSString *)tel;
-(NSString *)getrelative;
-(NSString *)getsid;
-(BOOL)getDeviceInfo;

@end
