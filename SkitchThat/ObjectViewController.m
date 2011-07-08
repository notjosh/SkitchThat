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
#import "DTAttributedTextContentView.h"

#import "DTLinkButton.h"
#import "DTLazyImageView.h"

#import "NJOSkitchConfig.h"
#import "NJOSkitchResponse.h"
#import "NJOSkitchService.h"

#import "MBProgressHUD.h"

#import "MWPhotoBrowser.h"

#define THUMBNAIL_MAX_HEIGHT 100.0f
#define THUMBNAIL_CELL_PADDING 10.0f

CGFloat const kObjectViewControllerTitleFontSize = 16.0f;
CGFloat const kObjectViewControllerDimensionsFontSize = 12.0f;
CGFloat const kObjectViewControllerDetailsSeparatorPadding = 2.0f;

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
    kObjectViewControllerTableSectionDetailsRowPrimaryDetails,
    kObjectViewControllerTableSectionDetailsRowDescription,
    kObjectViewControllerTableSectionDetailsNumRows
};

enum {
    kObjectViewControllerTableSectionLinksRowShowLinks,
    kObjectViewControllerTableSectionLinksNumRows
};

@interface ObjectViewController ()

@property (retain, nonatomic) NSMutableArray *skitchComments;

- (void)handleThumbnailTapped:(UITapGestureRecognizer *)sender;
- (void)resizeHtmlRows;
@end

@interface ObjectViewController (Private)
- (UIImage *)thumbnailImage;
- (CGFloat)maxWidthForTableView:(UITableView *)tableView;
- (CGFloat) groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth;

- (CGSize)scaleSize:(CGSize)size toFitSize:(CGSize)maxSize;

- (NSString *)dimensionsAsString;
- (CGFloat)heightForTitle;
- (CGFloat)heightForDimensions;
- (CGFloat)heightForString:(NSString *)string fontSize:(CGFloat)fontSize;

- (void)loadMoreComments;
@end

@implementation ObjectViewController

@synthesize guid = _guid;
@synthesize tableView = _tableView;
@synthesize shadowView = _shadowView;
@synthesize imageView = _imageView;

@synthesize skitchComments = _skitchComments;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_guid release], _guid = nil;
    [_tableView release], _tableView = nil;
    [_shadowView release], _shadowView = nil;
    [_imageView release], _imageView = nil;
    [_contentViewCache release], _contentViewCache = nil;

    [_skitchComments release], _skitchComments = nil;
    
    [_hud release], _hud = nil;
    [_objectThumbnailUrl release], _objectThumbnailUrl = nil;
    [_objectTitle release], _objectTitle = nil;
    [_objectDescription release], _objectDescription = nil;
    [_skitchResponse release], _skitchResponse = nil;

    [_thumbnailData release], _thumbnailData = nil;

    [_titleLabel release], _titleLabel = nil;

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _commentsPreviouslyExpanded = NO;
        _commentsSectionExpanded = NO;

        _skitchComments = [[NSMutableArray alloc] init];

		// register notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lazyImageDidFinishLoading:) name:@"DTLazyImageViewDidFinishLoading" object:nil];
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

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbnailTapped:)];
    [_imageView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat xPos = [self groupedCellMarginWithTableWidth:CGRectGetWidth(_tableView.frame)] + THUMBNAIL_CELL_PADDING;
    
    if (_titleLabel) {
        _titleLabel.frame = CGRectMake(xPos, CGRectGetMaxY(_titleLabel.frame) - [self heightForTitle], [self maxWidthForTableView:_tableView], [self heightForTitle]);
    }

    [_contentViewCache removeAllObjects];
    
    [self resizeHtmlRows];
}

