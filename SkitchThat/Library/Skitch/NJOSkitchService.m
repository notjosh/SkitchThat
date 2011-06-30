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
#import "NJOSkitchJsonResponse.h"
#import "NJOSkitchXmlResponse.h"

NSString * const kNJOSkitchServiceTypeJpeg = @"image/jpeg";
NSString * const kNJOSkitchServiceTypePng  = @"image/png";

CGFloat const kNJOSkitchServiceJpegCompressionQuality = 80.0f;

@interface NJOSkitchService (SkitchRawAPI)
- (void)addObject:(NSString *)objectData type:(NSString *)type name:(NSString *)name objectSize:(NSUInteger)size;

- (NSString *)generateAuthTokenWithUsername:(NSString *)username password:(NSString *)password;

- (NSURL *)urlForPath:(NSString *)path;
- (NSURL *)urlForPath:(NSString *)path parameters:(NSDictionary *)parameters;
@end

@interface NJOSkitchService (Private)
- (void)notifyRequestComplete:(ASIHTTPRequest *)request skitchResponse:(NJOSkitchResponse *)skitchResponse;
- (void)notifyRequestFailed:(ASIHTTPRequest *)request;
@end

@implementation NJOSkitchService

@synthesize delegate = _delegate;

@synthesize completionBlock = _completionBlock;
@synthesize failureBlock    = _failureBlock;
@synthesize progressBlock   = _progressBlock;

- (void)dealloc {
    [_completionBlock release], _completionBlock = nil;
    [_failureBlock release],    _failureBlock = nil;
    [_progressBlock release],   _progressBlock = nil;

    [super dealloc];
}

- (void)authorise {
    NSString *username = [[NJOSkitchConfig sharedNJOSkitchConfig] username];
    NSString *password = [[NJOSkitchConfig sharedNJOSkitchConfig] password];

    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"/services/application/authorize"]];

    NSString *authToken = [self generateAuthTokenWithUsername:(NSString *)username password:(NSString *)password];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:authToken forKey:@"authtoken"];

    // optional, because we care
    [request setPostValue:@"Direct" forKey:@"initialchannelid"];
    [request setPostValue:@"1.0.6" forKey:@"skitchversion"];
    [request setPostValue:@"10.06.07" forKey:@"osversion"];
    [request setPostValue:@"D140ECC6-8955-0844-5BF8-53C262B5DB43" forKey:@"installationid"];
    [request setPostValue:@"Direct" forKey:@"channelid"];
    [request setPostValue:@"Mac" forKey:@"platform"];
    [request setPostValue:@"en-us" forKey:@"language"];
    
    [request setCompletionBlock:^(void) {
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        NJOSkitchJsonResponse *response = [[NJOSkitchJsonResponse alloc] initWithJsonString:responseString];

        if ([_delegate respondsToSelector:@selector(requestComplete:)]) {
            [_delegate requestComplete:response];
        }
        
        [response release];
    }];

    [request setFailedBlock:^(void) {
        NSLog(@"Error!");

        NSError *error = [request error];
        NSLog(@"%@", [error localizedDescription]);
    }];

    [request startAsynchronous];
}

- (void)login {
    NSString *username = [[NJOSkitchConfig sharedNJOSkitchConfig] username];
    NSString *password = [[NJOSkitchConfig sharedNJOSkitchConfig] password];

    [self loginWithUsername:username password:password];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"/api/1.0/auth/login/"]];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    
    [request setCompletionBlock:^(void) {
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        NJOSkitchJsonResponse *response = [[NJOSkitchJsonResponse alloc] initWithJsonString:responseString];
        
        if ([_delegate respondsToSelector:@selector(requestComplete:)]) {
            [_delegate requestComplete:response];
        }
        
        [response release];
    }];
    
    [request setFailedBlock:^(void) {
        NSLog(@"Error!");
        
        NSError *error = [request error];
        NSLog(@"%@", [error localizedDescription]);
    }];
    
    [request startAsynchronous];
}

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

    NSAssert(nil != objectData, @"objectData can not be represented as valid image MIME type");

    NSString *objectString = [ASIHTTPRequest base64forData:objectData];

    [self addObject:objectString
               type:type
               name:name
         objectSize:[objectString length]];
}

