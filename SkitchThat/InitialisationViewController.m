//
//  InitialisationViewController.m
//  SkitchThat
//
//  Created by compo on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InitialisationViewController.h"

#import "NJOSkitchConfig.h"
#import "NJOSkitchService.h"
#import "NJOSkitchResponse.h"


@interface InitialisationViewController (Private)
- (void)checkAuthentication;
@end

@implementation InitialisationViewController

@synthesize delegate = _delegate;

- (void)dealloc {
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self checkAuthentication];
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

#pragma mark - NJOSkitchServiceDelegate
- (void)requestComplete:(NJOSkitchResponse *)response {
    if (![response hasError]) {
        [NJOSkitchConfig sharedNJOSkitchConfig].skitchSession = response.skitchResponse;
    }

    [_delegate initialisationDidFinish];
}

@end


@implementation InitialisationViewController (Private)

- (void)checkAuthentication {
    NJOSkitchService *s = [[NJOSkitchService alloc] init];
    s.delegate = self;
    [s authorise];
    [s release];
}

@end