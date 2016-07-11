//
//  TCPManager.m
//  TcpManager
//
//  Created by ZhuXiaoyan on 15/10/12.
//  Copyright © 2015年 whatya. All rights reserved.
//

#import "TCPManager.h"
#import "ByteData.h"
#import "ByteManager.h"
#import "MessageService.h"
#import "CommonConstants.h"

@interface TCPManager ()

#pragma mark- 属性

@property (nonatomic,assign) NSInteger      totalDataLength;
@property (nonatomic,strong) NSMutableData  *data;

@property (nonatomic,strong) MessageService *messageService;

@end

@implementation TCPManager


#pragma mark- --------------------------------------TCP Manager Start--------------------------------------

#pragma mark- 初始化
+(TCPManager *) sharedInstance
{
    static TCPManager *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}

#pragma mark- 建立连接
- (void) initNetworkCommunication{ ShowLog
   
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (__bridge CFStringRef)(self.IPAddress),
                                       self.portNumber,
                                       &readStream,
                                       &writeStream);
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
}


#pragma mark- 管道事件回调代理方法
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent { ShowLog
    dispatch_async(kBgQueue, ^{
        
        switch (streamEvent) {
                
            case NSStreamEventOpenCompleted:
            {
                NSLog(@"TCP代理回调：-----------> 连接建立成功:%@",theStream);
                [self clearFormerData];
                break;
            }
                
            case NSStreamEventHasBytesAvailable:
            {
                
                NSLog(@"TCP代理回调：-----------> 收到可用数据:");
                if (theStream == self.inputStream) {
                    NSInputStream *inputStreamTemp = (NSInputStream*)theStream;
                    [self decodeStream:inputStreamTemp];
                }
                break;
            }
            case NSStreamEventErrorOccurred:
            {
                NSLog(@"TCP代理回调：-----------> 发生错误:");
                [self clearFormerData];
                break;
            }
            case NSStreamEventEndEncountered:
            {
                NSLog(@"TCP代理回调：-----------> 数据结束:");
            }
            default:
            {
                NSLog(@"TCP代理回调：-----------> 其他事件");
                [self clearFormerData];
            }
        }
        
        
    });
}

#pragma mark- 流解码
- (void)decodeStream:(NSInputStream*)theStream{ ShowLog
    
    if(!_data || self.data.length > self.totalDataLength) {
        _data = [NSMutableData data];
        self.totalDataLength = 0;
    }
    
    uint8_t buf[1024];
    NSInteger len = 0;
    len = [(NSInputStream *)theStream read:buf maxLength:1024];
    if(len > 0 && len <= 1024) {
        [_data appendBytes:(const void *)buf length:len];
        
        //获取数据总长度
        if (self.totalDataLength == 0) {
            if (self.data.length < 5) {
                self.totalDataLength = 0;
                self.data = nil;
                return;
            };
            
            NSData *lengthData = [self.data subdataWithRange:NSMakeRange(1, 4)];
            ByteData *calculator = [[ByteData alloc] init];
            int totalLength = [calculator bytesToInt:(Byte*)[lengthData bytes]];
            self.totalDataLength = totalLength + 5;//命令长度＋长度数据长度 ＋ 数据长度 ＝ 总长度
        }
        
        NSLog(@"\n\n\n\n收到总长度：%ld  已读：%ld \n\n\n\n",(long)self.totalDataLength,(long)self.data.length);
        
        if (self.totalDataLength == self.data.length) {
            
            NSLog(@"sth123312312312312312312312313124243432424241241241241241242421414");
            [self crackData:[self.data copy]];
            
            self.totalDataLength = 0;
            self.data = nil;
        }else if(self.data.length > self.totalDataLength){
            [self crackOverSizeData:[self.data copy]];
            self.totalDataLength = 0;
            self.data = nil;
        }
        
    } else {
        NSLog(@"空包!");
        [self clearFormerData];
    }
}

- (void)crackOverSizeData:(NSData*)overSizeData
{ShowLog
    NSData *rowData = overSizeData;
    while (rowData.length > 0) {
        NSData *lengthData = [rowData subdataWithRange:NSMakeRange(1, 4)];
        ByteData *calculator = [[ByteData alloc] init];
        int packetLength = [calculator bytesToInt:(Byte*)[lengthData bytes]];
        NSData *packet = [rowData subdataWithRange:NSMakeRange(0, packetLength + 5)];
        [self crackData:packet];
        rowData = [rowData subdataWithRange:NSMakeRange(packetLength + 5, rowData.length - packetLength -5)];
    }
    
}

