//
//  ApplicationProperties.h
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 01/05/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//
#import <UIKit/UIDevice.h>

#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define APP_PURPLE [UIColor colorWithRed:130 / 255.0f green:120 / 255.0f blue:200 / 255.0f alpha:1.0f]
#define DATABASE_NAME @"Database.sqlite"
#define APP_GROUP_ID @"group.com.cocoaheads.AppGroupBaby"

//Modify this property back and forth to test migrations from Documents Folder to AppGroup
#define RUNNING_ON_APPGROUP YES