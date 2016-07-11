//
//  ByteManager.m
//  BytePractice
//
//  Created by ZhuXiaoyan on 15/10/12.
//  Copyright © 2015年 张宝. All rights reserved.
//

#import "ByteManager.h"

@implementation ByteManager

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _byteData = [[ByteData alloc] initWithData:data];
        _values = [NSMutableArray new];
        [self readDataToValues];
    }
    return self;
}

- (void)readDataToValues
{
    //打印原始数据字节码
    [self.byteData showBytes];
    //1、读取命令
    Byte *commond = [self.byteData readByte];
    [self.values addObject:@([self.byteData asciiOfByte:commond])];
    if ([self.byteData byte:commond EqualTo:16]) {
        [self.values addObject:@"指令错误！"];
    }else{
        //2、读取数据总长度
        [self.byteData readInt];
        //3、按类型、长度、数据的顺序读取数据（注意，byte和int类型的数据不需要读长度，字符串需要）
        while ([self.byteData hasMoreData]) {
            Byte *type = [self.byteData readByte];
            if ([self.byteData byte:type EqualTo:2]) {
                //读整形
                int intValue = [self.byteData readInt];
                [self.values addObject:@(intValue)];
                
            }else if ([self.byteData byte:type EqualTo:4]){
                NSString *stringValue = nil;
                //读字符串需要先读长度，再读字符串,如果长度为负数，直接返回空字符串“”
                int stringLength = [self.byteData readInt];
                if (stringLength > 0) {
                    stringValue = [self.byteData readStringWithLength:stringLength];
                }else{
                    stringValue = @"";
                }
                if (stringValue.length > 0) {
                    [self.values addObject:stringValue];
                }else{
                    [self.values addObject:@""];
                }
                
            }else if([self.byteData byte:type EqualTo:1]){
                Byte *byte = [self.byteData readByte];
                int intValue = [self.byteData asciiOfByte:byte];
                [self.values addObject:@(intValue)];
            }
        }
    }
    
}

- (void)showValues
{
    NSLog(@"[");
    for (id value in self.values){
        NSLog(@"%@",value);
    }
    NSLog(@"]");
}

@end
