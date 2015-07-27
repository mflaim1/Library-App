//
//  webViewController.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/30/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()

@end

@implementation webViewController
@synthesize url,webPage;
/*
 function-viewDidLoad
 params-UIWebView webView
 description-when the view is loaded the url for the webview is requested
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSThread detachNewThreadSelector: @selector(showActivity) toTarget:self withObject:nil];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: self.url]];
    
    [self.webPage loadRequest: request];
    

}
/*
 function-webViewDidFinishLoad
 params-UIWebView webView
 description-when webview is finished loading the activity indicator is hidden
 */

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.loadIndicator.hidden=YES;
    [self.loadIndicator stopAnimating];

}
                             
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 function-showActivity
 params-none
 description-Shows activity indicator while webpage is loading
 */

-(void)showActivity{
    self.loadIndicator.hidden=NO;
    [self.loadIndicator startAnimating];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
