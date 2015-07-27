//
//  webViewController.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/30/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (strong) NSString* url;
@end
