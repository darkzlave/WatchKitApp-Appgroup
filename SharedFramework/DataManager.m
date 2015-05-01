//
//  DataManager.m
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import "DataManager.h"
#import "ImportManager.h"

@implementation DataManager

static DataManager * _sharedStore = nil;
static dispatch_once_t onceToken;

+ (DataManager *)sharedDataManager
{
    //thread-safe way to create a singleton
    dispatch_once(&onceToken, ^{
        _sharedStore = [[DataManager allocWithZone:nil] init];
    });
    
    return _sharedStore;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init
{
    if (self = [super init]) {
        [self buildContexts];
    }
    return self;
}

- (void)buildContexts
{
    //Import default database before creating the store
    [ImportManager importBundledDatabase];
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        /*Setting the undo manager to nil means that:
         You don’t waste effort recording undo actions for changes (such as insertions) that will not be undone;
         The undo manager doesn’t maintain strong references to changed objects and so prevent them from being deallocated
         */
        [self.managedObjectContext setUndoManager:nil];
    }
}

#pragma mark - NSManagedObjectContext

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppgroupExample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    NSAssert([NSThread isMainThread], @"Main context is been used outside of the main thread"); // for the lolz
    return _managedObjectContext;
}

#pragma mark - Persistent Store Coordinator

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    //options for auto migrate
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES],
                              NSInferMappingModelAutomaticallyOption :[NSNumber numberWithBool:YES],
                              NSSQLitePragmasOption:@{ @"synchronous": @"OFF" }
                              };
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = nil;
    if (RUNNING_ON_APPGROUP) {
        storeURL = [DataManager applicationAppGroupDatabasePath];
        [self setupCoordinatorOnAppGroupWithURL:storeURL options:options];
    } else {
        storeURL = [NSURL fileURLWithPath:[DataManager applicationDocumentsDatabasePath] isDirectory:NO];
        [self setupCoordinatorOnDocumentsFolderWithURL:storeURL options:options];
    }
    
    return _persistentStoreCoordinator;
}

-(void) setupCoordinatorOnDocumentsFolderWithURL:(NSURL*)storeURL options:(NSDictionary*)options
{
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        [self deleteAndSyncDatabaseInPath:[[storeURL URLByDeletingLastPathComponent] path]];
    }
}

-(void) setupCoordinatorOnAppGroupWithURL:(NSURL*)storeURL options:(NSDictionary*)options
{
    NSURL *pathDatabaseDocuments = [NSURL fileURLWithPath:[DataManager applicationDocumentsDatabasePath] isDirectory:NO];
    NSString *rootPathAppGroup = [[DataManager applicationAppGroupDirectory] path];
    NSString *rootPathDocuments = [DataManager applicationDocumentsDirectory];
    NSError *error;
    //check if we have the database on the old path in documents folder, if it is then let's do a migration
    BOOL openStoreOnNewPath = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[pathDatabaseDocuments path]]) {
        
        //delete files on the new location if we have them also on the old location and we haven't migrated ourselves
        if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
            [self deleteSqlFilesOnDirectory:rootPathAppGroup];
        }
        
        //open store on OLD Documents Folder, this is needed for the migration
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:pathDatabaseDocuments
                                                             options:options
                                                               error:nil]) {
            // Handle the error.
            [self deleteAndSyncDatabaseInPath:rootPathDocuments];
            openStoreOnNewPath = NO;
        }  else {
            //if we are on iOS 8 we need to do a migration if is possible
            if (IS_IOS8) {
                NSPersistentStore *oldStore = [[_persistentStoreCoordinator persistentStores] lastObject];//there should be only one store
                
                if (oldStore != nil){
                    
                    // Perform the migration
                    NSPersistentStore *newStore = [_persistentStoreCoordinator migratePersistentStore:oldStore toURL:storeURL options:options withType:NSSQLiteStoreType error:&error];
                    
                    if (newStore == nil) { // newStore is always nil and error is also nil
                        // Handle the migration error
                        NSLog(@"Error migrating store ");
                        [self deleteAndSyncDatabaseInPath:rootPathDocuments];
                        openStoreOnNewPath = NO;
                    } else {
                        NSLog(@"Successfully migrated store to %@", storeURL.path);
                        openStoreOnNewPath = NO;
                        //delete the files on the old path
                        [self deleteSqlFilesOnDirectory:rootPathDocuments];
                        
                    }
                } else {
                    openStoreOnNewPath = YES;
                }
            } else {
                openStoreOnNewPath = NO;
            }
        }
    }
    
    //if we need to we will open the persistent store on the new location
    if(openStoreOnNewPath) {
        //if we dont have any data on the old locations then we would just open the persistent store on the new app group location
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:options
                                                               error:&error]) {
            [self deleteAndSyncDatabaseInPath:rootPathAppGroup];
        }
    }
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Paths

+ (NSURL *)applicationAppGroupDatabasePath
{
    NSURL *appgroup = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    return [appgroup URLByAppendingPathComponent:DATABASE_NAME];
}

+ (NSString *)applicationDocumentsDatabasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return [basePath stringByAppendingPathComponent:DATABASE_NAME];
}

+ (NSURL *)applicationAppGroupDirectory
{
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
}

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

#pragma mark - Migration
+ (BOOL)needsToApplyMigration
{
    if(RUNNING_ON_APPGROUP){
        NSURL *oldURL = [NSURL fileURLWithPath:[self applicationDocumentsDatabasePath]];
        BOOL fileAtOldPath = [[NSFileManager defaultManager] fileExistsAtPath:[oldURL path]];
        if(fileAtOldPath){
            return YES;
        }
    }
    return NO;
}

#pragma mark - Delete and Safe database

-(void) deleteAndSyncDatabaseInPath:(NSString*)path
{
    // Handle the error.
    [self deleteSqlFilesOnDirectory:path];
    _persistentStoreCoordinator = nil;
    //do initial import again since the current database was corrupted
    [ImportManager importBundledDatabase];
    
    [self persistentStoreCoordinator];
}

-(void) deleteSqlFilesOnDirectory:(NSString*)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:directory]
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension CONTAINS[cd] 'sqlite'"];
    for (NSString *path in[contents filteredArrayUsingPredicate:predicate]) {
        // Enumerate each .sqllite file in directory
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
    }
}

@end
