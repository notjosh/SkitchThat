//
//  RootViewController.m
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "CredentialsViewController.h"
#import "DetailViewController.h"

#import "NJOSkitchConfig.h"

@interface RootViewController (Private)
- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath;
- (NSString *)pathForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tidyFileSizeForItemAtPath:(NSString *)path;
@end

@implementation RootViewController

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)awakeFromNib {
    _files = [[NSMutableArray alloc] init];
    
    NSString *resourcesDirectory = [[NSBundle mainBundle] bundlePath];
    [_files addObjectsFromArray:[self recursivePathsForResourcesOfType:@"jpg" inDirectory:resourcesDirectory]];
    [_files addObjectsFromArray:[self recursivePathsForResourcesOfType:@"png" inDirectory:resourcesDirectory]];
    
    //NSAssert(nil == error, @"Error loading SVG files", [error description]);
    
    NSLog(@"%@", _files);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Root";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NSString *path = [self pathForIndexPath:indexPath];
    cell.textLabel.text = [path lastPathComponent];
    cell.detailTextLabel.text = [self tidyFileSizeForItemAtPath:path];;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[NJOSkitchConfig sharedNJOSkitchConfig] hasCredentials]) {
        NSLog(@"No skitch credentials. Set them first!");
        return;
    }

    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailViewController.filePath = [self pathForIndexPath:indexPath];

    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (IBAction)handleConfigTapped:(id)sender {
    CredentialsViewController *credentialsViewController = [[CredentialsViewController alloc] initWithNibName:@"CredentialsViewController" bundle:nil];
    [self.navigationController presentModalViewController:credentialsViewController animated:YES];
    [credentialsViewController release];
}

@end

@implementation RootViewController (Private)

- (NSString *)pathForIndexPath:(NSIndexPath *)indexPath {
    return [_files objectAtIndex:indexPath.row];
}

- (NSArray *)recursivePathsForResourcesOfType: (NSString *)type inDirectory: (NSString *)directoryPath {
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    NSDirectoryEnumerator *enumerator = [[[NSFileManager defaultManager] enumeratorAtPath:directoryPath] retain] ;
    
    NSString *filePath;
    
    while (nil != (filePath = [enumerator nextObject])) {
        if( [[filePath pathExtension] isEqualToString:type] ){
            [filePaths addObject:[NSString stringWithFormat:@"%@/%@", directoryPath, filePath]];
        }
    }
    
    [enumerator release];
    
    return [filePaths autorelease];
}

- (NSString *)tidyFileSizeForItemAtPath:(NSString *)path {
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];

    unsigned long long size = [attributes fileSize];
    float displaySize = size;
    int i = 0;

    NSArray *labels = [NSArray arrayWithObjects:@"b", @"kb", @"mb", nil];

    for (i = 0; i < [labels count]; i++) {
        if (displaySize < 1024) {
            break;
        }

        if ([labels count] - 1 == i) {
            break;
        }

        displaySize /= 1024;
    }

    return [NSString stringWithFormat:@"%0.1f%@", displaySize, [labels objectAtIndex:i]];
}

@end
