/********* bgaccelerometer.h Cordova Plugin interface *******/

#import <Cordova/CDV.h>
#import "LocationTracker.h"

//#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#   define DLog(fmt, ...) NSLog((@"" ), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#   define DLog(...)

extern NSString* const CDVAccelerrometerCallback;
extern NSInteger  CDVAccelerrometerUpdateDuration;
@interface bgaccelerometer : CDVPlugin {
  // Member variables go here.
}
@property(nonatomic,retain) CDVInvokedUrlCommand *callbackCommand;
@property(nonatomic,strong) LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;

- (void)setConfig:(CDVInvokedUrlCommand*)command;
- (void)startRecording:(CDVInvokedUrlCommand*)command;
- (void)stopRecording:(CDVInvokedUrlCommand*)command;
- (void)getData:(CDVInvokedUrlCommand*)command;
- (void)clearData:(CDVInvokedUrlCommand*)command;
- (void)getConfig:(CDVInvokedUrlCommand*)command;


-(void)setDefaultConfigData;
@end