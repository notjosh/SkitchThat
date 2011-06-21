//
//  NJOSkitchService.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchService.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "NJOSkitchConfig.h"
#import "NJOSkitchResponse.h"

NSString * const kNJOSkitchServiceTypeJpeg = @"image/jpeg";
NSString * const kNJOSkitchServiceTypePng  = @"image/png";

CGFloat const kNJOSkitchServiceJpegCompressionQuality = 80.0f;

@interface NJOSkitchService (SkitchRawAPI)
- (void)addObject:(NSData *)objectData type:(NSString *)type name:(NSString *)name objectSize:(NSUInteger)size;

- (NSURL *)urlForPath:(NSString *)path;
@end

@implementation NJOSkitchService

- (void)addImageAsPng:(UIImage *)image name:(NSString *)name {
    [self addImage:image type:kNJOSkitchServiceTypePng name:name];
}

- (void)addImageAsJpeg:(UIImage *)image name:(NSString *)name {
    [self addImage:image type:kNJOSkitchServiceTypeJpeg name:name];
}

- (void)addImage:(UIImage *)image type:(NSString *)type name:(NSString *)name {
    // objectType = [mimeType]
    // objectName = `name`
    // objectSize = 
    // objectData = `image [type]representation`

    NSData *objectData;

    if ([kNJOSkitchServiceTypeJpeg isEqualToString:type]) {
        objectData = UIImageJPEGRepresentation(image, kNJOSkitchServiceJpegCompressionQuality);
    } else if ([kNJOSkitchServiceTypePng isEqualToString:type]) {
        objectData = UIImagePNGRepresentation(image);
    }

    NSString *errorMessage = [NSString stringWithFormat:@"objectData can not be represented as type: %@", type];
    NSAssert(nil != objectData, errorMessage);

    [self addObject:objectData
               type:type
               name:name
         objectSize:[objectData length]];
}

@end

@implementation NJOSkitchService (SkitchRawAPI)

- (void)addObject:(NSData *)objectData type:(NSString *)type name:(NSString *)name objectSize:(NSUInteger)size {
    NSURL *url = [self urlForPath:@"/services/addObject/"];
    
    NSString *username = [[NJOSkitchConfig sharedNJOSkitchConfig] username];
    NSString *password = [[NJOSkitchConfig sharedNJOSkitchConfig] password];

    NSLog(@"credentials: %@, %@", username, password);

    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:type forKey:@"objectType"];
    [request setPostValue:name forKey:@"objectName"];
    [request setPostValue:[NSNumber numberWithUnsignedInteger:size] forKey:@"objectSize"];
    [request setData:objectData withFileName:name andContentType:type forKey:@"objectData"];

    [request setCompletionBlock:^(void) {
        NSLog(@"complete!");

        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);

        NJOSkitchResponse *response = [[NJOSkitchResponse alloc] initWithXmlString:responseString];
        NSLog(@"%@", response);
    }];

    [request setFailedBlock:^(void) {
        NSLog(@"error!");

        NSError *error = [request error];
        NSLog(@"%@", [error localizedDescription]);
    }];

    NSLog(@"starting request");
    [request startSynchronous];
}

- (NSURL *)urlForPath:(NSString *)path {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://skitch.com", path]];
}

@end