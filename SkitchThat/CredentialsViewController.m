//
//  CredentialsViewController.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CredentialsViewController.h"

#import "NJOSkitchConfig.h"

enum {
    kCredentialsViewControllerTagUsername = 0,
    kCredentialsViewControllerTagPassword = 1
};

@interface CredentialsViewController ()
- (void)populateCredentialsFields;
@end

@implementation CredentialsViewController

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

- (void)dealloc {
    [_usernameField release], _usernameField = nil;
    [_passwordField release], _passwordField = nil;

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [self populateCredentialsFields];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)populateCredentialsFields {
    NJOSkitchConfig *c = [NJOSkitchConfig sharedNJOSkitchConfig];
    
    NSString *username = [c username];
    NSString *password = [c password];
    
    _usernameField.text = username;
    _passwordField.text = password;
}

- (IBAction)handleCancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleDoneTapped:(id)sender {
    NJOSkitchConfig *c = [NJOSkitchConfig sharedNJOSkitchConfig];
    [c setUsername:_usernameField.text password:_passwordField.text];

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleLogoutTapped:(id)sender {
    NJOSkitchConfig *c = [NJOSkitchConfig sharedNJOSkitchConfig];
    [c clearCredentials];

    [self populateCredentialsFields];
}

@end
