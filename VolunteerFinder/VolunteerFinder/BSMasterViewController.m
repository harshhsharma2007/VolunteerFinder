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
#import "BSAnnotation.h"

@interface BSMasterViewController () {
    NSMutableArray *_objects;
}
- (void) updateVisibleAnnotations;
- (void) switchTable:(id)sender;
- (void) calloutButtonTapped:(id)sender;
@end

@implementation BSMasterViewController

@synthesize tableView = _tableView, hiddenMapView = _hiddenMapView;

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
    
    _zoomedOnce = NO;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController = (BSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    }
    else {
        
        UIBarButtonItem *tableButton = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(switchTable:)];
        self.navigationItem.leftBarButtonItem = tableButton;
        
    }
    
    _objects = [[NSMutableArray alloc] initWithArray:[Opp MR_findAll]];

    [self.mapView setShowsUserLocation:YES];
    
    //create table view
    _tableView = [[UITableView alloc] initWithFrame:CGRectOffset(self.mapView.frame, 0, self.mapView.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    //create hidden mapview
    _hiddenMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //setup the toolbar bg
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.toolbar.frame = CGRectOffset(self.mapView.frame, 0, self.mapView.frame.size.height);
    }
    else {
        self.mapView = self.detailViewController.mapView;
        self.detailViewController.mapView.delegate = self;
        
        if (!_zoomedOnce && (self.mapView.userLocation.location.horizontalAccuracy < 2000 || self.mapView.userLocation.location.verticalAccuracy < 2000)) {
            
            [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 4000, 4000)];
            _zoomedOnce = YES;
            
            [self refreshOppsWithCurrentRegion];
            
        }
    }
}

- (void) refreshOppsWithCurrentRegion {
    
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMidY(mRect));
    
    //TODO: figure out the dist issue
    float distance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint) / 1609.34f;
    
    CLLocationCoordinate2D centerCoord = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView];
    
    [[DataManager instance] findOppsWithCenter:centerCoord distance:0.3f target:self callback:@selector(updateObjects) failureCallback:@selector(updateObjects)];
    
}

