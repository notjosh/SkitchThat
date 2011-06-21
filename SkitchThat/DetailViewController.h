//
//  DetailViewController.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController {
    NSString *_filePath;
    UIImageView *_imageView;
}

@property (retain, nonatomic) NSString *filePath;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@end
