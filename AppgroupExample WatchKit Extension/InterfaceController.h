//
//  InterfaceController.h
//  AppgroupExample WatchKit Extension
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *timestampsTable;

@end
