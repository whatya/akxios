//
//  AudiRecordView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/26.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "AudiRecordView.h"
#import "SDRecordButton.h"
#import "CommonConstants.h"
#import "amrFileCodec.h"
#import "Base64.h"
#import "Mp3Recorder.h"
#import "UUAVAudioPlayer.h"

const int videoDuration  = 8;
#define ThisRedColor  [UIColor colorWithRed:233/255.0 green:59/255.0 blue:60/255.0 alpha:1]
@interface AudiRecordView ()<Mp3RecorderDelegate,UUAVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *alphView;
@property (weak, nonatomic) IBOutlet SDRecordButton *recordBtn;
@property (weak, nonatomic) IBOutlet UILabel *countDownLB;
@property (nonatomic, strong)          NSTimer        *progressTimer;
@property (nonatomic, strong)          NSTimer        *countdownTimer;
@property (nonatomic)                  CGFloat        progress;
@property (nonatomic)                   int           seconds;
@property (weak, nonatomic) IBOutlet UILabel *timeTooShortLB;

@property (nonatomic)                   BOOL          isbeginVoiceRecord;
@property (nonatomic, strong)          Mp3Recorder    *MP3;


@end

@implementation AudiRecordView

- (void)awakeFromNib
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.alphView addGestureRecognizer:tap];
    
    [self configureButtonWithColor:ThisRedColor progressColor:[UIColor whiteColor]];
    
    self.MP3 = [[Mp3Recorder alloc]initWithDelegate:self];

    
}

- (void)dismiss:(UITapGestureRecognizer *)sender {
    [self removeFromSuperview];
}
- (void)configureButtonWithColor:(UIColor*)color progressColor:(UIColor *)progressColor {
    
    // Configure colors
    self.recordBtn.buttonColor = color;
    self.recordBtn.progressColor = progressColor;
    
    // Add Targets
    [self.recordBtn addTarget:self action:@selector(recording) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpOutside];
    
}

- (void)recording {
    NSLog(@"Started recording");
    [self.progressTimer invalidate];
    [self.countdownTimer invalidate];
    [self.MP3 startRecord];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    self.seconds = 8;
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    NSLog(@"%lu",(unsigned long)voiceData.length);
    [self.delegate gotVoiceData:voiceData withLength:8 - self.seconds];
    [self fadeOut];
}

- (void)failRecord
{
    self.timeTooShortLB.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timeTooShortLB.hidden = YES;
        [self.countdownTimer invalidate];
        [self.progressTimer invalidate];
        [self.recordBtn setProgress:0];
    });
}

- (void)pausedRecording {
    [self.progressTimer invalidate];
    [self.MP3 stopRecord];
}

- (void)updateLabel
{
    self.seconds -= 1;
    self.countDownLB.text = [NSString stringWithFormat:@"%d",self.seconds];
    if (self.seconds == 0) {
        [self.countdownTimer invalidate];
        [self.MP3 stopRecord];
    }
}
- (void)updateProgress {
    self.progress += 0.05/videoDuration;
    [self.recordBtn setProgress:self.progress];
    if (self.progress >= 1)
        [self.progressTimer invalidate];
}

- (void)fadeOut
{
    [UIView animateWithDuration:1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
