//
//  ScanViewController.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Search.h"
@interface ScanViewController : UIViewController
@property (strong) NSMutableArray* results;
@property (strong) UIActivityIndicatorView *searchIndicator;
@property (strong) Search *searcher;
@property (strong) UIView* navBorder;
@end
