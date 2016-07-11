//
//  CoreDataHelper.h
//  qingchu
//
//  Created by 张宝 on 15/10/20.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext      *context;
@property (nonatomic, readonly) NSManagedObjectModel        *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator*coordinator;
@property (nonatomic, readonly) NSPersistentStore           *store;

- (void)setupCoreCata;
- (void)saveContext;

@end
