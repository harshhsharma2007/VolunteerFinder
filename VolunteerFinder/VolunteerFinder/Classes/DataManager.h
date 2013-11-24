//
//  DataManager.h
//  VolunteerFinder
//
//  Created by Brian Singer on 11/11/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModels.h"
#import <MapKit/MapKit.h>

@interface DataManager : NSObject

+ (id)instance;

//data calls
- (void) syncConfigWithTarget:(id)target callback:(SEL)callback failureCallback:(SEL)failureCallback;
- (void) findOppsWithCenter:(CLLocationCoordinate2D)center distance:(float)dist target:(id)target callback:(SEL)callback failureCallback:(SEL)failureCallback;
- (void) findOppsWithCenter:(CLLocationCoordinate2D)center distance:(float)dist target:(id)target callback:(SEL)callback failureCallback:(SEL)failureCallback page:(int)page;

@end
