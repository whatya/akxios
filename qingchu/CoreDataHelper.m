//
//  CoreDataHelper.m
//  qingchu
//
//  Created by 张宝 on 15/10/20.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "CoreDataHelper.h"


@implementation CoreDataHelper

//if (debug == 1) {
//    NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
//}

#define debug 1

#pragma mark- FILES
NSString *storeFilename = @"AKX.sqlite";

#pragma mark- PATHS 应用程序文档目录的路径
- (NSString *)applicationDocumentsDirectory{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
//创建store子目录
- (NSURL *)applicationStoreDirectory
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]
                              URLByAppendingPathComponent:@"Stores"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
        }else{
            NSLog(@"FAILED to create Stores directory : %@",error);
        }
    }
    return storesDirectory;
}

- (NSURL *)storeURL{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    return [[self applicationStoreDirectory] URLByAppendingPathComponent:storeFilename];
}

#pragma mark- SETUP
- (id)init
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    self = [super init];
    if (!self) {
        return nil;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    return self;
}

- (void)loadStore
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    if (_store) {
        return;
    }
    NSDictionary *options = @{NSSQLitePragmasOption:@{@"journal_model":@"DELETE"}};
    NSError *error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:[self storeURL]
                                              options:options
                                                error:&error];
    if (!_store) {
        NSLog(@"Failed to add store. Error %@",error);
        abort();
    }else{
        if (debug == 1) {
            NSLog(@"Successfully added store:%@",_store);
        }
    }
}

- (void)setupCoreCata
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    [self loadStore];
}

#pragma mark- SAVING

- (void)saveContext
{
    if (debug == 1) {NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));}
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        }else{
            NSLog(@"Failed to save _context:%@",error);
        }
    }else{
        NSLog(@"SKIPPED _context save,there are no changes");
    }
}

@end
