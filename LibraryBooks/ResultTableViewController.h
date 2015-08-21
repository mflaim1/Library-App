//
//  ResultTableViewController.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Result.h"
#import "Search.h"
#import "Save.h"
#import "BookDetailViewController.h"
#import "UIColor+LibraryColors.h"

@interface ResultTableViewController : UITableViewController
@property (strong) UIView *activityView;
@property (strong, nonatomic) UIAlertView *insertNameAlert;
@property (nonatomic,strong) NSMutableArray* results;
@property (strong) Save* saver;
@property (nonatomic,strong) NSString* savedListPath;
@property BOOL isSimResults;
@property (strong) NSString *query;
@end