- (void)crackData:(NSData*)rowData{ ShowLog
    
    if (rowData.length > 0) {
        ByteManager *mamager = [[ByteManager alloc] initWithData:rowData];
        [mamager showValues];
        id  lastData = [mamager.values lastObject];
        int commond = [[mamager.values firstObject] intValue];
        
        if (commond == 16) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Commond error" object:nil];
            
        }else if (commond == 11) {
            
            [self.messageService saveMessageFromRowValues:mamager.values notifiy:YES];
            
        }else if (commond == 13){
            
            [self.messageService savePendingMessagesFromRowValues:mamager.values];
            
        }else if ([lastData isKindOfClass:[NSNumber class]] && [lastData intValue] == 0 && commond == 15){
            NSLog(@"TCP 登录成功！");
            
            [[TCPManager sharedInstance] getPendingMessages];
           
        }
        else if(commond == 17){
            id lastData = [mamager.values lastObject];
            if ([lastData isKindOfClass:[NSString class]]) {
                NSMutableData *stringData = [[NSMutableData alloc] initWithData:[lastData dataUsingEncoding:NSUTF8StringEncoding]];
                NSError *jsonCovertError = nil;
                NSMutableDictionary * result = [NSJSONSerialization JSONObjectWithData:stringData
                                                                               options:kNilOptions
                                                                                 error:&jsonCovertError];
                if (!jsonCovertError) {
                    NSLog(@"发送通知了。");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Received json data" object:result];
                }
                
            }
        }
    }else{
        // do nothing
    }
}

#pragma mark- 清除之前的数据
- (void)clearFormerData
{
    self.totalDataLength = 0;
    self.data = nil;
}

#pragma mark- 关闭流
- (void)closeStream{ ShowLog
    
    [self loginOut];
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream = nil;
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream = nil;
}

#pragma mark- --------------------------------------TCP Manager End--------------------------------------



#pragma mark- 发送心跳包
- (void)heartBeat{ ShowLog
    
    ByteData *byteData = [[ByteData alloc] init];
    Byte heartBeatCommond[] = {18};
    Byte intType[] = {2};
    
    //拼接请求id
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:[self mID] inFront:NO];
    
    //拼接命令＋长度
    [byteData appendInt:(int)byteData.data.length inFront:YES];
    [byteData appendBytes:heartBeatCommond inFront:YES];
    
    NSLog(@"\n\n\n\n发送心跳包命令:18");
    [byteData showBytes];

    
    [self.outputStream write:[byteData.data bytes] maxLength:byteData.data.length];
}

#pragma mark- 获取离线消息
- (void)getPendingMessages{ ShowLog
    
    ByteData *byteDta = [[ByteData alloc] init];
    Byte getPendingMessageCommond[] = {12};
    Byte intType[] = {2};
    
    //拼接请求id
    [byteDta appendBytes:intType inFront:NO];
    [byteDta appendInt:[self mID] inFront:NO];
    
    //拼接命令 ＋ 长度
    [byteDta appendInt:(int)byteDta.data.length inFront:YES];
    [byteDta appendBytes:getPendingMessageCommond inFront:YES];
    [byteDta showBytes];
    
    [self.outputStream write:[byteDta.data bytes] maxLength:byteDta.data.length];
    
}

#pragma mark- 登录
- (void)loginWithUsername:(NSString *)username andPwd:(NSString *)password{ ShowLog
    
    if (username.length > 0 && password.length > 0) {
        self.passwrod = password;
        self.username = username;
    }
    
    if (self.username.length == 0) {
        NSLog(@"用户名或密码不能为空！");
        return;
    }
    
    ByteData *byteData = [[ByteData alloc] init];
    Byte loginCommond[] = {2};
    
    //拼接命令字节1
    [byteData appendBytes:loginCommond inFront:NO];
    [byteData appendInt:0 inFront:NO];
    //拼接用户名字符串
    Byte stringType[] = {4};
    [byteData appendBytes:stringType inFront:NO];
    [byteData appendInt:(int)self.username.length inFront:NO];
    [byteData appendString:self.username inFront:NO];
    //拼接密码字符串
    [byteData appendBytes:stringType inFront:NO];
    [byteData appendInt:(int)self.passwrod.length inFront:NO];
    [byteData appendString:self.passwrod inFront:NO];
    //拼接头部，和总长度
    [byteData appendInt:(int)byteData.data.length inFront:YES];
    [byteData appendBytes:loginCommond inFront:YES];
    [byteData showBytes];
    [self.outputStream write:[byteData.data bytes] maxLength:byteData.data.length];
}

#pragma mark- 发送文本数据
- (void)sendText:(NSString*)text roomId:(NSString*)room senderId:(NSString*)sender{ ShowLog

    ByteData *byteData = [[ByteData alloc] init];
    Byte sendMsg[] = {11};
    
    Byte intType[] = {2};
    Byte strType[] = {4};
    Byte bytType[] = {1};
    
    //拼接随机整数
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:self.mID inFront:NO];
    //拼接发送者字符串
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:[self stringLength:sender] inFront:NO];
    [byteData appendString:sender inFront:NO];
    
    //拼接占位字符串
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:-1 inFront:NO];
    
    //拼接消息类型
    Byte msgType[] = {1};
    [byteData appendBytes:bytType inFront:NO];
    [byteData appendBytes:msgType inFront:NO];
    //添加消息长度（如果是语音就有值，如果没有就为0）
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:0 inFront:NO];
    //添加消息正文
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:[self stringLength:text] inFront:NO];
    [byteData appendString:text inFront:NO];
    //添加房间id
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:[self stringLength:room] inFront:NO];
    [byteData appendString:room inFront:NO];
    //添加发送时间
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeStamp = [NSString stringWithFormat:@"%llu",recordTime];
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:[self stringLength:timeStamp] inFront:NO];
    [byteData appendString:timeStamp inFront:NO];
    
    
    //拼接命令＋长度
    [byteData appendInt:(int)byteData.data.length inFront:YES];
    [byteData appendBytes:sendMsg inFront:YES];
    
    [byteData showBytes];
    [self.outputStream write:[byteData.data bytes] maxLength:byteData.data.length];
}

