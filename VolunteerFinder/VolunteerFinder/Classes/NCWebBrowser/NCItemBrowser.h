//
//  NCItemBrowser.h
//  VolunteerFinder
//
//  Created by Brandon Jones on 11/18/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import "NCWebBrowser.h"

@interface NCItemBrowser : NCWebBrowser

@property (nonatomic, strong) id item;
@property (nonatomic, strong) NSMutableString *itemTemplate;
@property (nonatomic, strong) NSURL *shareURL;
@property (nonatomic, strong) NSString *shareTitle;

- (id)initWithItem:(id)item;

@end
