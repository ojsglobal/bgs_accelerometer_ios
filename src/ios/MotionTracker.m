//
//  MotionTracker.m
//  Location
//
//  Created by Dotsquares on 4/20/15.
//  Copyright (c) 2015 Location. All rights reserved.
//

#import "MotionTracker.h"
#import "bgaccelerometer.h"
#import "AccelData.h"
#import "ConfigData.h"
#import "AppDelegate.h"
#import "AccelData.h"
#import "CDVCoredataPlugin.h"


static MotionTracker *locationManager;
static CMMotionManager *motionManager;

@interface MotionTracker ()
{
    NSString *_xValue;
    NSString *_yValue;
    NSString *_zValue;
    NSString *_longitude;
    NSString *_latitude;
    NSDate* firstDate;
    NSMutableDictionary *lastLocation;
    
    float steps;
    float fltLastAccel;
    NSDateFormatter *dateFormater;
    NSInteger daysToKeep;
    
    int intMillisecondCount;
}
@end

@implementation MotionTracker

+ (MotionTracker *)sharedMotionManager {

    @synchronized(self) {
        if (locationManager == nil) {
            locationManager = [[MotionTracker alloc] init];
            motionManager = [[CMMotionManager alloc] init];
            
        }
    }
    return locationManager;
}
-(void)startMotionTracking:(NSMutableDictionary*)locationData{
    
    fltLastAccel= 0.0;
    firstDate= [[NSDate alloc]init];
    if(locationData != nil){
        lastLocation =locationData;
    }
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    
    
    
    //[self saveDataInLocalDB];
    
    
    //This is accelerometer update time period.
    motionManager.accelerometerUpdateInterval =  0.10f;//CDVAccelerrometerUpdateDuration;
    
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 
                                                 if(error){
                                                     DLog(@"%@", error);
                                                 }
                                             }];
}

#pragma mark Custom methods:
-(void)stopAcceleroMeter{
    [motionManager stopAccelerometerUpdates];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    intMillisecondCount++;
    NSLog(@"outputAccelertionData :%d", intMillisecondCount);
    
    CGFloat strength = 1.6f;
    daysToKeep =[self fetchConfigData];
    AccelData * accelData=[self fetchOnlySingleAccelData];
    
    if (accelData!=nil) {
        if(accelData.saveDate.length>0){
            
            NSInteger daysDifference= [self compareDates:accelData.saveDate];
            if(daysDifference >= daysToKeep){
                [self clearAllData];
                
                //Remove only 0 index object from the DB.
                
                
            }
            else{
                if (fabs(acceleration.x) > strength || fabs(acceleration.y) > strength || fabs(acceleration.z) > strength) {
                    steps++;
                    
                    NSLog(@"steps :%lu",(long)steps);
                    //Set X,Y,Z accelerometer values for saving in local DB.
                    currentMaxAccelX =acceleration.x;
                    currentMaxAccelY = acceleration.y;
                    currentMaxAccelZ = acceleration.z;
                    
                    //Save values in local db if any change in accelerometer movement.
                }
            }
        }
    }
    else{
        if (fabs(acceleration.x) > strength || fabs(acceleration.y) > strength || fabs(acceleration.z) > strength) {
            steps++;
            currentMaxAccelX =acceleration.x;
            currentMaxAccelY = acceleration.y;
            currentMaxAccelZ = acceleration.z;
            
            //[self saveDataInLocalDB];
        }
    }
}

-(NSInteger)fetchConfigData{
    
    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    
    //Fetch record from config table:
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ConfigData" inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if ([results count]>0) {
        ConfigData *configData= [results objectAtIndex:0];
        return [configData.daysToKeep integerValue];
    }
    else
        return 0;
}

-(AccelData *)fetchOnlySingleAccelData{
    
    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"AccelData" inManagedObjectContext:context]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if([results count]>0){

        //Fetching last object.
        AccelData *accel=results[0];
        return accel;
    }
    else
        return nil;
}
-(NSInteger)compareDates:(NSString*)lastDate{
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDate * fromDate = [formatter dateFromString:lastDate];
    NSDate* currentdate = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger startDay=[calendar ordinalityOfUnit:NSDayCalendarUnit
                                           inUnit:NSEraCalendarUnit
                                          forDate:fromDate];
    NSInteger endDay=[calendar ordinalityOfUnit:NSDayCalendarUnit
                                         inUnit:NSEraCalendarUnit
                                        forDate:currentdate];
    return (endDay-startDay);
}

-(void)saveDataInLocalDB{
    NSLog(@"saveDataInLocalDB");
    
    if(steps>0){
        NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
        AccelData *accelInfo = [NSEntityDescription
                                insertNewObjectForEntityForName:@"AccelData"
                                inManagedObjectContext:context];
        
        accelInfo.x = [NSNumber numberWithDouble:currentMaxAccelX];
        accelInfo.y = [NSNumber numberWithDouble:currentMaxAccelY];
        accelInfo.z = [NSNumber numberWithDouble:currentMaxAccelZ];
        
        accelInfo.saveDate = [NSString stringWithFormat:@"%@",[NSDate date]];
        accelInfo.latitude= [NSNumber numberWithFloat:[[lastLocation valueForKey:@"latitude"] floatValue]];
        accelInfo.longitude= [NSNumber numberWithFloat:[[lastLocation valueForKey:@"longitude"] floatValue]];
        
        accelInfo.fltLastAccel = [NSNumber numberWithFloat:fltLastAccel];
        accelInfo.steps= [NSNumber numberWithFloat:steps];
        
        
        
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }else{
            //[self fetchResultForRefreshingTable];
        }
    }
    else{
        NSLog(@"Steps count is 0. No need to save in DB.");
    }
    
    //Set steps 0 after save in DB.
    steps= 0;
    intMillisecondCount= 0;
    
}
-(void)clearAllData{
    NSLog(@"clearAllData");
    steps=0.0;
    
    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"AccelData" inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    //error handling goes here
    for (NSManagedObject * accel in fetchedObjects) {
        [context deleteObject:accel];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}
-(void)fetchResultForRefreshingTable{
    
    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AccelData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *dicAccelData  = [[NSMutableDictionary alloc] init];
    
    if([fetchedObjects count]>0){
        
        //Fetching top element:
        AccelData *accelInfo=fetchedObjects[fetchedObjects.count-1];
       
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.x doubleValue]] stringValue]] forKey:@"xPosition"];
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.y doubleValue]] stringValue]] forKey:@"yPosition"];
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.z doubleValue]] stringValue]] forKey:@"zPosition"];
        
        [dicAccelData setValue:accelInfo.saveDate forKey:@"date"];
        [dicAccelData setValue:accelInfo.steps forKey:@"steps"];
        [dicAccelData setValue:accelInfo.fltLastAccel forKey:@"fltLastAccel"];
        
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.latitude floatValue]] stringValue]] forKey:@"latitude"];
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.longitude floatValue]] stringValue]] forKey:@"longitude"];
        
        steps=[accelInfo.steps floatValue];
        NSLog(@"steps :%f",steps);
    }
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVAccelerrometerCallback object:dicAccelData]];
}

@end
