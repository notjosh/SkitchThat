//
//  DetailViewController.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "NJOSkitchServiceDelegate.h"


@interface DetailViewController : UIViewController <NJOSkitchServiceDelegate> {
    NSString *_filePath;
    UIImageView *_imageView;
    
    MBProgressHUD *_hud;
}

@property (retain, nonatomic) NSString *filePath;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)handleUploadAsPngTapped:(id)sender;
- (IBAction)handleUploadAsJpegTapped:(id)sender;

@end
