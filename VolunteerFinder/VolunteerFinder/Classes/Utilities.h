//
//  Utilities.h
//  VolunteerFinder
//
//  Created by Brian Singer on 11/12/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import <Foundation/Foundation.h>

//System Versioning Preprocessor Macros
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface Utilities : NSObject {
    int _activityCount;
}

+ (Utilities *)instance;
+ (BOOL) is7OrHigher;

- (void)startActivity;
- (void)stopActivity;

@end
