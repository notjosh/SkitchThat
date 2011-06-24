//
//  NJOSkitchService.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NJOSkitchServiceDelegate.h"


extern NSString * const kNJOSkitchServiceTypeJpeg;
extern NSString * const kNJOSkitchServiceTypePng;

extern CGFloat const kNJOSkitchServiceJpegCompressionQuality;


@interface NJOSkitchService : NSObject {
//    id<NJOSkitchServiceDelegate> _delegate;
}

@property (assign, nonatomic) id<NJOSkitchServiceDelegate> delegate;

- (void)authorise;
- (void)login;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

- (void)addImageAsPng:(UIImage *)image name:(NSString *)name;
- (void)addImageAsJpeg:(UIImage *)image name:(NSString *)name;
- (void)addImage:(UIImage *)image type:(NSString *)type name:(NSString *)name;

- (void)fetchObject:(NSString *)guid;

@end