//
//  Utilities.m
//  VolunteerFinder
//
//  Created by Brian Singer on 11/12/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import "Utilities.h"

static Utilities *_kSharedInstance = nil;


@implementation Utilities

#pragma mark - activity indicator methods

//adds to the activity count which spins the network activity indicator
- (void)startActivity
{
	//increment the activity count
	//show start the activity indicator
	_activityCount++;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

//subtract from the activity count
//if the count reaches zero, stop the network activity indicator
- (void)stopActivity {
	
	if (--_activityCount <= 0) {
		_activityCount = 0;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	}
}


#pragma mark - Class Methods

//singleton
+ (Utilities *)instance
{
	@synchronized(self)	{
		if (_kSharedInstance == nil)
			_kSharedInstance = [[Utilities alloc] init];
	}
	return _kSharedInstance;
}

//determines if the current iOS is 7.0 or higher
+ (BOOL) is7OrHigher
{
	return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
}


@end
