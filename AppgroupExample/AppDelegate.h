//
//  AppDelegate.h
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (BOOL)finishLaunchingWithApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;

@end

