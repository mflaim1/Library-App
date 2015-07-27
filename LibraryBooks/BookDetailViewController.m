//
//  BookDetailViewController.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "BookDetailViewController.h"
#import "webViewController.h"
@interface BookDetailViewController ()

@end

@implementation BookDetailViewController
//@synthesize status,savedListPath,seggedFrom,imageLoadIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bookTitle.text=self.book.fullTitle;
    [self.callNum setTitle: self.book.callNumber forState: UIControlStateNormal];
    [self setColors];
    [self setUpPage];
    [self startStatusQueue];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) setColors{
    UIColor *light=[UIColor colorWithRed:((float)((0xEF0000 & 0xFF0000) >> 16))/255.0 \
                                   green:((float)((0x00EF00 & 0x00FF00) >>  8))/255.0 \
                                    blue:((float)((0x0000EF & 0x0000FF) >>  0))/255.0 \
                                   alpha:1.0];
    [self.navigationController.navigationBar.layer setBorderColor:[light CGColor]];
}

/*
 function-startStatusQueue
 params-none
 description-A thread is made, so getCurrentStatus can run separately from main thread and update the status label of the view when it is done
 */
-(void)startStatusQueue{
    dispatch_queue_t statusQueue = dispatch_queue_create("Status Queue",NULL);
    dispatch_async(statusQueue, ^{
        NSString *theStatus=[self getCurrentStatus];
        if (!theStatus) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.status.text=theStatus;
        });
        
    });
}
/*
 function-startImageQueue
 params-none
 description-A thread is made, so loadImageAndDesc can run separately from main thread and update the image view of the view when it is done
 */
-(void)startImageQueue{
    dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue",NULL);
    dispatch_async(imageQueue, ^{
        UIImage*theImage=[[UIImage alloc]init];
        
        theImage=[self loadImageAndDesc];
        if(!theImage) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageLoadIndicator.hidden=YES;
            [self.imageLoadIndicator stopAnimating];
            self.bookImageView.image=theImage;
            self.descTextView.text=self.book.desc;
        });
    });
}
/*
 function-getCurrentStatus
 params-none
 description-the status of the book is scraped from the html of the library detail webpage of that book
 */
-(NSString*) getCurrentStatus{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* url=[NSString stringWithFormat:@"http://phoebe.ithaca.edu/vwebv/holdingsInfo?bibId=%@",self.book.bibId];

    [request setURL:[NSURL URLWithString:url]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *token = nil;
    [scanner scanUpToString:@"<span style=\"display:inline\" class=\"subfieldData\">" intoString:NULL];
    [scanner scanUpToString:@"</span>" intoString:&token];
    token=[token stringByReplacingOccurrencesOfString:@"<span style=\"display:inline\" class=\"subfieldData\">" withString:@""];
    return token;
}
/*
 function-loadImageAndDesc
 params-none
 description-Search class functions are called so an image and description for the selected book can appear on the view
 */
-(UIImage*)loadImageAndDesc{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    self.searcher=[[Search alloc]init];
    
    if(!self.book.imageURL||!self.book.desc){
        
        result=[self.searcher getImageAndDesc:self.book.isbn:self.book.location:self.book.callNumber:self.book.title];
        self.book.imageURL=result[0];
        self.book.desc=result[1];
    }
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.book.imageURL]];
    
    return [UIImage imageWithData: imageData];
}
/*
 function-setUpPage
 params-none
 description-This sets up the way the view looks depending on where it segued from and calls appropriate functions to help do so.
 */
-(void)setUpPage{
    if([self.book.fullTitle isEqualToString:@"Book Not Found"]){
         self.noBookView.hidden=NO;
    }else{
        self.imageLoadIndicator.hidden=NO;
        [self.imageLoadIndicator startAnimating];
        [self startImageQueue];
        self.navigationItem.title=@"Details";
        if([self.seggedFrom isEqualToString:@"result"]){
            UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Save"style:UIBarButtonItemStylePlain
            target:self action:@selector(getSection)];
            self.navigationItem.rightBarButtonItem = saveButton;
        }
    }
}
/*
 function-getSection
 params-none
 description-An alert view that asks the user to input a section title they would like to save the book under in their SavedListTable
 */
-(void)getSection{
    UIAlertView *insertNameAlert = [[UIAlertView alloc] initWithTitle:@"Select Saved Section" message:@"Enter a section name you would like to store these results under:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    insertNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [[insertNameAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeAlphabet];
    [insertNameAlert show];
}
/*
 function-alertView clickedButtonAtIndex
 params-UIAlertView, NSInteger
 description-Called when a button on an alertview is pressed. If button index is 1 saving of book begins
 */
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        UITextField *newSectionField=[alertView textFieldAtIndex:0];
        NSString *newSection=newSectionField.text;
        [self save:newSection];
    }
}
/*
 function-save
 params-NSString section
 description-Save class functions are called to update the savedBooksDict.plist with the new book to be saved
 */
-(void)save:(NSString*)section{
    self.saver=[[Save alloc]init];
    Result* resultToSave=[[Result alloc]init];
    resultToSave=self.book;
    
    NSMutableArray *results=[[NSMutableArray alloc]init];
    [results addObject:resultToSave];
    self.savedListPath=[self.saver loadSavedBooksFilePath:self.savedListPath];
    if([self.saver saveItems:section :results :self.savedListPath]){
        [self successAddAlert];
    }else{
        [self failAddAlert];
    }
}
/*
 function-sectionAddAlert
 params-none
 description-An alert to let the user know their book has been saved successfully
 */
-(void)successAddAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"This book has been saved. To view click the \"Saved Books\" tab."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
/*
 function-failAddAlert
 params-none
 description-An alert to let the user know their book has not been saved successfully
 */

-(void)failAddAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh No!" message:@"Something went wrong and we could not add this book to your \"Saved Books\""delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"seeWeb"]){
    
        NSString* url=[NSString stringWithFormat:@"http://phoebe.ithaca.edu/vwebv/holdingsInfo?bibId=%@",self.book.bibId];
        [[segue destinationViewController] setUrl:url];
        
    }

}
@end
