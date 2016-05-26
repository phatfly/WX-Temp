//
//  WXConstants.h
//



#pragma mark - Web Services Constants

// Credential Values for WS
// Example call: http://api.wunderground.com/api/171aae5ec0eb84fd/conditions/lang:en/q/44.87,-93.534722.json

#define kWsUrl @"http://api.wunderground.com/api/%@/%@/%@/q/%@.json"
#define kWsKey @"171aae5ec0eb84fd"
#define kWsLanguage @"lang:en"

#define kWsFeatureConditions @"conditions"
#define kWsFeatureForecast @"forecast"
#define kWsFeatureAlerts @"alerts"

// Sets the constant interval for checking when there is no network connection detected.
#define time_interval_in_offline_mode @"300" // Seconds

////////////////////

#pragma mark - NSNotificationCenter

#define kWXSDKReachabilityChanged @"com.relativelogicinc.SDK.SDKReachabilityChanged"


//Colors

#define kmain_color @"7C7E7E"


// Logging

#ifdef DEBUG
 #define DebugLogWX( s, ... ) NSLog( @"SDK <%@:%d (%@)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  NSStringFromSelector(_cmd), [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLogWX( s, ... )
#endif


// Define Color macros

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBhalf(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.50]

#define UIColorFromRGBwithAlpha(rgbValue, alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha]
