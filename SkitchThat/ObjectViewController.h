//
//  ObjectViewController.h
//  SkitchThat
//
//  Created by Joshua May on 22/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NJOSkitchServiceDelegate.h"

@interface ObjectViewController : UIViewController <NJOSkitchServiceDelegate> {
    
}

@property (retain, nonatomic) NSString *guid;

@end
