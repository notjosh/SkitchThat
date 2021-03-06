//
//  DetailViewController.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "ObjectViewController.h"

#import "NJOSkitchService.h"
#import "NJOSkitchServiceDelegate.h"
#import "NJOSkitchResponse.h"

#import "MBProgressHUD.h"


@interface DetailViewController (Private)
- (void)configureView;
- (void)setHudProgress:(float)progress;
@end

@implementation DetailViewController

@synthesize filePath = _filePath;
@synthesize imageView = _imageView;

- (void)dealloc {
    [_filePath release], _filePath = nil;
    [_imageView release], _imageView = nil;
    [_hud release], _hud = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureView {
    // Update the user interface for the detail item.
    
    if (_filePath) {
        UIImage *image = [UIImage imageWithContentsOfFile:_filePath];
        
        if (image) {
            _imageView.image = image;
        }
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureView];

    self.title = [_filePath lastPathComponent];

    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.mode = MBProgressHUDModeDeterminate;
    _hud.labelText = @"Uploading...";
    [self.view addSubview:_hud];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

#pragma mark - Button handlers
- (void)handleUploadAsPngTapped:(id)sender {
    NSLog(@"handleUploadAsPngTapped");

    [self setHudProgress:0.0f];
    [_hud show:YES];

    NJOSkitchService *s = [[NJOSkitchService alloc] init];
    s.delegate = self;
    [s addImageAsPng:_imageView.image name:[_filePath lastPathComponent]];
    [s release];
}

- (void)handleUploadAsJpegTapped:(id)sender {
    NSLog(@"handleUploadAsJpegTapped");

    [self setHudProgress:0.0f];
    [_hud show:YES];

    NJOSkitchService *s = [[NJOSkitchService alloc] init];
    s.delegate = self;
    [s addImageAsJpeg:_imageView.image name:[_filePath lastPathComponent]];
    [s release];
}

- (void)handleMockGuidTapped:(id)sender {
    NSLog(@"handleMockGuidTapped");
    
    ObjectViewController *objectViewController = [[ObjectViewController alloc] initWithNibName:@"ObjectViewController" bundle:nil];
    objectViewController.guid = @"122753-adfd77-4a82b4-3df7cd-b1cadb-75";
    [self.navigationController pushViewController:objectViewController animated:YES];
    [objectViewController release];
}

- (void)setHudProgress:(float)progress {
    [_hud setProgress:progress];
    [_hud setDetailsLabelText:[NSString stringWithFormat:@"%0.0f%%", progress * 100]];
}

- (void)requestProgress:(float)progress {
    [self setHudProgress:progress];
}

- (void)requestComplete:(NJOSkitchResponse *)response {
    NSLog(@"-> transferComplete");
    NSLog(@"%@", response);
    [_hud hide:YES];

    if ([response hasError]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:[response message]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];

        return;
    }

    NSString *guid = [[response skitchResponse] objectForKey:@"guid"];

    ObjectViewController *objectViewController = [[ObjectViewController alloc] initWithNibName:@"ObjectViewController" bundle:nil];
    objectViewController.guid = guid;
    [self.navigationController pushViewController:objectViewController animated:YES];
    [objectViewController release];
}

@end