- (void)fetchObject:(NSString *)guid {
    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"/api/1.0/objects/info/%@", guid]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^(void) {
        // Use when fetching text data
        NSString *responseString = [request responseString];

        NJOSkitchJsonResponse *response = [[NJOSkitchJsonResponse alloc] initWithJsonString:responseString];

        if ([_delegate respondsToSelector:@selector(requestComplete:)]) {
            [_delegate requestComplete:response];
        }
        
        [response release];
    }];
    
    [request setFailedBlock:^(void) {
        NSLog(@"Error!");
        
        NSError *error = [request error];
        NSLog(@"%@", [error localizedDescription]);
    }];
    
    [request startAsynchronous];
}

- (void)fetchComments:(NSString *)guid fromId:(NSString *)fromId {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"/api/1.0/objects/comments/enum/%@", guid];

    if (nil != fromId) {
        [urlString appendFormat:@"/%@", fromId];
    }

    NSLog(@"comments URL: %@", urlString);
    NSURL *url = [self urlForPath:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^(void) {
        NSString *responseString = [request responseString];
        NJOSkitchJsonResponse *response = [[NJOSkitchJsonResponse alloc] initWithJsonString:responseString];

        [self notifyRequestComplete:request skitchResponse:response];

        [response release];
    }];
    
    [request setFailedBlock:^(void) {
        [self notifyRequestFailed:request];
    }];
    
    [request startAsynchronous];
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

    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIURLEncodedPostFormat];
    [request setValidatesSecureCertificate:NO];
    [request setPostValue:type forKey:@"objectType"];
    [request setPostValue:name forKey:@"objectName"];
    [request setPostValue:[NSNumber numberWithUnsignedInteger:size] forKey:@"objectSize"];
    [request setPostValue:data forKey:@"objectData"];

    [request setShowAccurateProgress:YES];

    [request setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
        if ([_delegate respondsToSelector:@selector(requestProgress:)]) {
            float bytesSent = [request totalBytesSent];
            [_delegate requestProgress:bytesSent / (float)total];
        }
    }];

    [request setCompletionBlock:^(void) {
        // Use when fetching text data
        NSString *responseString = [request responseString];

        NJOSkitchXmlResponse *response = [[NJOSkitchXmlResponse alloc] initWithXmlString:responseString];

        if ([_delegate respondsToSelector:@selector(requestComplete:)]) {
            [_delegate requestComplete:response];
        }

        [response release];
    }];

    [request setFailedBlock:^(void) {
        NSLog(@"error!");

        NSError *error = [request error];
        NSLog(@"%@", [error localizedDescription]);
    }];

    [request startAsynchronous];
}

- (NSString *)generateAuthTokenWithUsername:(NSString *)username password:(NSString *)password {
    NSString *tokenRaw = [NSString stringWithFormat:@"%@|%@",
                          [ASIHTTPRequest base64forData:[username dataUsingEncoding:NSUTF8StringEncoding]],
                          [ASIHTTPRequest base64forData:[password dataUsingEncoding:NSUTF8StringEncoding]]];

    return [ASIHTTPRequest base64forData:[tokenRaw dataUsingEncoding:NSUTF8StringEncoding]];
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

@implementation NJOSkitchService (Private)

- (void)notifyRequestComplete:(ASIHTTPRequest *)request skitchResponse:(NJOSkitchResponse *)skitchResponse {
    if ([_delegate respondsToSelector:@selector(requestComplete:)]) {
        [_delegate requestComplete:skitchResponse];
    }

    if (nil != _completionBlock) {
        _completionBlock(skitchResponse);
    }
}

- (void)notifyRequestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Error!");
    
    NSError *error = [request error];
    NSLog(@"%@", [error localizedDescription]);
}

@end