- (void) switchTable:(id)sender {
    
    [UIView animateWithDuration:0.3f animations:^{
        
        if (self.tableView.frame.origin.y == self.mapView.frame.origin.y) {
            self.tableView.frame = CGRectOffset(self.mapView.frame, 0, self.mapView.frame.size.height);
            [(UIBarButtonItem*)sender setTitle:@"List"];
        }
        else {
            self.tableView.frame = CGRectOffset(self.mapView.frame, 0, 0);
            [(UIBarButtonItem*)sender setTitle:@"Hide"];
        }
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void) updateObjects {
    _objects = [[NSMutableArray alloc] initWithArray:[Opp MR_findAll]];
    [self.tableView reloadData];
    
    //add opps to map
    for (Opp *thisOpp in _objects) {

            
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(thisOpp.lat.floatValue, thisOpp.lon.floatValue);
            
        BSAnnotation *a = [[BSAnnotation alloc] initWithCoordinate:coord title:thisOpp.title subtitle:thisOpp.desc oppId:thisOpp.oppID];
        [a setOpp:thisOpp];
        [_hiddenMapView addAnnotation:a];
        
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateVisibleAnnotations];
}

- (void) updateVisibleAnnotations {
    
    static float marginFactor = 2.0f;
    static float bucketSize = 45.0f;
    
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    MKMapRect adjustVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height);
    
    CLLocationCoordinate2D leftCoord = [self.mapView convertPoint:CGPointZero toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D rightCoord = [self.mapView convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:self.mapView];
    double gridSize = MKMapPointForCoordinate(rightCoord).x - MKMapPointForCoordinate(leftCoord).x;
    MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
    
    double startX = floor(MKMapRectGetMinX(adjustVisibleMapRect) / gridSize) * gridSize;
    double startY = floor(MKMapRectGetMinY(adjustVisibleMapRect) / gridSize) * gridSize;
    double endX = floor(MKMapRectGetMaxX(adjustVisibleMapRect) / gridSize) * gridSize;
    double endY = floor(MKMapRectGetMaxY(adjustVisibleMapRect) / gridSize) * gridSize;
    
    gridMapRect.origin.y = startY;
    while (MKMapRectGetMinY(gridMapRect) < endY) {
        gridMapRect.origin.x = startX;
        
        while (MKMapRectGetMinX(gridMapRect) < endX) {
            
            NSSet *allAnnotationsInBucket = [_hiddenMapView annotationsInMapRect:gridMapRect];
            NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:gridMapRect];
            
            NSMutableSet *filteredAnnotations = [[allAnnotationsInBucket objectsPassingTest:^BOOL(id obj, BOOL *stop) {
                return ([obj isKindOfClass:[BSAnnotation class]]);
            }] mutableCopy];
            
            if (filteredAnnotations.count > 0) {
                BSAnnotation *annotationForGrid = (BSAnnotation*)[self annotationsInGrid:gridMapRect usingAnnoations:filteredAnnotations];
                [filteredAnnotations removeObject:annotationForGrid];
                
                annotationForGrid.containedAnnotations = [filteredAnnotations allObjects];
                
                [self.mapView addAnnotation:annotationForGrid];
                
                for (BSAnnotation *annotation in filteredAnnotations) {
                    annotation.cluseredAnnotation = annotationForGrid;
                    annotation.containedAnnotations = nil;
                    
                    if ([visibleAnnotationsInBucket containsObject:annotation]) {
                        CLLocationCoordinate2D actualCoordiante = annotation.coordinate;
                        [UIView animateWithDuration:0.3 animations:^{
                            annotation.coordinate = annotation.cluseredAnnotation.coordinate;
                        } completion:^(BOOL finished) {
                            annotation.coordinate = actualCoordiante;
                            [self.mapView removeAnnotation:annotation];
                        }];
                        
                    }
                }
                
            }
            
            gridMapRect.origin.x += gridSize;
            
        }
        
        gridMapRect.origin.y += gridSize;
    }
    
    
}

- (id<MKAnnotation>) annotationsInGrid:(MKMapRect)grid usingAnnoations:(NSSet*)annotations {
    NSSet *visibleAnnoations = [self.mapView annotationsInMapRect:grid];
    NSSet *annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        BOOL returnValue = ([visibleAnnoations containsObject:obj]);
        if (returnValue)
            *stop = YES;
        return returnValue;
    }];
    
    if (annotationsForGridSet.count != 0) {
        return [annotationsForGridSet anyObject];
    }
    
    MKMapPoint centerMapPOint = MKMapPointMake(MKMapRectGetMidX(grid), MKMapRectGetMidY(grid));
    NSArray *sortedAnnotations = [[annotations allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
        MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);
        
        CLLocationDirection distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPOint);
        CLLocationDirection distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPOint);
        
        if (distance1 < distance2) {
            return NSOrderedAscending;
        } else if (distance1 > distance2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
        
    }];
    
    return [sortedAnnotations objectAtIndex:0];
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
    Opp *selectedOpp = _objects[indexPath.row];
    
    if (!_browser)
        _browser = [[NCItemBrowser alloc] initWithItem:selectedOpp];
    else
        [_browser setItem:selectedOpp];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        if (self.detailViewController.navigationController.viewControllers.count == 1)
            [self.detailViewController.navigationController pushViewController:_browser animated:YES];
        
    }
    else {
        
        
        [self.navigationController pushViewController:_browser animated:YES];
    }
}

#pragma mark - Map Delegate

- (void) calloutButtonTapped:(id)sender {
    
    if (self.mapView.selectedAnnotations.count == 1) {
        
        BSAnnotation *selectedAnnotation = self.mapView.selectedAnnotations.firstObject;
        Opp *selectedOpp = selectedAnnotation.opp;
        
        if (!_browser)
            _browser = [[NCItemBrowser alloc] initWithItem:selectedOpp];
        else
            [_browser setItem:selectedOpp];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            if (self.detailViewController.navigationController.viewControllers.count == 1)
                [self.detailViewController.navigationController pushViewController:_browser animated:YES];
            
        }
        else {
            [self.navigationController pushViewController:_browser animated:YES];
        }
    }
    
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
        
    MKAnnotationView *a = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"opp"];
    [a setImage:[UIImage imageNamed:@"carDot2.png"]];
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [disclosureButton addTarget:self action:@selector(calloutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [a setRightCalloutAccessoryView:disclosureButton];
    [a setCanShowCallout:YES];
    
    return a;

    
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {


}

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _previousSpan = mapView.region.span;
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    
    float latDiff = fabsf(mapView.region.span.latitudeDelta - _previousSpan.latitudeDelta);
    float lonDiff = fabsf(mapView.region.span.longitudeDelta - _previousSpan.longitudeDelta);
    
    if (lonDiff > 0.001 || latDiff > 0.001)
        [self updateVisibleAnnotations];
    
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!_zoomedOnce && (userLocation.location.horizontalAccuracy < 2000 || userLocation.location.verticalAccuracy < 2000)) {
        
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 4000, 4000)];
        _zoomedOnce = YES;
        
        [self refreshOppsWithCurrentRegion];

    }
    
    
}



@end
