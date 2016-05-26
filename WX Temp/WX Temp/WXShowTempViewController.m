//
//  WXShowTempViewController.m
//  WX Temp
//
//  Created by Christopher Scott on 5/25/16.
//  Copyright © 2016 Relative Logic, Inc. All rights reserved.
//

#import "WXShowTempViewController.h"

typedef NS_ENUM(NSInteger, tempScaleChoice) {
    celsius = 0,
    fahrenheit,
    kelvin,
};

@interface WXShowTempViewController ()

@property(nonatomic, strong) NSDictionary *currentLocationDict;
@property (strong, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationTempLabel;
@property (strong, nonatomic) IBOutlet UIButton *celsiusButton;
@property (strong, nonatomic) IBOutlet UIButton *fahrenheitButton;

@property tempScaleChoice chosenTempType;

@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@end

@implementation WXShowTempViewController

@synthesize currentLocationDict, locationNameLabel, locationTempLabel, celsiusButton, fahrenheitButton, chosenTempType, refreshControl;

-(void)setLocationDict:(NSDictionary*)locationDict
{
    currentLocationDict = locationDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    locationNameLabel.text = currentLocationDict[@"current_observation"][@"display_location"][@"full"];
    
    chosenTempType = fahrenheit;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setViewTemp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)celsiusButtonPressed:(id)sender {
    
    chosenTempType = celsius;
    
    [self setViewTemp];
}

- (IBAction)fahrenheitButtonPressed:(id)sender {
    
    chosenTempType = fahrenheit;
    
    [self setViewTemp];
}

-(void)setViewTemp
{
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        switch (chosenTempType)
        {
            case fahrenheit:
            {
                float f_temp = [currentLocationDict[@"current_observation"][@"temp_f"] floatValue];
                locationTempLabel.text = [NSString stringWithFormat:@"%.02fº F",f_temp];
                fahrenheitButton.enabled = NO;
                celsiusButton.enabled = YES;
                break;
            }
            case kelvin:
                
                break;
                
//            case celsius:
//                
//                break;
                
            default:
            {
                float c_temp = [currentLocationDict[@"current_observation"][@"temp_c"] floatValue];
                locationTempLabel.text = [NSString stringWithFormat:@"%.02fº C",c_temp];
                fahrenheitButton.enabled = YES;
                celsiusButton.enabled = NO;
                break;
            }
        }
        
        
    });
}

@end
