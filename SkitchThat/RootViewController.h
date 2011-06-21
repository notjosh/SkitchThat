//
//  RootViewController.h
//  SkitchThat
//
//  Created by compo on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_files;
}


@end
