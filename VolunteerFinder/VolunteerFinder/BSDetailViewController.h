//
//  BSDetailViewController.h
//  VolunteerFinder
//
//  Created by Brian Singer on 11/19/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
