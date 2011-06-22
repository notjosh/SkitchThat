//
//  NJOSkitchResponse.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchResponse.h"

@implementation NJOSkitchResponse

@synthesize skitchResponse = _skitchResponse;
@synthesize result = _result;
@synthesize message = _message;

- (void)dealloc {
    [_skitchResponse release], _skitchResponse = nil;
    [_message release], _message = nil;

    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Result: '%d', Message: '%@', Response: %@", _result, _message, _skitchResponse];
}

#pragma mark - API response helpers
- (BOOL)hasError {
    return _result < 0;
}

@end
