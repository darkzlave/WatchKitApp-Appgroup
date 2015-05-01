//
//  DataManager.h
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject
+ (DataManager *)sharedDataManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
+ (BOOL)needsToApplyMigration;

#pragma mark - URLs
+ (NSString *)applicationDocumentsDirectory;
+ (NSURL *)applicationAppGroupDirectory;
+ (NSString *)applicationDocumentsDatabasePath;
+ (NSURL *)applicationAppGroupDatabasePath;
@end
