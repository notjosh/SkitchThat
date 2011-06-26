//
//  SkitchThatAppDelegate.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InitialisationViewController.h"


@interface SkitchThatAppDelegate : NSObject <UIApplicationDelegate, InitialisationViewControllerDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet InitialisationViewController *initialisationController;

@end
