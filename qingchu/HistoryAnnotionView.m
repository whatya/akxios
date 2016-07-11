//
//  HistoryAnnotionView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/13.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "HistoryAnnotionView.h"
#import "HistoryAnnotion.h"

@implementation HistoryAnnotionView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        HistoryAnnotion *historyAnnotion = self.annotation;
        switch (historyAnnotion.type) {
            case HistoryNormal:
                self.image = [UIImage imageNamed:@"historyNormal"];
                break;
            case HistoryStart:
                self.image = [UIImage imageNamed:@"historyStart"];
                break;
            case HistoryEnd:
                self.image = [UIImage imageNamed:@"historyEnd"];
                break;
            default:
                self.image = [UIImage imageNamed:@"historyNormal"];
                break;
        }
    }
    
    return self;
}

@end
