//
//  WXModelManager.h
//  WX Temp
//
//  Created by Christopher Scott on 5/25/16.
//  Copyright © 2016 Relative Logic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - NSNotificationCenter calls names
/**
 *  kWXSDKNetworkReachabilityChanged notification is called when the SDK has a change in network availability.
 *  A notification will be posted when detecting that a network is connected or disconnected.
 *  The userInfo will contain the key:value -> networkAvailable:<NSNumber value for BOOL>
 */
extern NSString *const kWXSDKNetworkReachabilityChanged;

@interface WXModelManager : NSObject

/**
 *  Call [WXModelManager sharedManger] as soon as you would like to setup the SDK.
 *  This method will init the this singleton and the other SDK dependent object instances necessary for use.
 */
+ (id)sharedManager;

/**
 *  networkAvailable
 *
 *  This method makes a call to the WXCommunicationManager and it uses Apple's Reachablity class to determine if a network is available.
 *
 *  @return BOOL value for whether the SDK has determined there to be a network available.
 *  @warning This doesn't mean that the the network is connected to the internet.  There could be a connection, but the network is not connected to the interenet.
 */
-(BOOL)networkAvailable;

/**
 *  This method will attempt to use Corelocation to get a lat/ long position and then to query the wunderground API for the current conditions feature.
 *
 *  The completion block will "return" 
 *  success if there were no errors while handling the method.
 *  conditionResponseDict with the wunderground JSON response to their API call.
 *  localError will contain any errors if they are handled.  Else it is returned nil.
 */
-(void)getConditionWithLocationServicesWithCompletion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler;

/**
 *  This method will attempt to use a string as the query with the wunderground API for that locations conditions feature.
 *  This query string can be any of the options they allow for query in their API.
 *
 *  @see https://www.wunderground.com/weather/api/d/docs?d=data/index
 *
 *  The completion block will "return"
 *  success if there were no errors while handling the method.
 *  conditionResponseDict with the wunderground JSON response to their API call.
 *  localError will contain any errors if they are handled.  Else it is returned nil.
 */
-(void)getConditionWithQuery:(NSString*)queryString completion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler;

@end
