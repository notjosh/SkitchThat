//
//  ObjectViewController.m
//  SkitchThat
//
//  Created by Joshua May on 22/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectViewController.h"

#import "NJOSkitchService.h"
#import "NJOSkitchResponse.h"

#import "MBProgressHUD.h"

#import "MWPhotoBrowser.h"

#define THUMBNAIL_HEIGHT 100.0f

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

@implementation ObjectViewController

@synthesize guid = _guid;
@synthesize tableView = _tableView;
@synthesize imageView = _imageView;

- (void)dealloc {
    [_guid release], _guid = nil;
    [_tableView release], _tableView = nil;
    [_imageView release], _imageView = nil;
    
    [_hud release], _hud = nil;
    [_objectThumbnailUrl release], _objectThumbnailUrl = nil;
    [_objectTitle release], _objectTitle = nil;
    [_objectDescription release], _objectDescription = nil;
    [_skitchResponse release], _skitchResponse = nil;

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

    NJOSkitchService *s = [[NJOSkitchService alloc] init];
    s.delegate = self;
    [s fetchObject:_guid];
    [s release];

    [_hud show:YES];

    _tableView.hidden = YES;
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
    static NSString *CellIdentifier = @"ObjectTextTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    switch (indexPath.section) {
        case kObjectViewControllerTableSectionDetails:
            cell.accessoryType = UITableViewCellAccessoryNone;
            switch (indexPath.row) {
                case kObjectViewControllerTableSectionDetailsRowThumbnail:
                {
                    NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:_objectThumbnailUrl]];
                    UIImage *image = [UIImage imageWithData:d];

                    _imageView.image = image;
                    _imageView.frame = CGRectMake(CGRectGetMinX(cell.contentView.frame), CGRectGetMinY(cell.contentView.frame), CGRectGetWidth(cell.contentView.frame), THUMBNAIL_HEIGHT);

                    [cell addSubview:_imageView];

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
                    return THUMBNAIL_HEIGHT;
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