- (void)resizeHtmlRows {
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kObjectViewControllerTableSectionDetailsRowDescription inSection:kObjectViewControllerTableSectionDetails]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (_commentsSectionExpanded) {
        NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:[_skitchComments count]];
        
        for (NSInteger i = 1; i <= [_skitchComments count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:kObjectViewControllerTableSectionComments]];
        }

        [_tableView reloadRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [_tableView endUpdates];
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

#pragma mark - NSAttributedString+HTML
- (DTAttributedTextContentView *)contentViewForIndexPath:(NSIndexPath *)indexPath content:(NSString *)content {
    NSAssert(nil != content, @"Content is nil");

	if (!_contentViewCache) {
		_contentViewCache = [[NSMutableDictionary alloc] init];
	}
	
	DTAttributedTextContentView *contentView = (id)[_contentViewCache objectForKey:indexPath];
	
	if (!contentView) {
		NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[[UIFont systemFontOfSize:10.0f] familyName], DTDefaultFontFamily,
                                 nil];
        NSAttributedString *string = [[[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL] autorelease];
		
		// set width, height is calculated later from text
		CGFloat width = self.view.frame.size.width;
		[DTAttributedTextContentView setLayerClass:nil];
		contentView = [[[DTAttributedTextContentView alloc] initWithAttributedString:string width:width - 20.0] autorelease];

        contentView.delegate = self;
		contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		contentView.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
		[_contentViewCache setObject:contentView forKey:indexPath];
	}

	return contentView;
}

#pragma mark DTAttributedTextContentViewDelegate
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
	DTLinkButton *button = [[[DTLinkButton alloc] initWithFrame:frame] autorelease];
	button.url = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.guid = identifier;

	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
	if (DTTextAttachmentTypeImage == attachment.contentType) {
        NSLog(@"DTTextAttachmentTypeImage: %@", attachment.contentURL);

		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[[DTLazyImageView alloc] initWithFrame:frame] autorelease];
		if (attachment.contents) {
			imageView.image = attachment.contents;
		}
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
		
		return imageView;
	}
	
	return nil;
}

- (void)linkPushed:(DTLinkButton *)button {
	[[UIApplication sharedApplication] openURL:[button.url absoluteURL]];
}

