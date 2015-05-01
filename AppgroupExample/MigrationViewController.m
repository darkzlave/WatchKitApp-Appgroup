//
//  MigrationViewController.m
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 01/05/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import "MigrationViewController.h"
#import "DataManager.h"
#import "AppDelegate.h"

@interface MigrationViewController ()

@property (nonatomic, strong) UIApplication *application;
@property (nonatomic, strong) NSDictionary *launchOptions;

@end

@implementation MigrationViewController

- (id)initWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions
{
    self = [self init];
    self.application = application;
    self.launchOptions = launchOptions;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(doMigrationDelayed) withObject:nil afterDelay:1.0];
}

- (void)doMigrationDelayed
{
    [DataManager sharedDataManager];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate finishLaunchingWithApplication:self.application withOptions:self.launchOptions];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
