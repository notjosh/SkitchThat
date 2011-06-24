//
//  SkitchThatAppDelegate.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSkitchThatAppDelegateStateInitialisation,
    kSkitchThatAppDelegateStateNotAuthenticated,
    kSkitchThatAppDelegateStateAuthenticated
} kSkitchThatAppDelegateState;

@interface SkitchThatAppDelegate : NSObject <UIApplicationDelegate> {
    int _state;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIViewController *initialisationController;
@property (nonatomic, retain) IBOutlet UIViewController *notAuthenticatedController;

- (void)setState:(kSkitchThatAppDelegateState)state;

@end
