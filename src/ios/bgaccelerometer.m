/********* bgaccelerometer.m Cordova Plugin Implementation *******/
#import "bgaccelerometer.h"
#import <Cordova/CDV.h>
#import "MotionTracker.h"
#import "LocationTracker.h"

#import "ConfigData.h"
#import "AppDelegate.h"
#import "AccelData.h"
#import "CDVCoredataPlugin.h"

NSString* const CDVAccelerrometerCallback = @"CDVAccelerrometerCallback";
NSInteger  CDVAccelerrometerUpdateDuration = 1.0; //in sec;
NSMutableDictionary *lastLocation;
BOOL isStopUpdateLocation;

@implementation bgaccelerometer
{
    NSMutableArray *listArray;
    NSTimer *startMonitoring;
}

@synthesize callbackCommand,locationTracker,locationUpdateTimer;
- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView {
    self = (bgaccelerometer *)[super initWithWebView:theWebView];
    
    [self setDefaultConfigData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SendDataToJs:)
                                                 name:CDVAccelerrometerCallback object:nil];
    return self;
}
-(void)SendDataToJs:(NSNotification*) notification{
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary * dic =[[notification object] mutableCopy];
    if (dic != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    if (self.callbackCommand.callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommand.callbackId];
    }
}
#pragma Plugin function
- (void)setConfig:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    
    NSInteger pollPeriod=0;
    NSInteger daysToKeep=0;
    
    if([command.arguments count] == 2){
        pollPeriod= [[command.arguments objectAtIndex:0] integerValue];
        daysToKeep= [[command.arguments objectAtIndex:1] integerValue];
    }
    else{
        if([listArray count]>0){
            NSDictionary *dicValue=[listArray objectAtIndex:0];
            pollPeriod= [[dicValue valueForKey:@"pollPeriod"] integerValue];
            daysToKeep= [[dicValue valueForKey:@"daysToKeep"] integerValue];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@" Default configuration set successfully. Please start." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
    }
        

//            //Show alert for not getting argument for method.
//            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Values are't set properly"];

        CDVAccelerrometerUpdateDuration =pollPeriod;
        
        //Check config values are stored or not.
        //If values are not in db then insert them.
        //If values are there please update db with new values.
        NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
        
        //Fetch recored from config table:
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"ConfigData" inManagedObjectContext:context]];
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        //Update cofig data.
        if ([results count]>0) {
            
            DLog(@"Update cofig data");
            //http://stackoverflow.com/questions/28620794/swift-nspredicate-throwing-exc-bad-accesscode-1-address-0x1-when-compounding
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pollPeriod == %ld", pollPeriod];
            [request setPredicate:predicate];
            
            ConfigData *configData= [results objectAtIndex:0];
            configData.pollPeriod = [NSNumber numberWithInteger:pollPeriod];
            configData.daysToKeep = [NSNumber numberWithInteger:daysToKeep];
        }
        //Insert config data.
        else{
            DLog(@"Insert config values");
            ConfigData *configData = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"ConfigData"
                                      inManagedObjectContext:context];
            
            configData.pollPeriod = [NSNumber numberWithInteger:pollPeriod];
            configData.daysToKeep = [NSNumber numberWithInteger:daysToKeep];
        }
        //Save values.
        if (![context save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Configuration set successfully. Please start."];
        }
    
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   
}
-(void)setDefaultConfigData{
//    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ConfigData"
//                                              inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//
    listArray = [[NSMutableArray alloc] init];
//
//    if([fetchedObjects count]>0){
//        for (ConfigData *accelInfo in fetchedObjects) {
//            NSMutableDictionary *lastLocation1  = [[NSMutableDictionary alloc] init];
//            
//            [lastLocation1 setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.pollPeriod doubleValue]] stringValue]] forKey:@"pollPeriod"];
//            [lastLocation1 setValue:[NSString stringWithFormat:@" %@",[accelInfo.daysToKeep  stringValue]] forKey:@"daysToKeep"];
//            [listArray  addObject:lastLocation1];
//        }
//    }
//    else{
        NSMutableDictionary *lastLocation1  = [[NSMutableDictionary alloc] init];
        [lastLocation1 setValue:@"2.0" forKey:@"pollPeriod"];
        [lastLocation1 setValue:@"5.0" forKey:@"daysToKeep"];
        [listArray  addObject:lastLocation1];
//    }
    [self setConfig:nil];
}

