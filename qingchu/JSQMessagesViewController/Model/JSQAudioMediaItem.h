//
//  JSQAudioMediaItem.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/27.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "JSQMediaItem.h"

@interface JSQAudioMediaItem : JSQMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

@property (nonatomic, assign) int status;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) NSString *voiceContent;

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSNumber *duration;

- (instancetype)initWithFileURL:(NSURL *)fileURL Duration:(NSNumber *)duration;

- (void)startPlay;

- (void)stopPlay;

@end
