//
//  SavedListTableViewController.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/5/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Search.h"
#import "Save.h"
@interface SavedListTableViewController : UITableViewController
@property (strong,nonatomic) NSString* savedBooksPath;
@property (strong,nonatomic) NSDictionary* plistMainDict;
@property (strong,nonatomic) NSDictionary* currBook;
@property (strong,nonatomic) NSArray* plistSaveSections;
@property (strong) Save* saver;

@end
