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
}

@property (readonly, nonatomic) NSDictionary *skitchResponse;

@property (readonly, nonatomic) NSInteger result;
@property (readonly, nonatomic) NSString *message;

- (BOOL)hasError;

@end
