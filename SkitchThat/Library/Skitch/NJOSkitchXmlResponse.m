//
//  NJOSkitchXmlResponse.m
//  
//
//  Created by compo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchXmlResponse.h"

#import "XMLReader.h"

static NSString *kNJOSkitchResponseRootResponseNodeName = @"skitchResponse";

@implementation NJOSkitchXmlResponse

@synthesize version = _version;
@synthesize noun = _noun;

- (void)dealloc {
    [_version release], _version = nil;
    [_noun release], _noun = nil;
    
    [super dealloc];
}

- (id)initWithXmlString:(NSString *)xml {
    self = [super init];
    
    if (self) {
        NSError *error = nil;

        NSDictionary *response = [XMLReader dictionaryForXMLString:xml error:&error];

        if (nil == error && nil != [response objectForKey:kNJOSkitchResponseRootResponseNodeName]) {
            NSMutableDictionary *skitchResponse = [[response objectForKey:kNJOSkitchResponseRootResponseNodeName] mutableCopy];

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

@end
