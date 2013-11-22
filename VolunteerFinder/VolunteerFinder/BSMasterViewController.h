//
//  BSMasterViewController.h
//  VolunteerFinder
//
//  Created by Brian Singer on 11/19/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class BSDetailViewController;

@interface BSMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    BOOL _zoomedOnce;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) BSDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end 
