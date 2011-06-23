//
//  ObjectViewController.m
//  SkitchThat
//
//  Created by Joshua May on 22/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImage+Resizing.h"

#import "NJOSkitchService.h"
#import "NJOSkitchResponse.h"

#import "MBProgressHUD.h"

#import "MWPhotoBrowser.h"

#define THUMBNAIL_MAX_HEIGHT 100.0f
#define THUMBNAIL_CELL_PADDING 10.0f

enum {
    kObjectViewControllerTableSectionDetails,
    kObjectViewControllerTableSectionComments,
    kObjectViewControllerTableSectionLinks,
    kObjectViewControllerTableSectionPrivacy,
    kObjectViewControllerTableSectionTags,
    kObjectViewControllerTableSectionSets,
    kObjectViewControllerTableNumSections
};

enum {
    kObjectViewControllerTableSectionDetailsRowThumbnail,
    kObjectViewControllerTableSectionDetailsRowName,
    kObjectViewControllerTableSectionDetailsRowDecsription,
    kObjectViewControllerTableSectionDetailsRowDimensions,
    kObjectViewControllerTableSectionDetailsNumRows
};

enum {
    kObjectViewControllerTableSectionCommentsRowAddComment,
    kObjectViewControllerTableSectionCommentsNumRows
};

enum {
    kObjectViewControllerTableSectionLinksRowShowLinks,
    kObjectViewControllerTableSectionLinksNumRows
};

@interface ObjectViewController (Private)
- (UIImage *)thumbnailImage;
- (CGFloat) groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth;
@end

@implementation ObjectViewController

@synthesize guid = _guid;
@synthesize tableView = _tableView;
@synthesize shadowView = _shadowView;
@synthesize imageView = _imageView;

