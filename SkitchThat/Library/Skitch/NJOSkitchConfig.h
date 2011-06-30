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

@property (nonatomic, retain) NSDictionary *skitchSession;

+ (NJOSkitchConfig *)sharedNJOSkitchConfig;

- (BOOL)hasSession;
- (BOOL)hasCredentials;
- (void)clearCredentials;

- (void)setUsername:(NSString *)username password:(NSString *)password;
- (NSString *)username;
- (NSString *)password;


@end
