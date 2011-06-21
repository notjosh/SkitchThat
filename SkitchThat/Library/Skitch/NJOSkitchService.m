//
//  NJOSkitchService.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchService.h"

#import "NSString+MD5.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "NJOSkitchConfig.h"
#import "NJOSkitchResponse.h"

NSString * const kNJOSkitchServiceTypeJpeg = @"image/jpeg";
NSString * const kNJOSkitchServiceTypePng  = @"image/png";

CGFloat const kNJOSkitchServiceJpegCompressionQuality = 80.0f;

@interface NJOSkitchService (SkitchRawAPI)
- (void)addObject:(NSString *)objectData type:(NSString *)type name:(NSString *)name objectSize:(NSUInteger)size;

- (NSURL *)urlForPath:(NSString *)path;
- (NSURL *)urlForPath:(NSString *)path parameters:(NSDictionary *)parameters;
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

    NSString *objectString = [ASIHTTPRequest base64forData:objectData];

    [self addObject:objectString
               type:type
               name:name
         objectSize:[objectString length]];
}

@end

@implementation NJOSkitchService (SkitchRawAPI)

- (void)addObject:(NSString *)data type:(NSString *)type name:(NSString *)name objectSize:(NSUInteger)size {
    NSString *username = [[NJOSkitchConfig sharedNJOSkitchConfig] username];
    NSString *password = [[NJOSkitchConfig sharedNJOSkitchConfig] password];

    NSURL *url = [self urlForPath:@"/services/addObject/"
                       parameters:[NSDictionary dictionaryWithObjectsAndKeys:username,       @"username",
                                                                             [password MD5], @"password",
                                   nil]];
    
    NSLog(@"%@", url);
    NSLog(@"%@", type);
    NSLog(@"%@", name);
    NSLog(@"%@", [NSNumber numberWithUnsignedInteger:size]);
//    NSLog(@"%@", data);
    

    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIURLEncodedPostFormat];
    [request setValidatesSecureCertificate:NO];
    [request setPostValue:type forKey:@"objectType"];
    [request setPostValue:name forKey:@"objectName"];
    [request setPostValue:[NSNumber numberWithUnsignedInteger:size] forKey:@"objectSize"];
    [request setPostValue:data forKey:@"objectData"];

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

- (NSURL *)urlForPath:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableString *queryString = [NSMutableString string];

    for (NSString *key in parameters) {
        if ([queryString length] > 0) {
            [queryString appendFormat:@"&"];
        }

        NSString *parameter = [parameters objectForKey:key];

        [queryString appendFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    NSMutableString *mPath = [path mutableCopy];

    if ([queryString length] > 0) {
        [mPath appendFormat:@"?%@", queryString];
    }

    return [self urlForPath:mPath];
}

@end