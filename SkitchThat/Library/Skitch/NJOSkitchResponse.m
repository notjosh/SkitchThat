//
//  NJOSkitchResponse.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchResponse.h"

#import "XMLReader.h"

static NSString *kNJOSkitchResponseRootResponseKey = @"skitchResponse";

@implementation NJOSkitchResponse

@synthesize skitchResponse = _skitchResponse;
@synthesize result = _result;
@synthesize message = _message;
@synthesize version = _version;
@synthesize noun = _noun;

- (void)dealloc {
    [_skitchResponse release], _skitchResponse = nil;
    [_message release], _message = nil;
    [_version release], _version = nil;
    [_noun release], _noun = nil;

    [super dealloc];
}

- (id)initWithXmlString:(NSString *)xml {
    self = [super init];

    if (self) {
        NSError *error = nil;

        NSDictionary *response = [XMLReader dictionaryForXMLString:xml error:&error];

        if (nil == error && nil != [response objectForKey:kNJOSkitchResponseRootResponseKey]) {
            NSMutableDictionary *skitchResponse = [[response objectForKey:kNJOSkitchResponseRootResponseKey] mutableCopy];

            _result = [[skitchResponse objectForKey:@"result"] intValue];
            _message = [[skitchResponse objectForKey:@"message"] retain];

            _version = [[NSDecimalNumber decimalNumberWithString:[skitchResponse objectForKey:@"@version"]] retain];
            _noun = [[skitchResponse objectForKey:@"@noun"] retain];
            
            [skitchResponse removeObjectForKey:@"result"];
            [skitchResponse removeObjectForKey:@"message"];
            [skitchResponse removeObjectForKey:@"@version"];
            [skitchResponse removeObjectForKey:@"@noun"];

            _skitchResponse = [[skitchResponse copy] retain];
        }
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Result: '%d', Message: '%@', Version: '%@', Noun: '%@', Response: %@", _result, _message, _version, _noun, _skitchResponse];
}

#pragma mark - API response helpers
- (BOOL)hasError {
    return 0 != _result;
}

@end
