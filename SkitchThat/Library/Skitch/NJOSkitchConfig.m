//
//  NJOSkitchConfig.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NJOSkitchConfig.h"

#import "SFHFKeychainUtils.h"

@interface NJOSkitchConfig (Private)
- (NSString *)serviceName;
@end

@implementation NJOSkitchConfig

@synthesize skitchSession = _skitchSession;

+ (NJOSkitchConfig *)sharedNJOSkitchConfig {
    static NJOSkitchConfig *sharedNJOSkitchConfig;
    
    @synchronized(self) {
        if (!sharedNJOSkitchConfig) {
            sharedNJOSkitchConfig = [[NJOSkitchConfig alloc] init];
        }
        
        return sharedNJOSkitchConfig;
    }
}

- (BOOL)hasSession {
    return (nil != self.skitchSession);
}

- (BOOL)hasCredentials {
    return (nil != self.username && nil != self.password);
}

- (void)clearCredentials {
    if (nil == self.username) {
        return;
    }

    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:self.username andServiceName:[self serviceName] error:&error];

    if (nil != error) {
        NSLog(@"An error occurred setting password: %@", [error localizedDescription]);
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
}

- (void)setUsername:(NSString *)username password:(NSString *)password {
    NSParameterAssert(nil != username);
    NSParameterAssert(nil != password);

    if ([@"" isEqualToString:username] ||
        [@"" isEqualToString:password]) {
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];

    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:[self serviceName] updateExisting:YES error:&error];

    if (nil != error) {
        NSLog(@"An error occurred setting password: %@", [error localizedDescription]);
    }
}

- (NSString *)username {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
}

- (NSString *)password {
    if (nil == self.username) {
        return nil;
    }

    NSError *error = nil;
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:self.username andServiceName:[self serviceName] error:&error];

    if (nil != error) {
        NSLog(@"An error occurred retrieving password: %@", [error localizedDescription]);
        return nil;
    }

    return password;
}

@end

@implementation NJOSkitchConfig (Private)

- (NSString *)serviceName {
    return [NSString stringWithFormat:@"%@_NJOSkitchConfig_username", [[NSBundle mainBundle] bundleIdentifier]];
}

@end