//
//  NJOSkitchServiceDelegate.h
//  SkitchThat
//
//  Created by Joshua May on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NJOSkitchResponse;


@protocol NJOSkitchServiceDelegate <NSObject>

@optional
- (void)requestProgress:(float)progress;
- (void)requestComplete:(NJOSkitchResponse *)response;

@end
