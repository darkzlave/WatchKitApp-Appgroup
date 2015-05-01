//
//  Event.h
//  AppgroupExample
//
//  Created by Phillipe Casorla Sagot on 13/04/15.
//  Copyright (c) 2015 PCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;

@end
