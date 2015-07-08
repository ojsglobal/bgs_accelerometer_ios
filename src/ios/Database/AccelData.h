//
//  AccelData.h
//  pluginAppdemo
//
//  Created by Dotsquares on 5/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AccelData : NSManagedObject

@property (nonatomic, retain) NSNumber * fltLastAccel;
@property (nonatomic, retain) NSString * saveDate;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * z;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
