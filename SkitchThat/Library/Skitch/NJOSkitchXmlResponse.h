//
//  NJOSkitchXmlResponse.h
//  
//
//  Created by compo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NJOSkitchResponse.h"

@interface NJOSkitchXmlResponse : NJOSkitchResponse {
    NSDecimalNumber *_version;
    NSString *_noun;
}

@property (readonly, nonatomic) NSDecimalNumber *version;
@property (readonly, nonatomic) NSString *noun;

- (id)initWithXmlString:(NSString *)xml;

@end
