//
//  WXCommunicationManager.m
//

#import "WXCommunicationManager.h"

#import "WXConstants.h"
#import <UIKit/UIKit.h>

static WXCommunicationManager *sharedCommManager = nil;

@interface WXCommunicationManager() <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionConfiguration *backgroundConfigurationObject;

@property (nonatomic, getter = isWifiReachable) BOOL wifiReachable;
@property (nonatomic, getter = isWwanReachable) BOOL wwanReachable;

@property (nonatomic, strong) NSTimer *serverAvailabilityTimer;

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) BOOL isOfflineMode;

@end


@implementation WXCommunicationManager

@synthesize reachability, isOfflineMode, wwanReachable, wifiReachable, backgroundSession, backgroundConfigurationObject, serverAvailabilityTimer;


#pragma mark Singleton Methods

+ (id)sharedManager {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCommManager = [[WXCommunicationManager alloc] init];
        
        
    });
    
    return sharedCommManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedCommManager == nil)  {
            sharedCommManager = [super allocWithZone:zone];
            return sharedCommManager;
        }
    }
    return nil;
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        //initializations
  
        backgroundConfigurationObject = [NSURLSessionConfiguration defaultSessionConfiguration ];
        
        backgroundConfigurationObject.HTTPMaximumConnectionsPerHost = 5;
        backgroundConfigurationObject.timeoutIntervalForResource = 120;
        backgroundConfigurationObject.timeoutIntervalForRequest = 120;
        backgroundConfigurationObject.allowsCellularAccess = YES;
        
        backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // not sure if we are online, yet
        isOfflineMode = YES;
        wifiReachable = NO;
        wwanReachable = NO;
        
        [self firstReachabilityCheck];
        [self startNotifyingOfInternetChanges];
    }
    
    return self;
}



+ (NSString *)getWebServiceURLWithQueryType:(NSString*)query
{
    return [NSString stringWithFormat:kWsUrl, kWsKey, kWsFeatureConditions, kWsLanguage, query];
}


#pragma mark - NetworkStatus

- (void)startNotifyingOfInternetChanges
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kWXSDKReachabilityChangedNotification object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];

}

- (void)reachabilityChanged:(NSNotification *)notif
{
    DebugLogWX(@"reachabilityChanged --- reachabilityChanged ");
    
    Reachability* curReach = (Reachability *)[notif object];
    
    NetworkStatus internetStatus = [curReach currentReachabilityStatus];
    
    wwanReachable = NO;
    wifiReachable = NO;
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            wwanReachable = NO;
            wifiReachable = NO;
            [self serverNotAvailable];
        }
            break;
        case ReachableViaWiFi:
        {
            wifiReachable = YES;
            DebugLogWX(@"ReachableViaWiFi");
            //            break;
        }
        case ReachableViaWWAN:
            wwanReachable = YES;
            DebugLogWX(@"ReachableViaWWAN");
        default:
        {
            DebugLogWX(@"ReachableVia-default");
        }
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWXSDKReachabilityChanged object:nil];
}

- (BOOL)firstReachabilityCheck
{
    
    // This will only be called the first time the Comm Manager is init
    DebugLogWX(@"");
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    wwanReachable = NO;
    wifiReachable = NO;
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            wwanReachable = NO;
            wifiReachable = NO;

            [self serverNotAvailable];
            return NO;
        }
            break;
        case ReachableViaWiFi:
        {
            wifiReachable = YES;
            DebugLogWX(@"ReachableViaWiFi");
        }
            //            break;
        case ReachableViaWWAN:
        {
            wwanReachable = YES;
            DebugLogWX(@"ReachableViaWWAN");
        }
            //            break;
        default:
            [self serverAvailable];
            break;
    }
    
    return YES;
}

+ (BOOL)checkReachability
{
    DebugLogWX(@"");
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
            DebugLogWX(@"The internet is NotReachable");
            return NO;
            break;
            
        default:
            break;
    }
    return YES;
}

+ (BOOL)checkWIFIReachability
{
    DebugLogWX(@"");
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case ReachableViaWiFi:
            DebugLogWX(@"The internet is wifi.");
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

+ (BOOL)checkWWANReachability
{
    DebugLogWX(@"");
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case ReachableViaWWAN:
            DebugLogWX(@"The internet is not wifi.");
            return YES;
            break;
        default:
            break;
    }
    return NO;
}


