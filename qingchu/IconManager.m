//
//  IconManager.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/9.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "IconManager.h"
#import "Base64.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation IconManager

- (void)saveImage:(UIImage *)image withImei:(NSString *)imei
{
    dispatch_async(kBgQueue, ^{
        NSError *error0 = nil;
        NSString *jsonFileName = @"icons.json";
        NSString *iconString = [Base64 stringByEncodingData:UIImageJPEGRepresentation(image, 1)];
        NSMutableArray *iconsList = [self jsonFromJsonFile:jsonFileName];
        
        if (iconsList) {
            
            NSDictionary *tobeDeleted = nil;
            for (NSDictionary *iconDictionary in iconsList){
                if (iconDictionary[imei]) {
                    tobeDeleted = iconDictionary;
                }
            }
            
            if (tobeDeleted) {
                [iconsList removeObject:tobeDeleted];
            }
            
            [iconsList addObject:@{imei:iconString}];
        }else{
            iconsList = [[NSMutableArray alloc] init];
            [iconsList addObject:@{imei:iconString}];
        }
        
        NSData *jsonDataD = [NSJSONSerialization dataWithJSONObject:iconsList options:NSJSONWritingPrettyPrinted error:&error0];
        if (error0) {
            NSLog(@"转为NSData时出错:%@",[error0 localizedDescription]);
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonDataD encoding:NSUTF8StringEncoding];
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:jsonFileName];
        NSError *error = nil;
        
        BOOL flag = [jsonString writeToFile:storePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            NSLog(@"写入：%@ %@！",jsonFileName,flag?@"成功":@"失败");
        }
    });

}

- (UIImage *)imageWithImei:(NSString *)imei
{
    NSString *jsonFileName = @"icons.json";
    NSMutableArray *iconsList = [self jsonFromJsonFile:jsonFileName];
    if (iconsList) {
        for (NSDictionary *icon in iconsList){
            if (icon[imei]) {
                NSData *imageData = [Base64 decodeString: icon[imei]];
                 return [UIImage imageWithData: imageData];
            }
        }
        return nil;
    }else{
        return nil;
    }
}

- (NSString*)imageStringWithImei:(NSString*)imei
{
    NSString *jsonFileName = @"icons.json";
    NSMutableArray *iconsList = [self jsonFromJsonFile:jsonFileName];
    if (iconsList) {
        for (NSDictionary *icon in iconsList){
            if (icon[imei]) {
                return icon[imei];
            }
        }
        return nil;
    }else{
        return nil;
    }

}

- (NSMutableArray*)jsonFromJsonFile:(NSString*)jsonFileName
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *Json_path=[path stringByAppendingPathComponent:jsonFileName];
    NSData *data=[NSData dataWithContentsOfFile:Json_path];
    NSError *error = nil;
    if (data) {
        NSArray* jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
        return [jsonObject mutableCopy];
        
    }else{
        return nil;
    }
}

@end
