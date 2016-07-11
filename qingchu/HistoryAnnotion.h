//
//  HistoryAnnotion.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/13.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


typedef NS_ENUM(NSInteger, HistoryType) {
    HistoryNormal = 0,
    HistoryStart,
    HistoryEnd
};

@interface HistoryAnnotion : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *subtitle;
@property (nonatomic) HistoryType       type;

@end
