//
//  HttpConnection.h
//  Gateway
//
//  Created by wangsong on 13-2-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "CAlertView.h"

typedef enum
{
    ASI_RANK = 100,
    ASI_ALLRANK,
    ASI_RECOMMEND,
    ASI_ALLRECOMMEND,
    ASI_LOGIN,
    ASI_LOGOUT,
    ASI_SEARCH,
    ASI_GETCOLUMN,
    ASI_GETCONTENT,
    ASI_GETDETAIL,
    ASI_GETCHANNEL,
    ASI_PROEPG,
    ASI_CURRENTEPG,
    ASI_HISTORY,
    ASI_PLAYCOUNT,
    ASI_PLAYTIME,
    ASI_STBPLAY,
    ASI_STBKEY,
    ASI_STBEXIT,
    ASI_PHONESTB,
    ASI_BACKPHONE
}RequestType;

@protocol HttpConnectionDelegate <NSObject>
@optional
- (void)successed:(ASIHTTPRequest *)request;
- (void)failed:(ASIHTTPRequest *)request;
@end

@interface HttpConnection : NSObject
{
    id<HttpConnectionDelegate>_delegate;
//    ASIHTTPRequest *_request;
    NSTimer *m_timer;
    CAlertView *m_AlertView;

}
@property (nonatomic,assign) BOOL hasLogin;
@property (nonatomic,retain) NSString *m_zbarKey;
@property (nonatomic,assign) BOOL m_stbPlay;
@property (assign ,nonatomic) id<HttpConnectionDelegate> delegate;
@property (retain ,nonatomic) ASIHTTPRequest *request;

- (void)showWaitingViewWithMaxTime:(NSTimeInterval)ti;
- (void)stopWaitingView;


-(NSString *)getNewsInfoJson:(NSString *)urlParm   withParam:(NSString *)pageIndex  withParam:(NSString *)pageSize;
 
 
+ (HttpConnection *)shareInstance;

@end
