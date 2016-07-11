//
//  DailyAKXVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/22.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyAKXVC : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,strong) NSString *inputUrl;

@end
