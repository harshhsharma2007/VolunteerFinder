//
//  BSMasterViewController.m
//  VolunteerFinder
//
//  Created by Brian Singer on 11/19/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import "BSMasterViewController.h"
#import "DataManager.h"
#import "BSDetailViewController.h"
#import "NCItemBrowser.h"

@interface BSMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation BSMasterViewController

@synthesize tableView = _tableView;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }

    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _zoomedOnce = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (BSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    _objects = [[NSMutableArray alloc] initWithArray:[Opp MR_findAll]];

    [self.mapView setShowsUserLocation:YES];
    
    
    //create table view
    //_tableView = [[UITableView alloc] initWithFrame:CGRectOffset(self.mapView.frame, 0, self.mapView.frame.size.height) style:UITableViewStyleGrouped];
    _tableView = [[UITableView alloc] initWithFrame:CGRectOffset(self.mapView.frame, 0, 0) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //setup the toolbar bg
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.toolbar.frame = CGRectOffset(self.mapView.frame, 0, self.mapView.frame.size.height);
    }
}

- (void) updateObjects {
    _objects = [[NSMutableArray alloc] initWithArray:[Opp MR_findAll]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
    }

    
    Opp *object = _objects[indexPath.row];
    cell.textLabel.text = [object title];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
    else {
        Opp *selectedOpp = _objects[indexPath.row];
        
        NCItemBrowser *browser = [[NCItemBrowser alloc] initWithItem:selectedOpp];
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Map Delegate

//- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    return nil;
//}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {}

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    float distance = roundf(MKMetersBetweenMapPoints(eastMapPoint, westMapPoint) / 2);
    
    CLLocationCoordinate2D centerCoord = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView];
    
    [[DataManager instance] findOppsWithCenter:centerCoord distance:distance target:self callback:@selector(updateObjects) failureCallback:@selector(updateObjects)];
    
    
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!_zoomedOnce && (userLocation.location.horizontalAccuracy < 2000 || userLocation.location.verticalAccuracy < 2000)) {
        
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 4000, 4000)];
        _zoomedOnce = YES;

    }
    
    
}

@end
