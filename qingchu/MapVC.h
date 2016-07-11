//
//  MapVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/11.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapVC : UIViewController

@property (nonatomic, assign) BOOL isMaster;
@property (weak, nonatomic) IBOutlet UIButton *secureBtn;
@property (nonatomic,strong) NSDictionary *alertLocation;

@end
