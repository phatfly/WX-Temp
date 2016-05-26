//
//  WXMainViewController.m
//  WX Temp
//
//  Created by Christopher Scott on 5/25/16.
//  Copyright © 2016 Relative Logic, Inc. All rights reserved.
//

#import "WXMainViewController.h"
#import <WXModelFramework/WXModelManager.h>
#import "WXShowTempViewController.h"

@interface WXMainViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (strong, nonatomic) IBOutlet UITextField *zipcodeTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) __block NSDictionary *passingLocationDict;
@property (strong, nonatomic) __block IBOutlet UIView *activityIndicatorContainerView;
@property (strong, nonatomic) __block IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UILabel *activityIndicatorViewLabel;
@end

@implementation WXMainViewController

@synthesize scrollView, navTitle, zipcodeTextField, submitButton, passingLocationDict, activityIndicatorContainerView, activityIndicator, activityIndicatorViewLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    submitButton.enabled = NO;
    
    activityIndicatorContainerView.hidden = YES;
    [activityIndicator stopAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setKeyboardToolbar];
    
     [[NSNotificationCenter defaultCenter] addObserver: self
                                              selector: @selector(networkAvailabilityChanged:)
                                                  name:kWXSDKNetworkReachabilityChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    
    [self networkAvailabilityChanged:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)networkAvailabilityChanged:(NSNotification*)notif
{
    if([[WXModelManager sharedManager] networkAvailable])
    {
        NSLog(@"Network Available");
        [self hideActivityView];
    }
    else
    {
        NSLog(@"Network NOT Available");
        [self showActivityViewWithMessage:@"Offline! \n Waiting for a network connection."];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button methods

- (IBAction)usLocationButtonPressed:(id)sender {
    
     [self showActivityViewWithMessage:nil];
    
    [[WXModelManager sharedManager] getConditionWithLocationServicesWithCompletion:^(BOOL success, NSDictionary *conditionResponseDict, NSError *localError) {
       
        if (success) {
            passingLocationDict = conditionResponseDict;
            [self performSegueWithIdentifier:@"showTempSegue" sender:self];
        }
        else if(!success && [[localError localizedDescription] isEqualToString:@"no network connection"])
        {
            [self networkofflineAlert];
        }
        else if(!success && [[localError localizedDescription] isEqualToString:@"Location Services not enabled"])
        {
            [self locationServicesOfflineAlert];
        }
        
        [self hideActivityView];
        
    }];
}


- (IBAction)submitButtonPressed:(id)sender {
    
    [self showActivityViewWithMessage:nil];
    
    [[WXModelManager sharedManager] getConditionWithQuery:zipcodeTextField.text completion:^(BOOL success, NSDictionary *conditionResponseDict, NSError *localError) {
        if (success)
        {
            passingLocationDict = conditionResponseDict;
            [self performSegueWithIdentifier:@"showTempSegue" sender:self];
        }
        else if(!success && localError)
        {
            NSLog(@"localError: %@", [localError localizedDescription]);
        }
        
        [self hideActivityView];
    }];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showTempSegue"]) {
        
        // Get reference to the destination view controller
        WXShowTempViewController *vc = [segue destinationViewController];
        
        [vc setLocationDict: passingLocationDict];
        
    }
}

#pragma mark - Alert Methods

-(void)networkofflineAlert
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Network Offline Alert"
                                  message:@"You are currently offline."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)locationServicesOfflineAlert
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Location Services Offline Alert"
                                  message:@"Please check your Location Services authorization in settings to continue using this feature of the app."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - keyboard toolbar setup

-(void)setKeyboardToolbar
{
    
    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleDefault;
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(doneTyping)];
    
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    
    zipcodeTextField.inputAccessoryView = toolbar;
    
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.zipcodeTextField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.submitButton.frame animated:YES];
    }
    
    [self updateViewConstraints];
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


-(void)doneTyping{
    
    if ([zipcodeTextField canResignFirstResponder])
        [zipcodeTextField resignFirstResponder];
}

#pragma mark - textField Methods

-(void)textDidChange:(NSNotification *)notification
{
    
    if(zipcodeTextField.text.length > 0)
        submitButton.enabled = YES;
    else
        submitButton.enabled = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(zipcodeTextField.text.length > 0)
    {
        [self doneTyping];
        [self submitButtonPressed:nil];
    }
    return YES;
}

#pragma mark - Activity View Methods


-(void)showActivityViewWithMessage:(NSString*)msgString
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        if(msgString)
            activityIndicatorViewLabel.text = msgString;
        else
            activityIndicatorViewLabel.text = @"Please wait";
        
        activityIndicatorContainerView.hidden = NO;
        [activityIndicator startAnimating];
    });
    
}

-(void)hideActivityView
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        activityIndicatorContainerView.hidden = YES;
        [activityIndicator stopAnimating];
    });
    
}

@end
