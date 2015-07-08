//
//  MotionTracker.h
//  Location
//
//  Created by Dotsquares on 4/20/15.
//  Copyright (c) 2015 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
//#import "LocationShareModel.h"

double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;
double currentMaxRotX;
double currentMaxRotY;
double currentMaxRotZ;

@interface MotionTracker : NSObject

+ (MotionTracker *)sharedMotionManager;

-(void)startMotionTracking:(NSMutableDictionary*)locationData;
-(void)stopAcceleroMeter;
-(void)saveDataInLocalDB;

@end
