//
//  ScannerVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/15.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "ScannerVC.h"
#import <AVFoundation/AVFoundation.h>
@interface ScannerVC ()
<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *scanZoneView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBTN;
@property (strong, nonatomic) AVCaptureSession * session;
@property (nonatomic) BOOL valueGot;
@end

@implementation ScannerVC
- (IBAction)cancleIt:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scanZoneView.layer.borderWidth = 1;
    self.scanZoneView.layer.borderColor = [UIColor greenColor].CGColor;
    
    self.cancelBTN.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBTN.layer.borderWidth = 1.0;
    self.cancelBTN.layer.cornerRadius = 15.0;
    
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    [output setRectOfInterest:CGRectMake((screenHeight-200)/2/screenHeight,((screenWidth-200)/2)/screenWidth,200/screenHeight,200/screenWidth)];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [self.session startRunning];


}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        if (self.valueGot) {return;}
        self.valueGot = YES;
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        if (metadataObject.stringValue.length > 0) {
            [self.delegate setValue:metadataObject.stringValue forKey:@"barCode"];
            [self dismissViewControllerAnimated:YES completion:NULL];
            return;
        }
    }
}



@end