- (void)dealloc {
    [_guid release], _guid = nil;
    [_tableView release], _tableView = nil;
    [_shadowView release], _shadowView = nil;
    [_imageView release], _imageView = nil;
    
    [_hud release], _hud = nil;
    [_objectThumbnailUrl release], _objectThumbnailUrl = nil;
    [_objectTitle release], _objectTitle = nil;
    [_objectDescription release], _objectDescription = nil;
    [_skitchResponse release], _skitchResponse = nil;

    [_thumbnailData release], _thumbnailData = nil;

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (nil == _skitchResponse) {
        NJOSkitchService *s = [[NJOSkitchService alloc] init];
        s.delegate = self;
        [s fetchObject:_guid];
        [s release];

        [_hud show:YES];

        _tableView.hidden = YES;
    }

    // Set status/navigation bar style to normal
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.labelText = @"Loading...";
    [self.view addSubview:_hud];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource
- (void)requestComplete:(NJOSkitchResponse *)response {
    NSLog(@"-> %@", response);
    
    [_hud hide:YES];

    if ([response hasError]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:[response message]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        
        return;
    }

    NSDictionary *skitchResponse = [response skitchResponse];

    _objectThumbnailUrl = [[skitchResponse objectForKey:@"stream"] retain];
    _objectTitle        = [[skitchResponse objectForKey:@"objecttitle"] retain];
    _objectDescription  = [[skitchResponse objectForKey:@"description"] retain];
    _objectWidth        = [[skitchResponse objectForKey:@"objectwidth"] intValue];
    _objectHeight       = [[skitchResponse objectForKey:@"objectheight"] intValue];

    _skitchResponse = [skitchResponse retain];

    [_tableView reloadData];
    _tableView.hidden = NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kObjectViewControllerTableNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kObjectViewControllerTableSectionDetails:
            return kObjectViewControllerTableSectionDetailsNumRows;
        case kObjectViewControllerTableSectionComments:
            return kObjectViewControllerTableSectionCommentsNumRows;
        case kObjectViewControllerTableSectionLinks:
            return kObjectViewControllerTableSectionLinksNumRows;
        case kObjectViewControllerTableSectionPrivacy:
            return 1;
        case kObjectViewControllerTableSectionTags:
            return 1;
        case kObjectViewControllerTableSectionSets:
            return 1;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kObjectViewControllerTableSectionDetails:
            return nil;
        case kObjectViewControllerTableSectionComments:
            return @"Comments";
        case kObjectViewControllerTableSectionLinks:
            return @"Links";
        case kObjectViewControllerTableSectionPrivacy:
            return @"Privacy";
        case kObjectViewControllerTableSectionTags:
            return @"Tags";
        case kObjectViewControllerTableSectionSets:
            return @"Sets";
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LabelCellIdentifier     = @"LabelTableCell";
    static NSString *ThumbnailCellIdentifier = @"ThumbnailLabelTableCell";
    
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case kObjectViewControllerTableSectionDetails:
            cell.accessoryType = UITableViewCellAccessoryNone;
            switch (indexPath.row) {
                case kObjectViewControllerTableSectionDetailsRowThumbnail:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:ThumbnailCellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ThumbnailCellIdentifier] autorelease];
                    }

                    _imageView.layer.cornerRadius = 6.0f;
                    _imageView.layer.masksToBounds = YES;

                    _shadowView.backgroundColor = [UIColor clearColor];
                    _shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
                    _shadowView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
                    _shadowView.layer.shadowOpacity = 0.5f;
                    _shadowView.layer.shadowRadius = 3.0f;
                    
                    [cell addSubview:_shadowView];

                    break;
                }
                case kObjectViewControllerTableSectionDetailsRowName:
                case kObjectViewControllerTableSectionDetailsRowDecsription:
                case kObjectViewControllerTableSectionDetailsRowDimensions:
                    cell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LabelCellIdentifier] autorelease];
                    }

                    break;
            }
            break;
        case kObjectViewControllerTableSectionComments:
        case kObjectViewControllerTableSectionLinks:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LabelCellIdentifier] autorelease];
            }

            break;
    }

    NSAssert(nil != cell, @"Cell was null!");

    switch (indexPath.section) {
        case kObjectViewControllerTableSectionDetails:
            cell.accessoryType = UITableViewCellAccessoryNone;
            switch (indexPath.row) {
                case kObjectViewControllerTableSectionDetailsRowThumbnail:
                {
                    UIImage *image = [self thumbnailImage];
                    _imageView.image = image;
                    _imageView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);

                    _shadowView.frame = _imageView.frame;
                    _shadowView.center = CGPointMake(cell.center.x, image.size.height / 2 + THUMBNAIL_CELL_PADDING);

                    break;
                }
                case kObjectViewControllerTableSectionDetailsRowName:
                    cell.textLabel.text = _objectTitle;
                    break;
                case kObjectViewControllerTableSectionDetailsRowDecsription:
                    cell.textLabel.text = _objectDescription;
                    break;
                case kObjectViewControllerTableSectionDetailsRowDimensions:
                    cell.textLabel.text = [NSString stringWithFormat:@"%dx%d", _objectWidth, _objectHeight];
                    break;
            }
            break;
        case kObjectViewControllerTableSectionComments:
            cell.textLabel.text = @"Add Comment...";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kObjectViewControllerTableSectionLinks:
            cell.textLabel.text = @"Links";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        default:
            cell.textLabel.text = [NSString stringWithFormat:@"%d,%d", indexPath.section, indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kObjectViewControllerTableSectionDetails:
            switch (indexPath.row) {
                case kObjectViewControllerTableSectionDetailsRowThumbnail:
                {
                    UIImage *image = [self thumbnailImage];

                    if (nil == image) {
                        return 0.0f;
                    }

                    return image.size.height + THUMBNAIL_CELL_PADDING * 2;
                }
            }
    }

    return [tableView rowHeight];
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//        case kObjectViewControllerTableSectionDetails:
//            return nil;
//    }
//    
//    return indexPath;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kObjectViewControllerTableSectionDetails:
            switch (indexPath.row) {
                case kObjectViewControllerTableSectionDetailsRowThumbnail:
                {
                    NSString *url = [_skitchResponse objectForKey:@"stream"];
                    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
                    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:[NSArray arrayWithObject:photo]];
                    [self.navigationController pushViewController:browser animated:YES];
                    [browser release];

                    break;
                }
            }
    }
}

@end

@implementation ObjectViewController (Private)

- (UIImage *)thumbnailImage {
    if (nil == _objectThumbnailUrl) {
        return nil;
    }

    if (nil == _thumbnailData) {
        _thumbnailData = [[NSData dataWithContentsOfURL:[NSURL URLWithString:_objectThumbnailUrl]] retain];
    }

    UIImage *image = [UIImage imageWithData:_thumbnailData];

    CGFloat maxWidth = CGRectGetWidth(_tableView.frame) - THUMBNAIL_CELL_PADDING * 2 - [self groupedCellMarginWithTableWidth:CGRectGetWidth(_tableView.frame)] * 2;

    // don't grow bigger than image size is!
    if (maxWidth > image.size.width && THUMBNAIL_MAX_HEIGHT > image.size.height) {
        return image;
    }

    return [image scaleToFitSize:CGSizeMake(maxWidth, THUMBNAIL_MAX_HEIGHT)];
}

// voodoo. http://stackoverflow.com/questions/4708085/how-to-determine-margin-of-a-grouped-uitableview-or-better-how-to-set-it/4872199#4872199
- (CGFloat)groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth {
    CGFloat marginWidth;
    if (tableViewWidth > 20) {
        if (tableViewWidth < 400) {
            marginWidth = 10;
        } else {
            marginWidth = MAX(31, MIN(45, tableViewWidth*0.06));
        }
    } else {
        marginWidth = tableViewWidth - 10;
    }

    return marginWidth;
}

@end
