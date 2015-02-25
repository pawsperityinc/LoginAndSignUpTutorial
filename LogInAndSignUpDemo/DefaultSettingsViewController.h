//
//  DefaultSettingsViewController.h
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

@interface DefaultSettingsViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL clockedIn;
}

@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, strong) IBOutlet UIButton *clockButton;

- (IBAction)logOutButtonTapAction:(id)sender;

- (IBAction)clockInOrOut:(id)sender;
- (void)clockIn;

- (void)clockOut;

@end
