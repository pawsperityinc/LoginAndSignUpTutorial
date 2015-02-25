//
//  DefaultSettingsViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "DefaultSettingsViewController.h"

@implementation DefaultSettingsViewController


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    
    if ([PFUser currentUser]) {
        self.navigationItem.title = [NSString stringWithFormat:@"Welcome %@!", [[PFUser currentUser] username]];
    } else {
        self.navigationItem.title = @"Not logged in";
    }
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController]; 
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton;
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
        
    } else
    {
        PFQuery *queryForTimesheet = [[PFQuery alloc] initWithClassName:@"Timesheet"];
        [queryForTimesheet whereKey:@"volunteerUser" equalTo:[PFUser currentUser]];
        [queryForTimesheet whereKeyDoesNotExist:@"clockedOut"];
        NSInteger number = [queryForTimesheet countObjects];
        if (number > 0)
        {
            [self.clockButton setTitle:@"Clock Out" forState:UIControlStateNormal];
            self->clockedIn = YES;
        } else {
            [self.clockButton setTitle:@"Clock In" forState:UIControlStateNormal];
            self->clockedIn = NO;
        }
    }
    
}


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self viewDidAppear:YES];
}

- (IBAction)clockInOrOut:(id)sender
{
    if (self->clockedIn) {
        
        [self clockOut];
 self->clockedIn = NO;
}   else {

        [self clockIn];
    self->clockedIn = YES;
}
}

- (void) clockIn
{
    PFObject *timesheet = [PFObject objectWithClassName:@"Timesheet"];
    [timesheet setObject:[[NSDate alloc] init] forKey:@"clockedIn"];
    [timesheet setObject:[PFUser currentUser] forKey:@"volunteerUser"];
    [timesheet saveEventually];
    NSLog(@"%@",timesheet);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clocked In" message:[NSString stringWithFormat:@"%@",[[NSDate alloc] init]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    
    
    [self.clockButton setTitle:@"Clock Out" forState:UIControlStateNormal];

}

- (void) clockOut
{
    PFQuery *queryForTimesheet = [[PFQuery alloc] initWithClassName:@"Timesheet"];
    [queryForTimesheet whereKey:@"volunteerUser" equalTo:[PFUser currentUser]];
    [queryForTimesheet whereKeyDoesNotExist:@"clockedOut"];
    PFObject *timesheet = [queryForTimesheet getFirstObject];
    [timesheet setObject:[[NSDate alloc] init] forKey:@"clockedOut"];
    [timesheet saveEventually];
    NSLog(@"%@",timesheet);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clocked Out" message:[NSString stringWithFormat:@"%@",[[NSDate alloc] init]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    
    
    [self.clockButton setTitle:@"Clock In" forState:UIControlStateNormal];
}

@end