- (void)lazyImageDidFinishLoading:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSURL *url = [userInfo objectForKey:@"ImageURL"];
	CGSize imageSize = [[userInfo objectForKey:@"ImageSize"] CGSizeValue];

	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];

    [_contentViewCache enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        NSAssert([obj isKindOfClass:[DTAttributedTextContentView class]], @"Contents of _contentCacheView is not all DTAttributedTextContentView");

        DTAttributedTextContentView *textContentView = (DTAttributedTextContentView *)obj;

        // update all attachments that matchin this URL (possibly multiple images with same size)
        for (DTTextAttachment *oneAttachment in [textContentView.layoutFrame textAttachmentsWithPredicate:pred]) {
            oneAttachment.originalSize = imageSize;

            if (!CGSizeEqualToSize(imageSize, oneAttachment.displaySize)) {
                oneAttachment.displaySize = imageSize;
            }

            if (oneAttachment.displaySize.width > CGRectGetWidth(textContentView.frame)) {
                oneAttachment.displaySize = [self scaleSize:imageSize toFitSize:CGSizeMake(CGRectGetWidth(textContentView.frame) - (textContentView.edgeInsets.left + textContentView.edgeInsets.right), imageSize.height)];
            }
        }
        
        // redo layout
        // here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
        [textContentView relayoutText];
    }];

    [self resizeHtmlRows];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (nil == _skitchResponse) {
        return 0;
    }

    return kObjectViewControllerTableNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (nil == _skitchResponse) {
        return 0;
    }

    switch (section) {
        case kObjectViewControllerTableSectionDetails:
            return kObjectViewControllerTableSectionDetailsNumRows;
        case kObjectViewControllerTableSectionComments:
            // toggle row + number of comments (if visible) [+ 'add comment' row, if authenticated]
            return /* toggle row: */ 1 + 
                (_commentsSectionExpanded ?
                    [_skitchComments count] +
                    ([[NJOSkitchConfig sharedNJOSkitchConfig] hasSession] ? 1 : 0)
                : 0);
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
    static NSString *HtmlCellIdentifier      = @"HtmlCellIdentifier";
    static NSString *ThumbnailCellIdentifier = @"PrimaryDetailsTableCell";
    
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case kObjectViewControllerTableSectionDetails:
            cell.accessoryType = UITableViewCellAccessoryNone;
            switch (indexPath.row) {
                case kObjectViewControllerTableSectionDetailsRowPrimaryDetails:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:ThumbnailCellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ThumbnailCellIdentifier] autorelease];

                        if (nil == _titleLabel) {
                            _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                            _titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
                            _titleLabel.tag = 8;
                            _titleLabel.font = [UIFont systemFontOfSize:kObjectViewControllerTitleFontSize];
                            _titleLabel.textAlignment = UITextAlignmentCenter;
                            _titleLabel.numberOfLines = 0;
                            _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
                        }
                        [cell addSubview:_titleLabel];

                        UILabel *dimensionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        dimensionsLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
                        dimensionsLabel.tag = 9;
                        dimensionsLabel.font = [UIFont systemFontOfSize:kObjectViewControllerDimensionsFontSize];
                        dimensionsLabel.textColor = [UIColor lightGrayColor];
                        dimensionsLabel.textAlignment = UITextAlignmentCenter;
                        [cell addSubview:dimensionsLabel];
                        [dimensionsLabel release];
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
                case kObjectViewControllerTableSectionDetailsRowDescription:
                    cell = [tableView dequeueReusableCellWithIdentifier:HtmlCellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HtmlCellIdentifier] autorelease];
                    }
                    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    break;
            }
            break;
        case kObjectViewControllerTableSectionComments:
        {
            if (!_commentsSectionExpanded || (0 == indexPath.row || indexPath.row == [_skitchComments count] + 1)) {
                cell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LabelCellIdentifier] autorelease];
                }
            } else {
                // we have a comment row!
                cell = [tableView dequeueReusableCellWithIdentifier:HtmlCellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HtmlCellIdentifier] autorelease];
                }
                [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }

            break;
        }
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
                case kObjectViewControllerTableSectionDetailsRowPrimaryDetails:
                {
                    UIImage *image = [self thumbnailImage];
                    _imageView.image = image;
                    _imageView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);

                    _shadowView.frame = _imageView.frame;
                    _shadowView.center = CGPointMake(cell.center.x, image.size.height / 2 + THUMBNAIL_CELL_PADDING); 

                    CGFloat xPos = [self groupedCellMarginWithTableWidth:CGRectGetWidth(tableView.frame)] + THUMBNAIL_CELL_PADDING;
                    CGFloat yBottom = CGRectGetHeight(cell.frame) - (THUMBNAIL_CELL_PADDING + 1.0f); // 1.0f for the line separator

                    UILabel *titleLabel = (UILabel *)[cell viewWithTag:8];
                    if (titleLabel) {
                        titleLabel.text = _objectTitle;
                        titleLabel.frame = CGRectMake(xPos, yBottom - [self heightForTitle] - ([self heightForDimensions] + kObjectViewControllerDetailsSeparatorPadding), [self maxWidthForTableView:tableView], [self heightForTitle]);
                    }

                    UILabel *dimensionsLabel = (UILabel *)[cell viewWithTag:9];
                    if (dimensionsLabel) {
                        dimensionsLabel.text = [self dimensionsAsString];
                        dimensionsLabel.frame = CGRectMake(xPos, yBottom - [self heightForDimensions], [self maxWidthForTableView:tableView], [self heightForDimensions]);
                    }

                    break;
                }
                case kObjectViewControllerTableSectionDetailsRowDescription:
                {
                    DTAttributedTextContentView *contentView = [self contentViewForIndexPath:indexPath content:_objectDescription];
                    
                    contentView.frame = cell.contentView.bounds;
                    [cell.contentView addSubview:contentView];
                    break;
                }
            }
            break;
        case kObjectViewControllerTableSectionComments:
        {
            NSInteger count = [tableView numberOfRowsInSection:indexPath.section];

            switch (indexPath.row) {
                case 0:
                    if (_commentsSectionExpanded) {
                        cell.textLabel.text = @"Hide Comments";
                    } else {
                        cell.textLabel.text = @"Show Comments";
                    }
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                    
                default:
                    if (count - 1 == indexPath.row) {
                        cell.textLabel.text = @"Add Comment...";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    } else {
                        // we have a comment row!
                        NSInteger idx = indexPath.row - 1;
                        NSDictionary *comment = [_skitchComments objectAtIndex:idx];

                        DTAttributedTextContentView *contentView = [self contentViewForIndexPath:indexPath content:[comment objectForKey:@"comment"]];
                        
                        contentView.frame = cell.contentView.bounds;
                        [cell.contentView addSubview:contentView];
                        break;
                    }

                    break;
            }
            break;
        }
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
                case kObjectViewControllerTableSectionDetailsRowPrimaryDetails:
                {
                    UIImage *image = [self thumbnailImage];

                    if (nil == image) {
                        return 0.0f;
                    }

                    CGFloat imagePartHeight = image.size.height + THUMBNAIL_CELL_PADDING * 2;

                    // add some room for labels
                    CGFloat titleHeight = [self heightForTitle];
                    CGFloat dimensionsHeight = [self heightForDimensions];

                    return imagePartHeight + titleHeight + dimensionsHeight + kObjectViewControllerDetailsSeparatorPadding + THUMBNAIL_CELL_PADDING;
                }

                case kObjectViewControllerTableSectionDetailsRowDescription:
                {
                    DTAttributedTextContentView *contentView = [self contentViewForIndexPath:indexPath content:_objectDescription];

                    return contentView.bounds.size.height + 8.0f; // for cell seperator and rounded bottom
                }
            }

            break;

        case kObjectViewControllerTableSectionComments:
        {
            if (!_commentsSectionExpanded) {
                break;
            }

            if (indexPath.row > 0 && indexPath.row <= [_skitchComments count]) {
                // we have a comment row!
                NSInteger idx = indexPath.row - 1;
                NSDictionary *comment = [_skitchComments objectAtIndex:idx];

                DTAttributedTextContentView *contentView = [self contentViewForIndexPath:indexPath content:[comment objectForKey:@"comment"]];
                return contentView.bounds.size.height + 1.0f; // for cell seperator
            }
            
            break;
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
                case kObjectViewControllerTableSectionDetailsRowPrimaryDetails:
                {
                    break;
                }
            }

            break;

        case kObjectViewControllerTableSectionComments:
            switch (indexPath.row) {
                case 0:
                    _commentsSectionExpanded = !_commentsSectionExpanded;

                    if (_commentsSectionExpanded) {

                        NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];

                        for (NSInteger i = 0; i < [_skitchComments count]; i++) {
                            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i + 1 inSection:indexPath.section]];
                        }

                        // add 'add comment' row if authenticated
                        if ([[NJOSkitchConfig sharedNJOSkitchConfig] hasSession]) {
                            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:[_skitchComments count] + 1 inSection:indexPath.section]];
                        }

                        [tableView beginUpdates];
                        [tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationBottom];
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [tableView endUpdates];

                        [indexPathsToInsert release];

                        if (!_commentsPreviouslyExpanded) {
                            [self loadMoreComments];
                            _commentsPreviouslyExpanded = YES;
                        }
                    } else {
                        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];

                        for (NSInteger i = 1; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
                            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                        }

                        [tableView beginUpdates];
                        [tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [tableView endUpdates];

                        [indexPathsToDelete release];
                    }

                    [tableView deselectRowAtIndexPath:indexPath animated:NO];

                    break;
            }
            break;

    }
}

