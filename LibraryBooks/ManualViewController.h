//
//  ManualViewController.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor+LibraryColors.h"
#import "ResultTableViewController.h"
#import "Search.h"
#import "Reachability.h"

@interface ManualViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *query;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (strong) NSString *typeSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;
@property (strong) NSMutableArray* results;
@property (strong) Search* searcher;
@property (weak, nonatomic) IBOutlet UILabel *noneFoundLabel;
@property BOOL isSimResults;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchIndicator;
@property (weak, nonatomic) IBOutlet UITextView *grayBackground;




@end
