//
//  MessageListManager.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/31.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "MessageListManager.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "CHTermUser.h"
#import "NSPublic.h"
#import "Alert.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MessageListManager ()
@property(nonatomic) BOOL shouldPostNoification;
@end


@implementation MessageListManager

- (void)appendMessage:(NSDictionary*)message toImei:(NSString*)imei withSender:(NSString *)sender
{
    
    dispatch_async(kBgQueue, ^{
        NSError *error0 = nil;
        NSString *jsonFileName = [NSString stringWithFormat:@"%@-%@.json",imei,sender];
        NSMutableArray *messagesList = [self jsonFromJsonFile:jsonFileName];
        
        if (messagesList) {
             [messagesList addObject:message];
        }else{
            messagesList = [[NSMutableArray alloc] init];
            [messagesList addObject:message];
        }
        
        NSData *jsonDataD = [NSJSONSerialization dataWithJSONObject:messagesList options:NSJSONWritingPrettyPrinted error:&error0];
        if (error0) {
            NSLog(@"转为NSData时出错:%@",[error0 localizedDescription]);
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonDataD encoding:NSUTF8StringEncoding];
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:jsonFileName];
        NSError *error = nil;
        
        BOOL flag = [jsonString writeToFile:storePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            NSLog(@"写入：%@ %@！",jsonFileName,flag?@"成功":@"失败");
            
            if (self.shouldPostNoification) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageList" object:nil];
                NSLog(@"通知已发送！");
                self.shouldPostNoification = NO;
                NSLog(@"%@",self.shouldPostNoification ? @"YES" : @"NO");
            }
            
        }
    });
}



- (NSMutableArray*)jsonFromJsonFile:(NSString*)jsonFileName
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *Json_path=[path stringByAppendingPathComponent:jsonFileName];
    NSData *data=[NSData dataWithContentsOfFile:Json_path];
    NSError *error = nil;
    if (data) {
        NSArray* jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
        return [jsonObject mutableCopy];

    }else{
        return nil;
    }
}

- (void)fetchNewMessage:(NSDictionary *)params
{
  //  [[Alert sharedAlert] showMessage:[NSString stringWithFormat:@"开始获取消息：%@",params]];
    NSString *msgid = params[@"msgid"];
    NSString *url = @"chunhui/m/data@getMessage.do";
    NSString *paramString = [NSString stringWithFormat:@"msgid=%@",msgid];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                                portID:80
                                                           queryString:paramString
                                                              callBack:^(id jsonData, NSError *error) {
                                                                  NSDictionary *temp = jsonData;
                                                                  NSString *status = temp[@"status"];
                                                                  if ([status isEqualToString:@"0"]) {
                                                                      [ProgressHUD showSuccess:@"获取消息成功！" Interaction:YES];
                                                                      
                                                                      if (![jsonData[@"data"] isKindOfClass:[NSDictionary class]]) {
                                                                          return ;
                                                                      }
                                                                      
                                                                      NSMutableDictionary *newPrams = [NSMutableDictionary dictionaryWithDictionary:jsonData[@"data"]];
                                                                      newPrams[@"imei"] = params[@"imei"];
                                                                      
                                                                    //  [[Alert sharedAlert] showMessage:[NSString stringWithFormat:@"消息获取成功：%@",newPrams]];
                                                                      
                                                                      [self formatDataAndSave:newPrams];
                                                                  }
                                                              }];
}

- (void)formatDataAndSave:(NSDictionary*)message
{
    NSMutableDictionary *newMessage = [NSMutableDictionary new];
    CHTermUser *user  = [self userWithImei:message[@"imei"]];
    newMessage[@"from"] = @(1);
    newMessage[@"type"] = @"2";
    newMessage[@"voice"] =  message[@"msg"];
    newMessage[@"strName"] = user.name;
    newMessage[@"strIcon"] = user.image;
    newMessage[@"strVoiceTime"] = @([message[@"msglen"] intValue]);
    NSString *dateString = message[@"sendtime"];
    newMessage[@"strTime"] = [dateString substringToIndex:dateString.length-2];
    self.shouldPostNoification = YES;
    [self appendMessage:newMessage toImei:message[@"imei"] withSender:[[NSPublic shareInstance] getUserName]];
    
    
}

- (NSString *)fixStringForDate:(NSDate *)date

{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *fixString = [dateFormatter stringFromDate:date];
    
    return fixString;
    
}

- (NSDate*)dateFromString:(NSString*)dateStr
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter dateFromString:dateStr];
}

- (CHTermUser*)userWithImei:(NSString*)imei
{
    NSMutableArray *termUsers = [[NSPublic shareInstance] getTermUserArray];

    
    for (CHTermUser *termUser in termUsers) {
        if ([imei isEqualToString:termUser.imei]) {
            return termUser;
        }
    }
    return nil;
}

@end
