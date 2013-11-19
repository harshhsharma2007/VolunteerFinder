//
//  BSMasterViewController.h
//  VolunteerFinder
//
//  Created by Brian Singer on 11/19/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSDetailViewController;

@interface BSMasterViewController : UITableViewController

@property (strong, nonatomic) BSDetailViewController *detailViewController;

@end 
