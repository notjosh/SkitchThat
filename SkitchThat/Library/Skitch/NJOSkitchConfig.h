//
//  NJOSkitchConfig.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NJOSkitchConfig : NSObject {
    
}

+ (NJOSkitchConfig *)sharedNJOSkitchConfig;

- (BOOL)hasCredentials;

- (void)setUsername:(NSString *)username password:(NSString *)password;
- (NSString *)username;
- (NSString *)password;


@end
