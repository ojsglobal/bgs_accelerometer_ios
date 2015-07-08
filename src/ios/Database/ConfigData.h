//
//  ConfigData.h
//  pluginAppdemo
//
//  Created by Dotsquares on 4/30/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ConfigData : NSManagedObject

@property (nonatomic, retain) NSNumber * pollPeriod;
@property (nonatomic, retain) NSNumber * daysToKeep;

@end
