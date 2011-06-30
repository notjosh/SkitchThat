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

typedef void (^NJOSkitchResponseBlock)(NJOSkitchResponse *response);

@interface NJOSkitchService : NSObject {
}

@property (assign, nonatomic) id<NJOSkitchServiceDelegate> delegate;

@property (copy, nonatomic) NJOSkitchResponseBlock completionBlock;
@property (copy, nonatomic) NJOSkitchResponseBlock failureBlock;
@property (copy, nonatomic) NJOSkitchResponseBlock progressBlock;

- (void)authorise;
- (void)login;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

- (void)addImageAsPng:(UIImage *)image name:(NSString *)name;
- (void)addImageAsJpeg:(UIImage *)image name:(NSString *)name;
- (void)addImage:(UIImage *)image type:(NSString *)type name:(NSString *)name;

- (void)fetchObject:(NSString *)guid;
- (void)fetchComments:(NSString *)guid fromId:(NSString *)fromId;

@end