//
//  NJOSkitchService.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NJOSkitchServiceDelegate.h"


extern NSString * const kNJOSkitchServiceTypeJpeg;
extern NSString * const kNJOSkitchServiceTypePng;

extern CGFloat const kNJOSkitchServiceJpegCompressionQuality;


@interface NJOSkitchService : NSObject {
//    id<NJOSkitchServiceDelegate> _delegate;
}

@property (assign, nonatomic) id<NJOSkitchServiceDelegate> delegate;

- (void)addImageAsPng:(UIImage *)image name:(NSString *)name;
- (void)addImageAsJpeg:(UIImage *)image name:(NSString *)name;
- (void)addImage:(UIImage *)image type:(NSString *)type name:(NSString *)name;

- (void)fetchObject:(NSString *)guid;

@end


/*
POST /api/1.0/auth/login
 - username: string
 - password: string

-> response {JSON}
 - JSON:
   {"result":true,"message":"OK"}

on start of app:
POST /services/application/authorize
 - initialchannelid	Direct
 - skitchversion	1.0.6
 - osversion	10.06.07
 - installationid	0ECC641D-5598-4408-8FB5-62B5DB432C35
 - channelid	Direct
 - platform	Mac
 - authtoken	ZFhObGNqRT18Y0dGemN6RT0=
 - language	en-US

notes:
 user1, pass1 (base64 encode each, add pipe separator)
 -> dXNlcjE=|cGFzczE= (base64 encode)
 -> ZFhObGNqRT18Y0dGemN6RT0=

-> response {JSON}
 result	Boolean	true
 message	String	OK
 plus	Boolean	true
 introurl	String	http://skitch.com/services/application/intro/welcome?authtoken=Ym05MGFtOXphQT09fGEyVnlabUZz&identifier=0ECC641D-5598-4408-8FB5-62B5DB432C35&channelcode=Direct
 bezelurl	String	http://skitch.com/services/application/topbezel
 storeurl	String	http://skitch.com/services/application/intro/getplus
 accounturl	String	http://skitch.com/notjosh/
 anonymous	Boolean	false
 clientood	Boolean	false
 userguid	String	deffa6-2e8032-4fe7f4-7e1825-c5cd7f-f5
 userpage	String	http://skitch.com/notjosh/
 introwidth	Integer	510
 introheight	Integer	670
 forceintro	Boolean	false
 prefershowintro	Boolean	false
 code	Integer	0
*/