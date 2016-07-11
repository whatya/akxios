//
//  ByteData.m
//  BytePractice
//
//  Created by 张宝 on 15/10/11.
//  Copyright © 2015年 张宝. All rights reserved.
//

#import "ByteData.h"

@interface ByteData ()


@end

@implementation ByteData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] initWithData:data];
        _restData = [[NSData alloc] initWithData:data];
    }
    return self;
}



- (void)showBytes
{
    Byte *bytes = (Byte *)[self.data bytes];
    printf("[");
    for(int i=0;i<[self.data length];i++){
        printf(" %d ",bytes[i]);
        
    }
    printf("]\n\n\n\n");
}

- (void)showRestBytes
{
    Byte *bytes = (Byte *)[self.restData bytes];
    printf("\n[");
    for(int i=0;i<[self.restData length];i++){
        printf(" %d ",bytes[i]);
        
    }
    printf("]\n");
}

- (BOOL)hasMoreData
{
    return self.restData.length > 0;
}

- (void)appendInt:(int)intValue inFront:(BOOL)isFront
{
    Byte *intBytes = [self intToBytes:intValue];
    if (isFront) {
        NSMutableData *tempData = [NSMutableData dataWithBytes:intBytes length:sizeof(intValue)];
        [tempData appendData:self.data];
        self.data = tempData;
    }else{
        [self.data appendBytes:intBytes length:sizeof(intValue)];
    }
}

- (void)appendString:(NSString *)stringValue inFront:(BOOL)isFront
{
    NSMutableData *stringData = [[NSMutableData alloc] initWithData:[stringValue dataUsingEncoding:NSUTF8StringEncoding]];
    if (isFront) {
        [stringData appendData:self.data];
        self.data = stringData;
    }else{
        [self.data appendData:stringData];
    }
}

- (void)appendBytes:(Byte *)byte inFront:(BOOL)isFront
{
    if (isFront) {
        NSMutableData *tempData = [NSMutableData dataWithBytes:byte length:1];
        [tempData appendData:self.data];
        self.data = tempData;
    }else{
        [self.data appendBytes:byte length:1];
    }
}

- (int)readInt
{
    NSData *intData = [self.restData subdataWithRange:NSMakeRange(0, 4)];
    self.restData = [self.restData subdataWithRange:NSMakeRange(4, self.restData.length-4)];
    return [self bytesToInt:(Byte*)[intData bytes]];
}

- (NSString *)readStringWithLength:(int)length
{
    if (length > self.restData.length) {
        length = (int)self.restData.length;
    }
    NSData *stringData = [self.restData subdataWithRange:NSMakeRange(0, length)];
    self.restData = [self.restData subdataWithRange:NSMakeRange(length, self.restData.length-length)];
    return [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
}

- (Byte *)readByte
{
    Byte *byte = (Byte*)[[self.restData subdataWithRange:NSMakeRange(0, 1)] bytes];
    self.restData = [self.restData subdataWithRange:NSMakeRange(1, self.restData.length-1)];
    return byte;
}

- (Byte*)intToBytes:(int)intValue
{
    static Byte src[4];
    src[0] = (Byte) ((intValue>>24) & 0xFF);
    src[1] = (Byte) ((intValue>>16)& 0xFF);
    src[2] = (Byte) ((intValue>>8)&0xFF);
    src[3] = (Byte) (intValue & 0xFF);
    return src;
}

- (int)bytesToInt:(Byte*)byte
{
    int value;
    value = (int) ( ((byte[0] & 0xFF)<<24)
                   |((byte[1] & 0xFF)<<16)
                   |((byte[2] & 0xFF)<<8)
                   |(byte[3] & 0xFF));
    return value;
}

- (BOOL)byte:(Byte*)byte EqualTo:(int)value
{
    Byte targetValue[] = {value};
    return byte[0] == targetValue[0];
}

- (int)asciiOfByte:(Byte *)byte
{
    
    for (int i = 0; i < 255; i ++) {
        Byte targetValue[] = {i};
        if (byte[0] == targetValue[0]) {
            return i;
        }
    }
    return -1;
}

@end
