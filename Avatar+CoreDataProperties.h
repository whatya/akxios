//
//  Avatar+CoreDataProperties.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/22.
//  Copyright © 2015年 whtriples. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Avatar.h"

NS_ASSUME_NONNULL_BEGIN

@interface Avatar (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *userName;

@end

NS_ASSUME_NONNULL_END
