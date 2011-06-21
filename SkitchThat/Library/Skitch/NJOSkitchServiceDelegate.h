//
//  NJOSkitchServiceDelegate.h
//  SkitchThat
//
//  Created by Joshua May on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NJOSkitchServiceDelegate <NSObject>

@optional
- (void)transferProgress:(float)progress;
- (void)transferComplete;

@end
