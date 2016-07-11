//
//  AddClockTVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/7.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "AddClockTVC.h"
#import "UUProgressHUD.h"
#import "Mp3Recorder.h"
#import "UUAVAudioPlayer.h"
#import "HttpManager.h"
#import "ProgressHUD.h"
#import "NSPublic.h"
#import "amrFileCodec.h"
#import "Base64.h"



@interface AddClockTVC ()<Mp3RecorderDelegate,UUAVAudioPlayerDelegate>
{
    BOOL isbeginVoiceRecord;
    UUAVAudioPlayer *audio;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    BOOL contentVoiceIsPlaying;
}
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UIDatePicker *time;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *repeatSwitches;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (nonatomic,strong) NSData *voiceData;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImage;
@property (nonatomic,strong) NSString *voiceID;

@property (nonatomic) BOOL isVoiceChanged;

@end

@implementation AddClockTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
    self.recordBtn.clipsToBounds = YES;
    self.recordBtn.layer.cornerRadius = 5.0;
    [self.recordBtn setTitle:@"按住录音" forState:UIControlStateNormal];
    [self.recordBtn setTitle:@"松开发送" forState:UIControlStateHighlighted];
    [self.recordBtn addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.recordBtn addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self.recordBtn addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    self.voiceImage.image = [UIImage imageNamed:@"chat_animation3"];
    self.voiceImage.animationImages = [NSArray arrayWithObjects:
                                  [UIImage imageNamed:@"chat_animation1"],
                                  [UIImage imageNamed:@"chat_animation2"],
                                  [UIImage imageNamed:@"chat_animation3"],nil];
    self.voiceImage.animationDuration = 1;
    
    if (self.clock) {
        
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"HH:mm";
        self.time.date = [fmt dateFromString:[self.clock.clockTime substringWithRange:NSMakeRange(0, 5)]];
        
        NSArray *strs = [self.clock.schedule componentsSeparatedByString:@","];
        
        for (int i = 0; i < strs.count; i++) {
            
            int index = [strs[i] intValue] - 1;
            if (index < 0) {
                return;
            }
            UISwitch *clockSwitch = self.repeatSwitches[index];
            clockSwitch.on = YES;
        }
        
        if (self.clock.msgId.length > 0) {
            [self fetchNewMessageWithID:self.clock.msgId];
        }
        
    }

}


- (void)setVoiceData:(NSData *)voiceData
{
    _voiceData = voiceData;
    if (voiceData) {
        self.indicatorView.hidden = NO;
    }else{
        self.indicatorView.hidden = YES;
    }
}


- (IBAction)play:(UITapGestureRecognizer *)sender
{
    if(!contentVoiceIsPlaying){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
        contentVoiceIsPlaying = YES;
        audio = [UUAVAudioPlayer sharedInstance];
        audio.delegate = self;
        [audio playSongWithData:self.voiceData];
    }else{
        [self UUAVAudioPlayerDidFinishPlay];
    }

}


- (void)UUAVAudioPlayerBeiginPlay
{
    NSLog(@"playing.....");
    [self.voiceImage startAnimating];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    [self.voiceImage stopAnimating];
    contentVoiceIsPlaying = NO;
    NSLog(@"ended");
    [[UUAVAudioPlayer sharedInstance]stopSound];
}

#pragma mark - 录音touch事件
- (void)beginRecordVoice:(UIButton *)button
{
    [MP3 startRecord];
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    [UUProgressHUD show];
}

- (void)endRecordVoice:(UIButton *)button
{

    if (playTimer) {
        [MP3 stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
}

- (void)cancelRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [MP3 cancelRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    [UUProgressHUD dismissWithError:@"Cancel"];
}

- (void)RemindDragExit:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"Release to cancel"];
}

- (void)RemindDragEnter:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"Slide up to cancel"];
}


- (void)countVoiceTime
{
    playTime ++;
    if (playTime>=20) {
        [self endRecordVoice:nil];
    }
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    [UUProgressHUD dismissWithSuccess:@"Success"];
    self.voiceData = voiceData;
    self.isVoiceChanged = YES;
    //缓冲消失时间 (最好有block回调消失完成)
    self.recordBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.recordBtn.enabled = YES;
    });
}

