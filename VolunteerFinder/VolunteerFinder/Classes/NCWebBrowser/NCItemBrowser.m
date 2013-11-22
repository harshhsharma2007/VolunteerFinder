//
//  NCItemBrowser.m
//  VolunteerFinder
//
//  Created by Brandon Jones on 11/18/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import "NCItemBrowser.h"
#import "Opp.h"

@interface NCItemBrowser ()
- (void)setValue:(NSString *)value forPlaceholder:(NSString *)placeholder;
@end

@implementation NCItemBrowser

- (id)initWithItem:(id)item
{
    self = [super init];
    if (self) {
        
        //get the item
        [self setItem:item];
        
        //check the item type and load the appropriate html
        if (self.item && [self.item  isKindOfClass:[Opp class]]) {
            
            //FeedItem
            //setup the template
            Opp *oppItem = (Opp *)self.item;
            NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"FeedItemTemplate" ofType:@"html"];
            [self setItemTemplate:[NSMutableString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL]];
            [self setValue:oppItem.title forPlaceholder:@"title"];
            [self setValue:oppItem.desc forPlaceholder:@"content"];
            
            //setup share values
            [self setShareTitle:oppItem.title];
            [self setShareURL:[NSURL URLWithString:@"www.google.com"]];
            
            //show the item
            [self loadHTMLString:self.itemTemplate];
            
        }
        
    }
    return self;
}

- (void)loadView
{
    //don't show the toolbar and use a separate in-app browser for links
    [self setHideToolbar:YES];
    [self setOpenLinksInNewBrowser:YES];
    
    [super loadView];
}

#pragma mark - sharing

//share the current web page
- (void)share
{
    //use the special share items if we have them
    if (self.shareURL) {
        [self shareURL:self.shareURL withTitle:self.shareTitle];
    } else {
        [super share];
    }
}

#pragma mark - helpers

//used to replace template palceholders with values
- (void)setValue:(NSString *)value forPlaceholder:(NSString *)placeholder
{
	//if the value is nil, use an empty string instead
	if (!value) {
		value = @"";
	}
	
	//replace the {mustache} tag
	[self.itemTemplate replaceOccurrencesOfString:[NSString stringWithFormat:@"{%@}", placeholder] withString:value options:NSLiteralSearch range:NSMakeRange(0, [self.itemTemplate length])];
}

@end