-(BOOL)isReachability
{
    return [self configuredReachability];
}

-(BOOL)configuredReachability
{

    if ([[WXCommunicationManager sharedManager] isWwanReachable] || [[WXCommunicationManager sharedManager] isWifiReachable])
    {
        return YES;
    }

    return NO;
}


- (BOOL)isOnlineMode
{
    //    DebugLogWX(@"");
    return (!isOfflineMode && [self configuredReachability]);
    //    return isOfflineMode;
}

- (BOOL)isWWANOnlineMode
{
    DebugLogWX(@"");
    return (!isOfflineMode && [WXCommunicationManager checkWWANReachability]);
}

- (BOOL)isWIFIOnlineMode
{
    DebugLogWX(@"");
    return (!isOfflineMode && [WXCommunicationManager checkWIFIReachability]);
}

- (void)checkServerAvalability
{
//    DebugLogWX(@"");
    
    if([WXCommunicationManager checkReachability])
    {
        DebugLogWX(@"Network Available");
    }
    else
    {
        [self serverNotAvailable];
    }
    
}

- (void)serverNotAvailable
{
    DebugLogWX(@"serverNotAvailable");
    
    if (!isOfflineMode)
    {
        isOfflineMode = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kWXSDKReachabilityChanged object:nil];
        });
        
        
        if (!serverAvailabilityTimer)
            serverAvailabilityTimer = [NSTimer scheduledTimerWithTimeInterval:[time_interval_in_offline_mode intValue] target:self selector:@selector(checkServerAvalability) userInfo:nil repeats:YES];
        else {
            
            [serverAvailabilityTimer invalidate];
            serverAvailabilityTimer = nil;
            
            serverAvailabilityTimer = [NSTimer scheduledTimerWithTimeInterval:[time_interval_in_offline_mode intValue] target:self selector:@selector(checkServerAvalability) userInfo:nil repeats:YES];
        }
    }
}


- (void)serverAvailable
{
    DebugLogWX(@"serverAvailable");
    
    if (isOfflineMode)
        isOfflineMode = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kWXSDKReachabilityChanged object:nil];
    });
    
    if (serverAvailabilityTimer)
    {
        [serverAvailabilityTimer invalidate];
        serverAvailabilityTimer = nil;
    }
}

-(void)errorCheckingReachability:(NSError*)error
{
    if([[error localizedDescription] isEqualToString:@"The Internet connection appears to be offline."] || [[error localizedDescription] isEqualToString:@"The request timed out."])
    {
        DebugLogWX(@"%@", [error localizedDescription]);
        [self checkServerAvalability];
    }
    
}


-(void)readConditionForLocation:(NSString*)locationQuery completion:(void (^)(BOOL success, NSDictionary *jsonResult, NSError *localError))completionHandler
{
    DebugLogWX(@"locationQuery: %@", locationQuery);
    
    NSURL *url = [[NSURL alloc] initWithString:[WXCommunicationManager getWebServiceURLWithQueryType:locationQuery]];

    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];

    if([self configuredReachability])
    {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURLSessionDataTask *task = [backgroundSession dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response, NSError *error) {
        
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (error)
            {
                DebugLogWX(@"\n error ------ %@", [error localizedDescription]);
                completionHandler(NO, @{@"error":[error localizedDescription]},error);
                [self errorCheckingReachability:error];
            }
            else
            {
                NSError *localError = nil;
                NSMutableDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:&localError];
                
                if (localError != nil)
                {
                    completionHandler(NO, @{@"error":[localError localizedDescription]},localError);
                    DebugLogWX(@"localError: %@", localError);
                    return;
                }
                completionHandler(YES, parsedObject, nil);
            }
        }];
        [task resume];
    }
    else
    {
        NSError *error =[NSError errorWithDomain:@"com.relativelogicinc.SDK.applicationErrorDomain" code:14 userInfo:[NSDictionary dictionaryWithObject:@"no network connection" forKey:NSLocalizedDescriptionKey]];
        completionHandler(NO, @{@"error":[error localizedDescription]},error);
    }
    
}
@end
