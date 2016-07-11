//
//  WXShareVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/28.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "WXShareVC.h"
#import "WXApi.h"
#import "WXMediaMessage+messageConstruct.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#define BUFFER_SIZE 1024 * 100

@interface WXShareVC ()

@property (weak, nonatomic) IBOutlet UILabel *imeiLB;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@end

@implementation WXShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imeiLB.text = [NSString stringWithFormat:@"邀请码：%@",self.imei];
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        self.shareBtn.hidden = NO;
    }else{
        self.shareBtn.hidden = YES;
    }
}

- (IBAction)WXShare:(UIButton *)sender
{
    [self sendAppMessage];
}

- (void)setImei:(NSString *)imei
{
    _imei = imei;
    self.imeiLB.text = [NSString stringWithFormat:@"邀请码：%@",imei];
}

- (void) sendAppMessage
{
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    UIImage *thumbImage = [UIImage imageNamed:@"shareIcon"];
    [self sendAppContentData:data
                     ExtInfo:@"<xml>extend info</xml>"
                      ExtURL:@"https://itunes.apple.com/us/app/an-kang-xin/id990174637?l=zh&ls=1&mt=8"
                       Title:@"安康信"
                 Description:[NSString stringWithFormat:@"邀请码:%@",self.imei]
                  MessageExt:@""
               MessageAction:@"<action>dotaliTest</action>"
                  ThumbImage:thumbImage
                     InScene:0];
}

- (BOOL)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene {
    
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = info;
    ext.url = url;
    ext.fileData = data;
    
    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:messageExt
                                                 MessageAction:action
                                                    ThumbImage:thumbImage
                                                      MediaTag:nil];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
    
}


@end
