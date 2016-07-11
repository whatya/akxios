//
//  HttpManager.m
//  Aitu
//
//  Created by 张宝 on 15-4-23.
//  Copyright (c) 2015年 zhangbao. All rights reserved.
//

#import "HttpManager.h"


@interface HttpManager ()
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSession *uploadSession;
@end

@implementation HttpManager
 
#pragma mark- 单利
+ (HttpManager *)sharedHttpManager
{
    static HttpManager *sharedManagerInstance = nil;
    static dispatch_once_t  singleton;
    dispatch_once(&singleton, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

#pragma mark- 惰性初始化
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:nil
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (NSURLSession*)uploadSession
{
    if (!_uploadSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _uploadSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    }
    return _uploadSession;
}

#pragma mark- 从服务端获取json数据
- (void)jsonDataFromServerWithBaseUrl:(NSString *)baseUrl
                               portID:(int)port
                          queryString:(NSString *)queryString
                             callBack:(CallbackWithJsonData)callBack
{
    NSURL *url = nil;
    if ([baseUrl hasPrefix:@"http"]) {
        url = [NSURL URLWithString:baseUrl];
    }else{
        //配置端口
        NSString *urlPlusPort = [NSString stringWithFormat:@"%@%d/",HttpServerUrl,port];
        
        // 1、配置session configuration
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlPlusPort,baseUrl]];
    }

    // 2、配置请求体
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    
    // 3、配置请求参数
    NSString *params = queryString;
    NSError *error = nil;
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    if (!error) {
        // 4、发送请求
        [[self.session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
        {
            if (!error)
            {
                NSError *jsonCovertError = nil;
                NSMutableDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonCovertError];
                if (!jsonCovertError) {
                    callBack(result,nil);
                }else{
                    callBack(nil,jsonCovertError);
                    NSLog(@"json转换出错：%@",[jsonCovertError localizedDescription]);
                }
                
            }else{
                NSLog(@"请求出错：%@",[error localizedDescription]);
                callBack(nil,error);
            }
        }] resume];
    }else{
        NSLog(@"参数转换出错：%@",[error localizedDescription]);
    }
}

- (void)jsonDataFromServerWithqueryString:(NSString *)queryString callBack:(CallbackWithJsonData)callBack
{
        NSString *temp = [queryString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        // 4、发送请求
        [[self.session dataTaskWithURL:URL(temp) completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
              if (!error)
              {
                  NSError *jsonCovertError = nil;
                  NSMutableDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonCovertError];
                  if (!jsonCovertError) {
                      callBack(result,nil);
                  }else{
                      callBack(nil,jsonCovertError);
                      NSLog(@"json转换出错：%@",[jsonCovertError localizedDescription]);
                  }
                  
              }else{
                  NSLog(@"请求出错：%@",[error localizedDescription]);
                  callBack(nil,error);
              }
          }] resume];

}


- (NSString*)joinKeys:(NSArray*)keys withValues:(NSArray*)values
{
    NSString * queryString = @"";
    for (int i = 0;i<keys.count;i++){
        NSString *key = keys[i];
        NSString *value = values[i];
        NSString *kvTemp = [NSString stringWithFormat:@"%@=%@&",key,value];
        queryString = [queryString stringByAppendingString:kvTemp];
    }
    if (queryString.length > 2) {
        return [queryString substringToIndex:queryString.length - 1];
    }else{
        return nil;
    }
    
}

@end
