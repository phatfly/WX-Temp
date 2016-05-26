//
//  WXCommunicationManager.h
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface WXCommunicationManager : NSObject 

+ (id)sharedManager;

-(BOOL)isReachability;

/**
 *  This method will return a BOOL based on if the SDK should allow access to the WWAN and/ or WIFI.  Currently the SDK is setup for both WWAN and WIFI.
 *
 *
 *  @return BOOL whill return YES if either the WWAN or WIFI are available.  It will return NO if neither are available.
 */
-(BOOL)configuredReachability;

-(BOOL)isOnlineMode;
-(BOOL)isWIFIOnlineMode;
-(BOOL)isWWANOnlineMode;

/**
 *  This method will attempt to use a string as the locationQuery with the wunderground API for that locations conditions feature.
 *
 *  The completion block will "return"
 *  success if there were no errors while handling the method.
 *  jsonResult with the wunderground JSON response to their API call.
 *  localError will contain any errors if they are handled.  Else it is returned nil.
 */
-(void)readConditionForLocation:(NSString*)locationQuery completion:(void (^)(BOOL success, NSDictionary *jsonResult, NSError *localError))completionHandler;

@end