#pragma mark - Gesture recognisers
- (void)handleThumbnailTapped:(UITapGestureRecognizer *)sender {
    NSString *url = [_skitchResponse objectForKey:@"stream"];
    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:[NSArray arrayWithObject:photo]];
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

#pragma mark - KVO observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"observed change on: %@", keyPath);
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)insertObject:(id)obj inSkitchCommentsAtIndex:(NSUInteger)index {
    [_skitchComments insertObject:obj atIndex:index];

    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index + 1 inSection:kObjectViewControllerTableSectionComments]] withRowAnimation:UITableViewRowAnimationTop];
    [_tableView endUpdates];
}

- (void)removeObjectFromSkitchCommentsAtIndex:(NSUInteger)index {
    [_skitchComments removeObjectAtIndex:index];
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

    CGFloat maxWidth = [self maxWidthForTableView:_tableView];

    // don't grow bigger than image size is!
    if (maxWidth > image.size.width && THUMBNAIL_MAX_HEIGHT > image.size.height) {
        return image;
    }

    return [image scaleToFitSize:CGSizeMake(maxWidth, THUMBNAIL_MAX_HEIGHT)];
}

- (CGFloat)maxWidthForTableView:(UITableView *)tableView {
    return CGRectGetWidth(tableView.frame) - THUMBNAIL_CELL_PADDING * 2 - [self groupedCellMarginWithTableWidth:CGRectGetWidth(tableView.frame)] * 2;
}

