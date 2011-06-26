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
            _result = [[dictionary objectForKey:@"result"] intValue] - 1;       // JSON true/false becomes 1/0 as intValue
            _message = [[dictionary objectForKey:@"message"] retain];

            _skitchResponse = [dictionary objectForKey:@"info"];

            if (nil == _skitchResponse) {
                NSMutableDictionary *tmp = [dictionary mutableCopy];
                [tmp removeObjectForKey:@"result"];
                [tmp removeObjectForKey:@"message"];

                _skitchResponse = [tmp copy];

                [tmp release];
            } else {
                [_skitchResponse retain];
            }
        }
    }
    
    return self;
}

@end
