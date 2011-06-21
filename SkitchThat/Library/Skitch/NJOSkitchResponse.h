//
//  NJOSkitchResponse.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NJOSkitchResponse : NSObject {
    NSDictionary *_skitchResponse;

    NSInteger _result;
    NSString *_message;

    NSDecimalNumber *_version;
    NSString *_noun;
}

- (id)initWithXmlString:(NSString *)xml;

- (BOOL)hasError;


@property (readonly, nonatomic) NSDictionary *skitchResponse;

@property (readonly, nonatomic) NSInteger result;
@property (readonly, nonatomic) NSString *message;

@property (readonly, nonatomic) NSDecimalNumber *version;
@property (readonly, nonatomic) NSString *noun;

@end
