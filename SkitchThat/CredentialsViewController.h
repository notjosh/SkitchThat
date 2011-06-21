//
//  CredentialsViewController.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CredentialsViewController : UIViewController {
}

@property (retain, nonatomic) IBOutlet UITextField *usernameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)handleCancelTapped:(id)sender;
- (IBAction)handleDoneTapped:(id)sender;

@end
