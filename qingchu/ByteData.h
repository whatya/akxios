//
//  ByteData.h
//  BytePractice
//
//  Created by 张宝 on 15/10/11.
//  Copyright © 2015年 张宝. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ByteData : NSObject

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSData *restData;

- (void)showBytes;
- (void)showRestBytes;
- (BOOL)hasMoreData;

#pragma mark- 写数据
- (instancetype)initWithData:(NSData*)data;

- (void)appendInt:(int)intValue inFront:(BOOL)isFront;

- (void)appendString:(NSString*)stringValue inFront:(BOOL)isFront;

- (void)appendBytes:(Byte*)byte inFront:(BOOL)isFront;

#pragma mark- 读数据
- (int)readInt;

- (Byte*)readByte;

- (NSString*)readStringWithLength:(int)length;

#pragma mark- 自己比较
- (BOOL)byte:(Byte*)byte EqualTo:(int)value;

#pragma mark- 数字字符的ascll码
- (int)asciiOfByte:(Byte*)byte;

- (int)bytesToInt:(Byte*)byte;

@end
