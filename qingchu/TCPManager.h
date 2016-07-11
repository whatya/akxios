//
//  TCPManager.h
//  TcpManager
//
//  Created by ZhuXiaoyan on 15/10/12.
//  Copyright © 2015年 whatya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPManager : NSObject<NSStreamDelegate>

//输入输出流
@property (nonatomic,strong) NSInputStream  *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;

//TCP登录用户名和密码
@property (nonatomic,strong) NSString       *username;
@property (nonatomic,strong) NSString       *passwrod;

//地址和端口号
@property (nonatomic,assign) NSString       *IPAddress;
@property (nonatomic,assign) int             portNumber;
//指令id(自增）
@property (nonatomic,assign) int             mID;


+ (TCPManager *)sharedInstance;

//建立连接
- (void)initNetworkCommunication;

//登录
- (void)loginWithUsername:(NSString*)username andPwd:(NSString*)password;

//注销
- (void)loginOut;

//发送文本数据
- (void)sendText:(NSString*)text roomId:(NSString*)room senderId:(NSString*)sender;

//发送图片数据
- (void)sendImageString:(NSString*)imageString roomId:(NSString*)room senderId:(NSString*)sender;

//发送音频数据
- (void)sendAudioString:(NSString*)audioString audioLenth:(int)length roomId:(NSString*)room senderId:(NSString*)sender;

//指令id获取
- (int)mID;

//关闭输入输出流
- (void)closeStream;

//获取离线消息
- (void)getPendingMessages;

//发送心跳包
- (void)heartBeat;

@end
