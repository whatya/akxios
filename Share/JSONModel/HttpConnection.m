//
//  HttpConnection.m
//  Gateway
//
//  Created by wangsong on 13-2-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "HttpConnection.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
//#import "JSONKit.h"
#import "CommonHead.h"

@implementation HttpConnection
@synthesize delegate = _delegate, request = _request;
@synthesize hasLogin;

//将HttpConnection做成单例
static HttpConnection *httpConnect = nil;

+ (HttpConnection *)shareInstance
{
    @synchronized(self){//线程安全
        if (!httpConnect){
            httpConnect=[[super allocWithZone:NULL]init];
            httpConnect.m_zbarKey = [[[NSString alloc] init] autorelease];
        }
    }
    return httpConnect;
}

+ (id)allocWithZone:(NSZone *)zone//重新写alloc是从写的父类的alloc
{
    return [[self shareInstance]retain];  //返回单例  这里self在+方法中就是类型不是对象
}
- (id)copy
{
    return self;
}
- (id)retain
{
    return self;
}
- (id)autorelease
{
    return self;
}
- (oneway void)release
{
    //不做处理
}
- (void)dealloc
{
    //不作处理
    [super dealloc];
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

#pragma mark -
#pragma mark 服务器接口
- (NSString *)getUrl:(NSString *)method
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Property" ofType:@"plist"];
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] autorelease];
    NSString *url =[[[data valueForKey:@"lcyurl"] stringByAppendingString:@"?"]stringByAppendingString:method];
    return url;
}



//从HTTP提交参数后，返回Json格式数据 pageIndex=页码&pageSize=行数
-(NSString *)getNewsInfoJson:(NSString *)urlParm   withParam:(NSString *)pageIndex  withParam:(NSString *)pageSize
{ 
    NSString *mainURL=  urlParm ; 
    mainURL = [mainURL stringByReplacingOccurrencesOfString:@"页码" withString:@"0"];
    mainURL = [mainURL stringByReplacingOccurrencesOfString:@"行数" withString:@"10"];
    
    NSURL *requestURL = [NSURL URLWithString:mainURL];//
    
    //构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:requestURL];
    //开始同步请求
    
    [request startSynchronous]; 
    NSString *response = [request responseString];
    NSLog(@"response:%@",response);
    return response;
}


#pragma mark - 
#pragma mark 转圈
//停止转圈等待界面，外部调用接口
- (void)stopWaitingView
{
    if (m_AlertView)
    {
        [m_AlertView dismissAlertView];
        [m_AlertView release];
        m_AlertView = nil;
    }
    
}
//停止转圈等待界面，定时器超时调用
- (void)stopWaitingViewByTimer:(NSTimer *)timer
{
    //销毁定时器
    if(m_timer && [m_timer isValid])
    {
        [m_timer invalidate];
        m_timer = nil;
    }
    
    [self stopWaitingView];
}
//展示转圈等待界面，入参为自动停止的超时时间
- (void)showWaitingViewWithMaxTime:(NSTimeInterval)ti
{
    //转圈存在的情况下不创建
    if(m_AlertView)
        return;
    UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,IPHONE_HEIGHT)];
    if (!([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))
    {
        waitingView.frame = CGRectMake(0, 0, 1024,768);
    }
    waitingView.backgroundColor = [UIColor blackColor];
    waitingView.alpha = 0.4;
    
    UIActivityIndicatorView *indiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [waitingView addSubview:indiView];
    [indiView startAnimating];
    indiView.center = waitingView.center;
    [indiView release];
    
    
    m_AlertView = [[CAlertView alloc] initWithAlertView:waitingView andAnimationType:NoneAnimationType];
    m_AlertView.backAlpha = 0.4;
    m_AlertView.windowLevel = UIWindowLevelStatusBar;
    [m_AlertView show];
    
    [waitingView release];

    
    if (ti != 0) {
        m_timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                   target:self
                                                 selector:@selector(stopWaitingViewByTimer:)
                                                 userInfo:nil
                                                  repeats:NO];
    }
    
    
}
#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString]?[request responseString]:nil;
    if (responseString == nil)
    {
        responseString = @"";
    }
    LogInfo(@"%@",responseString);
    if (_delegate && [_delegate respondsToSelector:@selector(successed:)])
    {
        [_delegate successed:request];
    }
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    LogInfo(@"出现请求失败，request.tag==%d",request.tag);
    if (_delegate != nil && [_delegate respondsToSelector:@selector(Failed:)])
    {
        [_delegate failed:request];
    }
}


@end
