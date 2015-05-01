//
//  EventDAO.m
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import "EventDAO.h"
#import <CoreData/CoreData.h>
#import "Event.h"
#import "DataManager.h"

@implementation EventDAO

-(NSArray*) listEvents
{
    NSManagedObjectContext *moc = [DataManager sharedDataManager].managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([Event class])
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    //we won't count or list entities marked as deleted
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    NSUInteger length = [array count];
    if (array != nil && length > 0) {
        return array;
    }
    return nil;
}

@end
