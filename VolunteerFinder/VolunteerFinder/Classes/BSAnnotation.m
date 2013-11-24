//
//  BSAnnotation.m
//  VolunteerFinder
//
//  Created by Brian Singer on 11/22/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import "BSAnnotation.h"

@implementation BSAnnotation

@synthesize theCoordinate = _theCoordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize oppID = _oppID;
@synthesize cluseredAnnotation = _cluseredAnnotation;
@synthesize containedAnnotations = _containedAnnotations;
@synthesize opp = _opp;
@synthesize type = _type;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)theTitle subtitle:(NSString*)theSubtitle oppId:(NSString*)theOppId {
	if (self = [super init]) {
		_theCoordinate = coord;
		_title = [[NSString alloc] initWithString:theTitle];
        _subtitle = [[NSString alloc] initWithString:theSubtitle];
        _oppID = [[NSString alloc] initWithString:theOppId];
        _type = BSAnnotationTypeDefault;
        _opp = nil;
	}
	return self;
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _theCoordinate = CLLocationCoordinate2DMake(newCoordinate.latitude, newCoordinate.longitude);
}

- (CLLocationCoordinate2D) coordinate
{
    return _theCoordinate;
}

@end