// voodoo. http://stackoverflow.com/questions/4708085/how-to-determine-margin-of-a-grouped-uitableview-or-better-how-to-set-it/4872199#4872199
- (CGFloat)groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth {
    CGFloat marginWidth;
    if (tableViewWidth > 20) {
        if (tableViewWidth <= 480) {
            marginWidth = 10;
        } else {
            marginWidth = MAX(31, MIN(45, tableViewWidth * 0.06));
        }
    } else {
        marginWidth = tableViewWidth - 10;
    }

    return marginWidth;
}

- (CGSize)scaleSize:(CGSize)size toFitSize:(CGSize)maxSize {
	const size_t originalWidth = size.width;
	const size_t originalHeight = size.height;
    
	/// Keep aspect ratio
	size_t destWidth, destHeight;
	if (originalWidth > originalHeight)
	{
		destWidth = maxSize.width;
		destHeight = originalHeight * maxSize.width / originalWidth;
	}
	else
	{
		destHeight = maxSize.height;
		destWidth = originalWidth * maxSize.height / originalHeight;
	}
	if (destWidth > maxSize.width)
	{ 
		destWidth = maxSize.width; 
		destHeight = originalHeight * maxSize.width / originalWidth; 
	} 
	if (destHeight > maxSize.height)
	{ 
		destHeight = maxSize.height; 
		destWidth = originalWidth * maxSize.height / originalHeight; 
	}

    return CGSizeMake(destWidth, destHeight);
}

- (NSString *)dimensionsAsString {
    return [NSString stringWithFormat:@"%dx%d", _objectWidth, _objectHeight];
}

- (CGFloat)heightForTitle {
    return [self heightForString:_objectTitle fontSize:kObjectViewControllerTitleFontSize];
}

- (CGFloat)heightForDimensions {
    return [self heightForString:[self dimensionsAsString] fontSize:kObjectViewControllerDimensionsFontSize];
}

- (CGFloat)heightForString:(NSString *)string fontSize:(CGFloat)fontSize {
    CGSize maximumLabelSize = CGSizeMake([self maxWidthForTableView:_tableView], 99999.0f);
    
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] 
                                      constrainedToSize:maximumLabelSize 
                                          lineBreakMode:UILineBreakModeWordWrap];

    return expectedLabelSize.height;
}

#pragma mark - Skitch API helpers
- (void)loadMoreComments {
    NSDictionary *lastComment = [_skitchComments lastObject];

    NSString *fromId = (nil != lastComment) ? [lastComment objectForKey:@"id"] : nil;

    NJOSkitchService *s = [[NJOSkitchService alloc] init];

    s.completionBlock = ^(NJOSkitchResponse *response) {
        if ([response hasError]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:[response message]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av release];
            
            return;
        }

        NSDictionary *comments = [[response skitchResponse] objectForKey:@"comments"];

        if (nil == comments) {
            return;
        }

        for (NSDictionary *comment in comments) {
            [self insertObject:comment inSkitchCommentsAtIndex:[_skitchComments count]];
        }
    };

    [s fetchComments:[_skitchResponse objectForKey:@"objectguid"] fromId:fromId];
    [s release];
}

@end
