//
//  CallOutView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/12.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "CallOutView.h"
#import "CommonConstants.h"
#import "BubbleView.h"

@interface CallOutView ()


@property (weak, nonatomic) IBOutlet BubbleView *bubbleView;
@property (weak, nonatomic) IBOutlet UIButton *routeBtn;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UIButton *hospitalBtn;
@property (weak, nonatomic) IBOutlet UIButton *medicineBtn;
@property (weak, nonatomic) IBOutlet UIView *lineView;



@end

@implementation CallOutView

- (void)awakeFromNib
{
//    AddCornerBorder(self.routeBtn, self.routeBtn.width/2, 2, [WhiteColor CGColor]);
//    AddCornerBorder(self.secureBtn, self.secureBtn.width/2, 2, [WhiteColor CGColor]);
//    
//    AddCornerBorder(self.hospitalBtn, self.hospitalBtn.width/2, 2, [WhiteColor CGColor]);
//    AddCornerBorder(self.medicineBtn, self.medicineBtn.width/2, 2, [WhiteColor CGColor]);
    
    //AddCornerBorder(self.circleView, self.circleView.width/2, 0, [RedColor CGColor]);
    
    AddConerWithShadow(self.circleView, self.circleView.width/2, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
    AddConerWithShadow(self.routeBtn, self.routeBtn.width/2, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
    AddConerWithShadow(self.secureBtn, self.secureBtn.width/2, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
    AddConerWithShadow(self.medicineBtn, self.medicineBtn.width/2, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
    AddConerWithShadow(self.hospitalBtn, self.hospitalBtn.width/2, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
    AddConerWithShadow(self.lineView, 0, 0, nil, [UIColor blackColor], 0.4, CGSizeMake(0, 0));
}

- (IBAction)secure:(UIButton *)sender
{
    ShowLog;
    CallOutRouteAction temp = self.circleAction;
    if (temp) {
        temp();
    }
}
- (IBAction)route:(UIButton *)sender
{
    ShowLog;
    CallOutRouteAction temp = self.routeAction;
    if (temp) {
        temp();
    }
}

- (IBAction)hospitalSearch:(id)sender
{ShowLog
    CallOutRouteAction temp = self.hospitalAction;
    if (temp) {
        temp();
    }
}
- (IBAction)medecineSearch:(id)sender
{ShowLog
    CallOutRouteAction temp = self.medicineAction;
    if (temp) {
        temp();
    }
    
}

- (IBAction)navigate:(UIButton *)sender {
    
    CallOutRouteAction temp = self.navigateAction;
    if (temp) {
        temp();
    }
}


void AddConerWithShadow(id target,
                        CGFloat radius,
                        CGFloat borderWidth,
                        UIColor *borderColor,
                        UIColor *shadowColor,
                        float shadowOpacity,
                        struct CGSize shadowOffset)
{
    //[target setClipsToBounds:YES];
    CALayer *layer = [target layer];
    layer.cornerRadius = radius;
    //layer.shadowRadius = radius;
    layer.borderWidth = borderWidth;
    layer.borderColor = borderColor.CGColor;
    layer.shadowColor = shadowColor.CGColor;
    layer.shadowOpacity = shadowOpacity;
    layer.shadowOffset = shadowOffset;
    
    
}

@end
