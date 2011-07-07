//
//  ObjectViewController.h
//  SkitchThat
//
//  Created by Joshua May on 22/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTAttributedTextContentView.h"
#import "NJOSkitchServiceDelegate.h"

@class MBProgressHUD;

@interface ObjectViewController : UIViewController <NJOSkitchServiceDelegate, DTAttributedTextContentViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    MBProgressHUD *_hud;
    NSMutableDictionary *_contentViewCache;

    NSString *_objectThumbnailUrl;
    NSString *_objectTitle;
    NSString *_objectDescription;
    NSUInteger _objectWidth;
    NSUInteger _objectHeight;

    NSDictionary *_skitchResponse;

    BOOL _commentsPreviouslyExpanded;
    BOOL _commentsSectionExpanded;

    NSData *_thumbnailData;
}

@property (retain, nonatomic) NSString *guid;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *shadowView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@end
