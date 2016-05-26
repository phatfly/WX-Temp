//
//  WXModelManager.h
//  WX Temp
//
//  Created by Christopher Scott on 5/25/16.
//  Copyright © 2016 Relative Logic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  kWXSDKNetworkReachabilityChanged notification is called when the SDK has a change in network availability
 */
extern NSString *const kWXSDKNetworkReachabilityChanged;

@interface WXModelManager : NSObject

+ (id)sharedManager;

-(BOOL)networkAvailable;

//-(void)readConditionForLocation:(NSString*)locationQuery completion:(void (^)(BOOL success, NSDictionary *conditionResponseDict))completionHandler;

-(void)getConditionWithLocationServicesWithCompletion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler;

-(void)getConditionWithQuery:(NSString*)queryString completion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler;

@end
