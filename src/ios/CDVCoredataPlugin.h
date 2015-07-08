//
//  CDVCoredataPlugin.h
//  pluginAppdemo
//
//  Created by admin on 5/4/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface CDVCoredataPlugin : NSObject

//Coredata attributes:
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+(instancetype)sharedInstance;
@end
