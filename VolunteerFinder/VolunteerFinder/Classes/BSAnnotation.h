//
//  BSAnnotation.h
//  VolunteerFinder
//
//  Created by Brian Singer on 11/22/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

enum BSAnnotationType {
    BSAnnotationTypeDefault = 0
};

@interface BSAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D theCoordinate;
@property (nonatomic, copy) NSString *title, *subtitle, *oppID;
@property (nonatomic, retain) BSAnnotation *cluseredAnnotation;
@property (nonatomic, retain) NSArray *containedAnnotations;
@property (nonatomic, retain) id opp;
@property  int type;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)theTitle subtitle:(NSString*)theSubtitle oppId:(NSString*)theOppId;

@end
