//
//  PointsVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointsVC : UIViewController

@property (nonatomic,strong) NSString *urlString;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
