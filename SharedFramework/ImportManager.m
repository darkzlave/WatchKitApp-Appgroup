//
//  ImportManager.m
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 01/05/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import "ImportManager.h"
#import "DataManager.h"

@implementation ImportManager

+ (void) importBundledDatabase
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Database" ofType:@"sqlite"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSURL *appgroupURL = [DataManager applicationAppGroupDirectory];
    NSString *documentsDirectoryNEW = [appgroupURL path]; // pointing to shared appgroup - enables shared data between main app and other extensions
    NSString *documentsDirectoryOLD = [DataManager applicationDocumentsDirectory];// default documents directory app
    
    NSString *databaseName = @"Database.sqlite";

    //create sql files paths
    NSString *finalOLDPath = [documentsDirectoryOLD stringByAppendingPathComponent:databaseName];
    NSString *finalNEWPath = [documentsDirectoryNEW stringByAppendingPathComponent:databaseName];
    NSLog(@"PATH %@", finalNEWPath);
    
    //install the default new database if it doesnt exist on our Appgroup or the documents folder
    if (![fileManager fileExistsAtPath:finalNEWPath] && ![fileManager fileExistsAtPath:finalOLDPath] && plistPath) {
        NSString *finalPath = RUNNING_ON_APPGROUP? finalNEWPath : finalOLDPath;
        [[NSFileManager defaultManager] copyItemAtPath:plistPath toPath:finalPath error:nil];
        
        NSURL *urlPath = [NSURL fileURLWithPath:finalNEWPath isDirectory:NO];
        //Exclude this database from iCloud syncing
        BOOL success = [urlPath setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (!success) {
            NSLog(@"Error excluding %@ from backup %@", [urlPath lastPathComponent], error);
        }
    }
}

@end