- (void)failRecord
{
    [UUProgressHUD dismissWithSuccess:@"时间太短!"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.recordBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.recordBtn.enabled = YES;
    });
}
- (IBAction)save:(UIBarButtonItem *)sender {
    
    if (self.voiceData && self.isVoiceChanged) {
        [self uploadRecord];
    }else{
        [self addClock];
    }
}

#pragma mark- 添加闹钟
- (void)addClock
{
    [ProgressHUD show:@"保存闹钟中..." Interaction:YES];
    NSString *url = @"chunhui/m/terminal@updateClockSetting.do";
    NSString *cid = @"";
    if (self.clock) {
        cid = self.clock.cid;
    }
    NSString *imei = [[NSPublic shareInstance] getImei];
    NSString *clock = [self selectedTime];
    NSString *schedule = [self connectSchedule];
    NSString *msgId = self.voiceID ? self.voiceID : @"";
    NSString *queryString = [NSString stringWithFormat:@"id=%@&imei=%@&clock=%@&schedule=%@&startDate=%@&msgId=%@",cid,imei,clock,schedule,@"",msgId];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (jsonData) {
            NSString *status = jsonData[@"status"];
            if ([status isEqualToString:@"0"]) {
                [ProgressHUD showSuccess:@"成功!" Interaction:YES];
            }else{
                [ProgressHUD showError:@"失败！" Interaction:YES];
            }
        }else{
            [ProgressHUD showError:@"网络错误！" Interaction:YES];
        }

    }];
}

#pragma mark- 上传录音
- (void)uploadRecord
{
    [ProgressHUD show:@"上传录音文件中..." Interaction:YES];
    NSString *url = @"chunhui/m/data@addClockMsg.do";
    NSString *type = @"2";
    NSString *msgId = @"";
    NSString *imei = [[NSPublic shareInstance] getImei];
    NSData *AudioData = EncodeWAVEToAMR(self.voiceData,1,16);
    NSString *msg = [AudioData base64EncodedStringWithOptions:0];
    
    NSLog(@"%@",msg);
    
    NSString *queryString = [NSString stringWithFormat:@"type=%@&msgId=%@&imei=%@&msg=%@",type,msgId,imei,msg];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (jsonData) {
            NSString *status = jsonData[@"status"];
            if ([status isEqualToString:@"0"]) {
                [ProgressHUD showSuccess:@"录音上传成功!" Interaction:YES];
                self.voiceID = jsonData[@"data"][@"msgId"];
                [self addClock];
            }else{
                [ProgressHUD showError:@"录音上传失败！" Interaction:YES];
            }
        }else{
            [ProgressHUD showError:@"网络错误！" Interaction:YES];
        }
    }];
}

#pragma mark- 获取录音
- (void)fetchNewMessageWithID:(NSString*)msgID
{
    NSString *url = @"chunhui/m/data@getClockMsg.do";
    NSString *paramString = [NSString stringWithFormat:@"msgId=%@",msgID];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:url
                                                            portID:80
                                                       queryString:paramString
                                                          callBack:^(id jsonData, NSError *error) {
                                                              NSDictionary *temp = jsonData;
                                                              NSString *status = temp[@"status"];
                                                              if ([status isEqualToString:@"0"]) {
                                                                  NSString *voiceStr = jsonData[@"data"][@"msg"];
                                                                  NSData *voiceData = [Base64 decodeString:[voiceStr stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
                                                                  self.voiceData = DecodeAMRToWAVE(voiceData);
                                                              }

                                                          }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString*)selectedTime
{
    NSDate *date = self.time.date;
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"HH:mm";
    NSString* dateString = [fmt stringFromDate:date];
    return [dateString stringByAppendingString:@":00"];
}

- (NSString*)connectSchedule
{
    NSString *scheduleString = @"";
    for (int i = 0; i < self.repeatSwitches.count; i++) {
        UISwitch *switcher = self.repeatSwitches[i];
        if (switcher.isOn) {
            scheduleString = [scheduleString stringByAppendingString:[NSString stringWithFormat:@"%d,",i+1]];
        }
    }
    if (scheduleString.length > 0) {
        return [scheduleString substringToIndex:scheduleString.length-1];
    }else{
        return @"-1";
    }
}

@end
