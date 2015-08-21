//
//  ScanViewController.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
/*  scanner source:  http://www.infragistics.com/community/blogs/torrey-betts/archive/2013/10/10/scanning-barcodes-with-ios-7-objective-c.aspx
 */


#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BookDetailViewController.h"
#import "Search.h"
#import "ResultTableViewController.h"
#import "Reachability.h"
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
}

  @end

@implementation ScanViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.searcher=[[Search alloc]init];
    self.results=[[NSMutableArray alloc]init];
    self.navigationItem.title=@"Scan Book Barcode";
    
    
}

-(void)setColors{
    UIColor *blue=[UIColor colorWithRed:((float)((0x360000 & 0xFF0000) >> 16))/255.0 \
    green:((float)((0x009800 & 0x00FF00) >>  8))/255.0 \
    blue:((float)((0x0000BF & 0x0000FF) >>  0))/255.0 \
                                  alpha:1.0];
    UIColor *light=[UIColor colorWithRed:((float)((0xEF0000 & 0xFF0000) >> 16))/255.0 \
    green:((float)((0x00EF00 & 0x00FF00) >>  8))/255.0 \
    blue:((float)((0x0000EF & 0x0000FF) >>  0))/255.0 \
                                   alpha:1.0];
    self.navigationController.navigationBar.barTintColor = light;

    [self.navigationController.navigationBar.layer setBorderWidth:2.0];// Just to make sure its working
    [self.navigationController.navigationBar.layer setBorderColor:[blue CGColor]];
    
}


/*
 function-viewDidAppear
 params-animated BOOL
 description-when the view appears,scanner is set up so a barcode can be located and scanned
 */
- (void)viewDidAppear:(BOOL)animated {
    [self setColors];
    [super viewDidAppear:animated];
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    /*if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        [self viewDidLoad];
        [self viewDidAppear:YES];
    }*/
    
}
/*
 function-captureOutput
 params-AVCaptureOutput, NSArray, AVCaptureConnection
 description-sets up camera so it can detect a lto fo different types of barcodes and grab the information from them
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        NSLog(@"%@",detectionString);
        if (detectionString != nil)
        {
            _label.text = detectionString;
            [_session stopRunning];
            break;
        }
        else{
            _label.text = @"(none)";
            [_session stopRunning];
            break;
        }
    }
    
    _highlightView.frame = highlightViewRect;
   
    //search for isbn just grabbed from barcode
    if ([self.searcher checkConnection]== NotReachable) {
        [self failSearchAlert:@"There is no internet connection"];
    }if([_label.text isEqual:@"(none)"]){
        [self failSearchAlert:@"Barcode could not be read. Please try again and be sure to hold your camera steady"];
        [_session startRunning];
    }else{
        NSLog(@"1");
        [self startSearch:_label.text];
            
    }
    
}
-(void)failSearchAlert:(NSString*) errorMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
-(void)startSearch:(NSString*)isbn{
    NSLog(@"2");
    self.searcher.query=isbn;
    self.searcher.queryType=@"isbn";
    [self.searcher search];
    self.results=self.searcher.results;
    if(self.searcher.didConnect==YES){
        if([self.results count]>0){
            NSLog(@"3");
            [self performSegueWithIdentifier:@"scanResults" sender:self];
        }else{
            NSLog(@"4");
            [self startSimSearch];
        }
    }else{
        NSLog(@"5");
        [self slowConnection];
    }
    
}
/*
 function-startSimSearch
 params-none
 description-Search class functions are called to find similair editions or books with common subjects to an isbn query. View seques to ResultTableView when done.
 */

-(void)startSimSearch{
    NSLog(@"6");
    [self.searcher findEditions];
    [self.results addObjectsFromArray:self.searcher.editionsResults];
    
    [self.searcher findSimilair];
    [self.results addObjectsFromArray:self.searcher.subjectResults];
    if([self.results count]>0){
        [self performSegueWithIdentifier:@"showSimilair" sender:self];
    }else{
        [self performSegueWithIdentifier:@"scanResults" sender:self];
    }

}
/*
 function-slowConnection
 params-none
 description-Everything turned on if showActivity is turned off and an alert is called to tell user the connection was too slow to find results
 */
-(void)slowConnection{
    [self.searchIndicator stopAnimating];
    self.searchIndicator.hidden=YES;
    
    [self failSearchAlert:@"Connection is too slow. Results could not be obtained"];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.searchIndicator.hidden=YES;
    [self.searchIndicator stopAnimating];
    if([segue.identifier isEqual:@"scanResults"]){
        if([self.results count]>0){
            
            Result* book=self.results[0];
            [[segue destinationViewController] setBook:book];
        }else{
            Result* book=[[Result alloc]init];
            book.fullTitle=[NSMutableString stringWithString:@"Book Not Found"];
            [[segue destinationViewController] setBook:book];
        }
        
    }
    if([segue.identifier isEqual:@"showSimilair"]){
        
        [[segue destinationViewController] setResults:self.results];
        [[segue destinationViewController] setIsSimResults:YES];
        
        [[segue destinationViewController] setQuery:_label.text];
    }

}


@end










