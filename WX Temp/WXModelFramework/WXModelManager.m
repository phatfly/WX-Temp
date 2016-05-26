//
//  WXModelManager.m
//  WX Temp
//

#import "WXModelManager.h"
#import "WXConstants.h"
#import "WXCommunicationManager.h"
#import <CoreLocation/CoreLocation.h>


static WXModelManager *sharedManager = nil;

NSString *const kWXSDKNetworkReachabilityChanged = @"com.relativelogicinc.SDK.kWXSDKNetworkReachabilityChanged";

@interface WXModelManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WXModelManager

@synthesize locationManager;

+ (id)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[WXModelManager alloc] init];
        
    });
    
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedManager == nil)  {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;
        }
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        DebugLogWX(@"SDK started");
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(networkAvailabilityChanged:) name:kWXSDKNetworkReachabilityChanged object:nil];
        
        [WXCommunicationManager sharedManager];
        
        [self setupLocationManager];
        
    }
    return self;
}

-(void)networkAvailabilityChanged:(NSNotification*)notif
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWXSDKNetworkReachabilityChanged object:nil userInfo:@{@"networkAvailable":[NSNumber numberWithBool:[self networkAvailable]]}];
}

-(BOOL)networkAvailable
{
    return [[WXCommunicationManager sharedManager] configuredReachability];
}

-(void)setupLocationManager
{
    locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    locationManager.distanceFilter = 100.f; // meters
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    if ([CLLocationManager authorizationStatus] == 0 || ![CLLocationManager locationServicesEnabled])
    {
        DebugLogWX(@"location services requesting to be enabled");
        
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
            
        }
        
// Pre ios 8
//        else
//        {
//            if ([CLLocationManager locationServicesEnabled])
//            {
//                [locationManager startUpdatingLocation];
//            }
//            
//        }
        
    }
}

#pragma mark - Location Services

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    DebugLogWX(@"error getting location");
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DebugLogWX(@"location services didChangeAuthorizationStatus enum: %d", status);
    
    if ([CLLocationManager authorizationStatus] > 2)
    {
        if ([CLLocationManager locationServicesEnabled])
        {
            [locationManager startUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [locationManager stopUpdatingLocation];
    
    DebugLogWX(@"location services newLocation: latValue: %f, longValue: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

-(void)getConditionWithLocationServicesWithCompletion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] > 2)
    {
        
         NSString *queryString = [NSString stringWithFormat:@"%f,%f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
            
            [self readConditionForLocation:queryString completion:^(BOOL success, NSDictionary *conditionResponseDict, NSError *localError) {
                completionHandler(success, conditionResponseDict, localError);
            }];
    }
    else
    {
        NSError *error =[NSError errorWithDomain:@"com.relativelogicinc.SDK.applicationErrorDomain" code:14 userInfo:[NSDictionary dictionaryWithObject:@"Location Services not enabled" forKey:NSLocalizedDescriptionKey]];
        completionHandler(NO, @{@"error":[error localizedDescription]},error);
    }
    
}

-(void)getConditionWithQuery:(NSString*)queryString completion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler
{
    NSString *trimmedQueryString = [queryString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [self readConditionForLocation:trimmedQueryString completion:^(BOOL success, NSDictionary *conditionResponseDict, NSError *localError) {
        completionHandler(success, conditionResponseDict, localError);
    }];
}

#pragma mark - WS call

-(void)readConditionForLocation:(NSString*)locationQuery completion:(void (^)(BOOL success, NSDictionary *conditionResponseDict, NSError *localError))completionHandler
{
    [[WXCommunicationManager sharedManager] readConditionForLocation:locationQuery completion:^(BOOL success, NSDictionary *jsonResult, NSError *localError)
     {
         DebugLogWX(@"%@", jsonResult);
         if(jsonResult[@"response"][@"error"])
         {
             NSError *error =[NSError errorWithDomain:@"com.relativelogicinc.SDK.applicationErrorDomain" code:14 userInfo:[NSDictionary dictionaryWithObject:jsonResult[@"response"][@"error"][@"description"] forKey:NSLocalizedDescriptionKey]];
             
             completionHandler(NO, jsonResult, error);
         }
         else
             completionHandler(success, jsonResult, localError);
     }];
}


@end
