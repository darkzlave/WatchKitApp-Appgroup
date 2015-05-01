//
//  AppDelegate.m
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import "AppDelegate.h"
#import "MigrationViewController.h"
#import "DataManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = APP_PURPLE;
    // Check if we need to do a data migration
    if ([DataManager needsToApplyMigration]) {
        MigrationViewController *importViewController = [[MigrationViewController alloc] initWithApplication:application
                                                                                                               launchOptions:launchOptions];
        [self.window setRootViewController:importViewController];
        [self.window makeKeyAndVisible];
        return YES;
    }
    else {
        return [self finishLaunchingWithApplication:application withOptions:launchOptions];
    }
}

- (BOOL)finishLaunchingWithApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions
{
    //Start core data stack
    [DataManager sharedDataManager];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainController = storyboard.instantiateInitialViewController;
    [self.window setRootViewController:mainController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[DataManager sharedDataManager] saveContext];
}


@end
