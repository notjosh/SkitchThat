//
//  InitialisationViewController.h
//  SkitchThat
//
//  Created by compo on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NJOSkitchServiceDelegate.h"


@protocol InitialisationViewControllerDelegate <NSObject>
- (void)initialisationDidFinish;
@end


@interface InitialisationViewController : UIViewController <NJOSkitchServiceDelegate> {
}

@property (nonatomic, assign) id<InitialisationViewControllerDelegate> delegate;

@end