- (void)getConfig:(CDVInvokedUrlCommand*)command
{
    NSLog(@"getConfig :%@",command.arguments);

    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ConfigData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * listarray  = [[NSMutableArray alloc] init];
    for (ConfigData *accelInfo in fetchedObjects) {
        NSMutableDictionary *lastLocation1  = [[NSMutableDictionary alloc] init];
        
        [lastLocation1 setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.pollPeriod doubleValue]] stringValue]] forKey:@"pollPeriod"];
        [lastLocation1 setValue:[NSString stringWithFormat:@" %@",[accelInfo.daysToKeep  stringValue]] forKey:@"daysToKeep"];
        [listarray addObject:lastLocation1];
    }
    CDVPluginResult* pluginResult = nil;
    if (listarray != nil && listarray.count>0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:listarray];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No configuration available"];
    }
    
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)startRecording:(CDVInvokedUrlCommand*)command
{
    // 1. check config.
    // 2. if config not saved then save default config.
    // 3. if config is saved then get config and set for process.
    // 4. start process.
    
    DLog(@"%@",command.arguments);
    isStopUpdateLocation= NO;
    
//    if(!startMonitoring){
//        startMonitoring= [NSTimer scheduledTimerWithTimeInterval:60.0
//                                                         target:self
//                                                       selector:@selector(saveDataInLocalDB)
//                                                       userInfo:nil
//                                                        repeats:YES];
//    }
    
//    NSTimeInterval startMonitoring = 60.0;
    
    
    [self collectLocationData];
}

- (void)stopRecording:(CDVInvokedUrlCommand*)command
{
    DLog(@"%@",command.arguments);
    
    [startMonitoring invalidate];
    startMonitoring=nil;
    
    isStopUpdateLocation= YES;
    
    [[MotionTracker sharedMotionManager]stopAcceleroMeter];
    [[LocationTracker sharedLocationTracker] stopLocationTracking];
    [self.locationUpdateTimer invalidate];
}

- (void)getData:(CDVInvokedUrlCommand*)command
{
    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AccelData"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * listarray  = [[NSMutableArray alloc] init];
    for (AccelData *accelInfo in fetchedObjects) {
        NSMutableDictionary *dicAccelData  = [[NSMutableDictionary alloc] init];
        
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.x doubleValue]] stringValue]] forKey:@"xPosition"];
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.y doubleValue]] stringValue]] forKey:@"yPosition"];
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.z doubleValue]] stringValue]] forKey:@"zPosition"];
        [dicAccelData setValue:accelInfo.saveDate forKey:@"date"];
        [dicAccelData setValue:accelInfo.steps forKey:@"steps"];
        [dicAccelData setValue:accelInfo.fltLastAccel forKey:@"fltLastAccel"];

        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.latitude floatValue]] stringValue]] forKey:@"latitude"];
        [dicAccelData setValue:[NSString stringWithFormat:@" %@",[[NSNumber numberWithFloat:[accelInfo.longitude floatValue]] stringValue]] forKey:@"longitude"];
        
        [listarray addObject:dicAccelData];
    }
    CDVPluginResult* pluginResult = nil;
    if (listarray != nil && listarray.count>0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:listarray];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No data available"];
    }
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)clearData:(CDVInvokedUrlCommand*)command
{
    DLog(@"%@",command.arguments);
    //[AppDelegate shareAppDelegateInstance].steps=0.0;
    
    NSManagedObjectContext *context = [[CDVCoredataPlugin sharedInstance] managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"AccelData" inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    DLog(@"clearAllLocalData :%lu",(long)[fetchedObjects count]);
    
    //error handling goes here
    for (NSManagedObject * accel in fetchedObjects) {
        [context deleteObject:accel];
    }
    CDVPluginResult* pluginResult = nil;
    NSError *saveError = nil;
    if (![context save:&saveError]) { 
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No data available"];
    }
    else{
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Cleared successfully"];
    }    
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

#pragma class methods
-(void)collectLocationData{
    UIAlertView * alert;
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        
        [[LocationTracker sharedLocationTracker]startLocationTracking];
        
//        self.locationTracker = [[LocationTracker alloc]init];
//        [self.locationTracker startLocationTracking];

        //[self.locationUpdateTimer invalidate];
        
        NSTimeInterval time = CDVAccelerrometerUpdateDuration;
        self.locationUpdateTimer =[NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
    }
}
-(void)updateLocation {
    DLog(@"updateLocation");
    if(isStopUpdateLocation){
        [[LocationTracker sharedLocationTracker] stopLocationTracking];
    }else{
        [[LocationTracker sharedLocationTracker] updateLocationToServer];
    }
    
}


@end
