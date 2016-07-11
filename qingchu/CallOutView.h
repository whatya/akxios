//
//  CallOutView.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/12.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallOutRouteAction)();

@interface CallOutView : UIView
@property (weak, nonatomic) IBOutlet UILabel *placeTypeLB;

@property (weak, nonatomic) IBOutlet UILabel *timeLB;
@property (weak, nonatomic) IBOutlet UILabel *addressLB;
@property (nonatomic, copy) CallOutRouteAction routeAction;
@property (nonatomic, copy) CallOutRouteAction circleAction;
@property (nonatomic, copy) CallOutRouteAction hospitalAction;
@property (nonatomic, copy) CallOutRouteAction medicineAction;
@property (nonatomic, copy) CallOutRouteAction navigateAction;
@property (weak, nonatomic) IBOutlet UIButton *secureBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleWidthCST;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *routeWidthCST;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hospitalWidthCST;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *medicineWidthCST;

@end
