//
//  NJOSkitchJsonResponse.m
//  SkitchThat
//
//  Created by compo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchJsonResponse.h"

#import "CJSONDeserializer.h"

@implementation NJOSkitchJsonResponse

- (id)initWithJsonString:(NSString *)json {
    self = [super init];
    
    if (self) {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;

        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];

        if (nil == error) {
            _result = [[dictionary objectForKey:@"result"] intValue];
            _message = [[dictionary objectForKey:@"message"] retain];

            _skitchResponse = [[dictionary objectForKey:@"info"] retain];
        }
    }
    
    return self;
}

@end
