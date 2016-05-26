//
//  WXCommunicationManager.h
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface WXCommunicationManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) BOOL isOfflineMode;

+ (id)sharedManager;

-(BOOL)isReachability;

+(BOOL)configuredReachability;

-(BOOL)isOnlineMode;
-(BOOL)isWIFIOnlineMode;
-(BOOL)isWWANOnlineMode;

-(void)readConditionForLocation:(NSString*)locationQuery completion:(void (^)(BOOL success, NSDictionary *jsonResult, NSError *localError))completionHandler;

@end
