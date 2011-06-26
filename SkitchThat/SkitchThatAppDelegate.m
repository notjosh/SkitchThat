//
//  SkitchThatAppDelegate.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SkitchThatAppDelegate.h"

#import "InitialisationViewController.h"

@interface SkitchThatAppDelegate (Private)
- (UIViewController *)viewControllerForState:(kSkitchThatAppDelegateState)state;
@end

@implementation SkitchThatAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize initialisationController = _initalisationController;
@synthesize notAuthenticatedController = _notAuthenticatedController;

- (void)dealloc {
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setState:kSkitchThatAppDelegateStateInitialisation];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setState:(kSkitchThatAppDelegateState)state {
    _state = state;
    
    UIViewController *vc = [self viewControllerForState:_state];
    
    self.window.rootViewController = vc;
}

@end

@implementation SkitchThatAppDelegate (Private)

- (UIViewController *)viewControllerForState:(kSkitchThatAppDelegateState)state {
    switch (state) {
        case kSkitchThatAppDelegateStateInitialisation:
            NSLog(@"Switching to state: kSkitchThatAppDelegateStateInitialisation");
            if (nil == _initalisationController) {
                self.initialisationController = [[InitialisationViewController alloc] initWithNibName:@"InitialisationViewController" bundle:nil];
            }

            return _initalisationController;

        case kSkitchThatAppDelegateStateAuthenticated:
            NSLog(@"Switching to state: kSkitchThatAppDelegateStateAuthenticated");
            return self.navigationController;

        case kSkitchThatAppDelegateStateNotAuthenticated:
            NSLog(@"Switching to state: kSkitchThatAppDelegateStateNotAuthenticated");
            return self.navigationController;
    }

    return nil;
}

@end
