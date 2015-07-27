//
//  BookDetailViewController.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Save.h"
#import "Result.h"
#import "Search.h"
@interface BookDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UIButton *callNum;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadIndicator;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UITextView *noBookView;

@property (strong) Result *book;
@property (strong) NSString* seggedFrom;
@property (strong) NSString *savedListPath;
@property (strong) Save* saver;
@property (strong) Search* searcher;





@end
