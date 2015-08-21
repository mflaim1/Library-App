//
//  ManualViewController.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "ManualViewController.h"


@implementation ManualViewController
@synthesize typeSelected,noneFoundLabel;

/*
 function-viewDidLoad
 params-none
 description-when view loads the navigation title is changed and the segment control is setup
 */
- (void)viewDidLoad {

    [super viewDidLoad];
    self.navigationItem.title=@"Search";
    [self.typeControl addTarget:self action:@selector(setType:) forControlEvents:UIControlEventValueChanged];
    self.results=[[NSMutableArray alloc]init];
    self.searcher=[[Search alloc]init];
}
/*
 function-viewDidAppear
 params-animated BOOL
 description-when the view appears, the isSimResults flag is set to NO and noneFoundLabel is hidden
 */
-(void)viewDidAppear:(BOOL)animated{
    self.noneFoundLabel.hidden=YES;
    self.isSimResults=NO;
    [self setColors];
}
-(void)setColors{
    self.navigationController.navigationBar.barTintColor = [UIColor libraryLight];
    self.view.backgroundColor=[UIColor libraryTan];
    self.searchButton.layer.borderWidth = 1.0f;
    self.searchButton.layer.borderColor =[UIColor libraryBlue].CGColor;
    self.searchButton.layer.cornerRadius = 4.0f;
    
    [self.navigationController.navigationBar.layer setBorderWidth:2.0];// Just to make sure its working
    [self.navigationController.navigationBar.layer setBorderColor:[[UIColor libraryBlue] CGColor]];
    [self.tabBarController.tabBar setBarTintColor:[UIColor libraryLight]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* 
 function-backgroundTap
 params-sender
 description-when background of view is tapped while keyboard is open the keyboard is closed, if it is not open the seg control is reset to nothing being selected
 */
- (IBAction)backgroundTap:(id)sender {
    
    if([self.query isFirstResponder]==YES){
        [self.query resignFirstResponder];
    }else{
        [self.typeControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        self.typeSelected=nil;
    }

}

/*
 function-textFieldDoneEditing
 params-sender
 description-creates done button on keyboard so it can be closed when user is done typing
*/
- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}
/*
 function-seachPressed
 params-sender
 description-when search button is pressed the query is validated. If it is an isbn search the checkISBN function is called. If the query is empty the failSearchAlert function is called. Anything else the startSearch function is called
 */
- (IBAction)searchPressed:(UIButton *)sender {
    
    if([self.typeSelected isEqualToString:@"isbn"]){
        self.query.text=[self.query.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.query.text=[self.query.text stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];
        [self validateISBN];
    
    }else if([self.query.text isEqual:@""]){
        [self searchAlert:@"Please enter a query in order to search"];
    }else{
        if ([self.searcher checkConnection]== NotReachable) {
            [self searchAlert:@"There is no internet connection"];
        } else {
            [self startSearch];
        }
        
    }
}
/*
 function-validateISBN
 params-none
 description-sends the isbn number being searched into a Search class function to be validated. Gives appropriate error messages if it is invalid or startSearch is called if it is valid.
 */
-(void)validateISBN{
    NSString *error;
    NSString* result=[self.searcher checkISBN:self.query.text];
    if([result isEqual:@"valid"]){
         [self startSearch];
    }else if([result isEqual:@"invalid"]){
        error=@"ISBN is not valid, please check your input and try again";
        [self searchAlert:error];
    }else{
        error=@"ISBN is not correct length, it must be 13 or 10 numbers long";
        [self searchAlert:error];
        
    }
}
/*
 function-showActivity
 params-none
 description-unhides a view to cover the whole view controller and starts an activity indicator to show that the database is being searched and the user should wait.
 */
-(void)showActivity{
    self.searchIndicator.hidden=NO;
    [self.searchIndicator startAnimating];
    self.grayBackground.hidden=NO;
}

/*
 function-startSearch
 params-none
 description-the search class is called and the database is searched for query, If there are no search results for a non-isbn query noResultsFound is called,if there are no results for an isbn query startSimSearch is called, if there are results the view segues to ResultTableView, if the connection is too slow to pull results slowConnection is called
 */
-(void)startSearch{
    [NSThread detachNewThreadSelector: @selector(showActivity) toTarget:self withObject:nil];
    self.searcher.query=self.query.text;
    if(self.typeSelected==nil){
        self.typeSelected=@"key";
    }
    self.searcher.queryType=self.typeSelected;
    [self.searcher search];
    if(self.searcher.didConnect==YES){
        self.results=self.searcher.results;
        if([self.results count]<1){
            if([self.typeSelected isEqual:@"isbn"]){
                
                [self startSimSearch];
            }else{
                [self noResultsFound];
            }
        }else{
            self.noneFoundLabel.hidden=YES;
            [self performSegueWithIdentifier:@"manualSearched" sender:self];
        }
    }else{
        [self slowConnection];
    }
}
/*
 function-startSimSearch
 params-none
 description-Search class functions are called to find similair editions or books with common subjects to an isbn query. If results are found view seques to ResultTableView, if there are still no results noResultsFound is called.
 */
-(void)startSimSearch{
    self.searcher.query=self.query.text;
    [self.searcher findEditions];
    [self.results addObjectsFromArray:self.searcher.editionsResults];
    
    [self.searcher findSimilair];
    [self.results addObjectsFromArray:self.searcher.subjectResults];
    if([self.results count]>0){
        self.isSimResults=YES;
        [self performSegueWithIdentifier:@"manualSearched" sender:self];
    }else{
        
        [self noResultsFound];
    }

}
/*
 function-slowConnection
 params-none
 description-Everything turned on in showActivity is turned off and an alert is called to tell user the connection was too slow to find results
 */
-(void)slowConnection{
    
    [self searchAlert:@"Connection is too slow. Results could not be obtained"];
    [self.searchIndicator stopAnimating];
    self.searchIndicator.hidden=YES;
    self.grayBackground.hidden=YES;
}
/*
 function-noResultsFound
 params-none
 description-Everything turned on in showActivity is turned off and a label above the search bar is truend on to tell the user there were no results for their query
 */
-(void)noResultsFound{
    [self.searchIndicator stopAnimating];
    self.searchIndicator.hidden=YES;
    self.grayBackground.hidden=YES;
    self.noneFoundLabel.text=[NSString stringWithFormat:@"No Results Found For Query:'%@'",self.query.text];
    self.noneFoundLabel.hidden=NO;
}
/*
 function-searchAlert
 params-NSString* errorMessage-message to be displayed in view
 description-displays pop up alert to user to alert them that something has gone wrong in the view
 */
-(void)searchAlert:(NSString*) errorMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
/*
 function-setType
 params-sender
 description-Depending on which part of the segment is pressed the typeSelected data member is changed to the corresponding string for the query type
 */
- (IBAction)setType:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.typeSelected=@"subject";
            break;
        case 1:
            self.typeSelected=@"author";
            [self searchAlert:@"For optimum results please enter an author search with the format: \'last, first\' "];
            break;
        case 2:
            self.typeSelected=@"title";
            break;
        case 3:
            self.typeSelected=@"isbn";
            break;
    }
}

#pragma mark - Navigation
//results sent to ResultTableView
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.searchIndicator stopAnimating];
    self.searchIndicator.hidden=YES;
    self.grayBackground.hidden=YES;
    if([segue.identifier isEqual:@"manualSearched"]){
        
        [[segue destinationViewController] setResults:self.results];
        [[segue destinationViewController] setIsSimResults:self.isSimResults];
        [[segue destinationViewController] setQuery:self.query.text];
    }
}
@end
