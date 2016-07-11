//
//  EULAVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/10.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "EULAVC.h"
#import "CommonConstants.h"
@implementation EULAVC
- (IBAction)agree:(UIBarButtonItem *)sender {
    
    ToUserDefaults(@"EULA", @(YES));
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)disAgree:(UIBarButtonItem *)sender {
    
    ToUserDefaults(@"EULA", @(NO));
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
