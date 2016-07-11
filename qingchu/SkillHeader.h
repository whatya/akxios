//
//  SkillHeader.h
//  qingchu
//
//  Created by 张宝 on 16/7/8.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HeaderMoreAction)();

@interface SkillHeader : UIView

@property (weak, nonatomic) IBOutlet UILabel *headerLB;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (copy) HeaderMoreAction pushAction;


@end
