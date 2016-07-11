//
//  AudiRecordView.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/26.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol VoiceDelegate <NSObject>

- (void)gotVoiceData:(NSData*)data withLength:(int)length;

@end

@interface AudiRecordView : UIView

@property (nonatomic,weak) id<VoiceDelegate> delegate;


@end