#pragma mark-发送图片数据
- (void)sendImageString:(NSString*)imageString roomId:(NSString*)room senderId:(NSString*)sender{ ShowLog
    
    ByteData *byteData = [[ByteData alloc] init];
    Byte sendMsg[] = {11};
    
    Byte intType[] = {2};
    Byte strType[] = {4};
    Byte byteType[]= {1};
    
    //拼接随机整数
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:self.mID inFront:NO];
    //拼接发送者字符串
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(sender.length) inFront:NO];
    [byteData appendString:sender inFront:NO];
    
    //拼接占位字符串
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:-1 inFront:NO];
    
    //拼接消息类型
    Byte msgType[] = {3};
    [byteData appendBytes:byteType inFront:NO];
    [byteData appendBytes:msgType inFront:NO];
    //添加消息长度（如果是语音就有值，如果没有就为0）
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:0 inFront:NO];
    //添加消息正文
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(imageString.length) inFront:NO];
    [byteData appendString:imageString inFront:NO];
    //添加房间id
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(room.length) inFront:NO];
    [byteData appendString:room inFront:NO];
    //添加发送时间
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeStamp = [NSString stringWithFormat:@"%llu",recordTime];
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(timeStamp.length) inFront:NO];
    [byteData appendString:timeStamp inFront:NO];
    
    //拼接命令＋长度
    [byteData appendInt:(int)byteData.data.length inFront:YES];
    [byteData appendBytes:sendMsg inFront:YES];
    
    [byteData showBytes];
    [self.outputStream write:[byteData.data bytes] maxLength:byteData.data.length];
}

#pragma mark- 发送语音数据
- (void)sendAudioString:(NSString*)audioString audioLenth:(int)length roomId:(NSString*)room senderId:(NSString*)sender{ ShowLog

    ByteData *byteData = [[ByteData alloc] init];
    Byte sendMsg[] = {11};
    
    Byte intType[] = {2};
    Byte strType[] = {4};
    Byte byteType[]= {1};
    
    //拼接随机整数
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:self.mID inFront:NO];
    //拼接发送者字符串
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(sender.length) inFront:NO];
    [byteData appendString:sender inFront:NO];
    
    //拼接占位字符串
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:-1 inFront:NO];
    
    //拼接消息类型
    Byte msgType[] = {2};
    [byteData appendBytes:byteType inFront:NO];
    [byteData appendBytes:msgType inFront:NO];
    //添加消息长度（如果是语音就有值，如果没有就为0）
    [byteData appendBytes:intType inFront:NO];
    [byteData appendInt:length inFront:NO];
    //添加消息正文
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(audioString.length) inFront:NO];
    [byteData appendString:audioString inFront:NO];
    //添加房间id
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(room.length) inFront:NO];
    [byteData appendString:room inFront:NO];
    //添加发送时间
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeStamp = [NSString stringWithFormat:@"%llu",recordTime];
    [byteData appendBytes:strType inFront:NO];
    [byteData appendInt:(int)(timeStamp.length) inFront:NO];
    [byteData appendString:timeStamp inFront:NO];
    
    //拼接命令＋长度
    [byteData appendInt:(int)byteData.data.length inFront:YES];
    [byteData appendBytes:sendMsg inFront:YES];
    
    [byteData showBytes];
    [self.outputStream write:[byteData.data bytes] maxLength:byteData.data.length];
}


#pragma mark- 注销
- (void)loginOut{ ShowLog

    if (self.username.length > 0 && self.passwrod.length > 0) {
        ByteData *byteData = [[ByteData alloc] init];
        Byte heartBeatCommond[] = {3};
        Byte intType[] = {2};
        
        //拼接请求id
        [byteData appendBytes:intType inFront:NO];
        [byteData appendInt:-1 inFront:NO];
        
        //拼接命令＋长度
        [byteData appendInt:(int)byteData.data.length inFront:YES];
        [byteData appendBytes:heartBeatCommond inFront:YES];
        
        [byteData showBytes];
        [self.outputStream write:[byteData.data bytes] maxLength:byteData.data.length];
    }
}


#pragma mark- 获取字符串长度
- (int)stringLength:(NSString*)string
{
    return (int)[string dataUsingEncoding:NSUTF8StringEncoding].length;
}

- (NSString*)stringFromCurrentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyymmddhhmmss"];
    return [formatter stringFromDate:[NSDate date]];
}


#pragma mark- 生成命令id
- (int)mID
{
    _mID += 1;
    return _mID;
}

- (MessageService *)messageService
{
    if (!_messageService) {
        _messageService = [[MessageService alloc] init];
    }
    return _messageService;
}

#pragma mark- 页面底部


@end

