//
//  InterfaceController.m
//  AppgroupExample WatchKit Extension
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import "InterfaceController.h"
#import "Event.h"
#import "EventDAO.h"
#import "EventRowController.h"
#import "DataManager.h"
@interface InterfaceController()

@end

@implementation InterfaceController

void syncCallback (CFNotificationCenterRef center,
                   void * observer,
                   CFStringRef name,
                   const void * object,
                   CFDictionaryRef userInfo) {
    
    //Data in the phone has changed
    InterfaceController *controller = (__bridge InterfaceController *)(observer);
    [controller loadData];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    //load store
    [DataManager sharedDataManager];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), syncCallback,
                                    CFSTR("WATCH_NEEDS_SYNC"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // Configure interface objects here.
    [self loadData];
}
-(void) loadData
{
    EventDAO *eventDAO = [[EventDAO alloc] init];
    NSArray *events = [eventDAO listEvents];
    [self.timestampsTable setNumberOfRows:events.count withRowType:@"EventRowController"];
    
    for (int index =0; index < events.count; index++) {
        Event *e = events[index];
        EventRowController *row = [self.timestampsTable rowControllerAtIndex:index];
        [row.timestampLabel setText:[[e valueForKey:@"timeStamp"] description]];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



