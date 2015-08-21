//
//  ResultTableViewController.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "ResultTableViewController.h"


@interface ResultTableViewController ()

@end

@implementation ResultTableViewController
@synthesize results,isSimResults;
- (void)viewDidLoad {
    //test isbn in database->9780345527264
    //test isbn not in database->9780698138322
    //test isbn not in database but diff isbn for same book is->3423141824->9780345527288
    [super viewDidLoad];
    self.navigationItem.title=@"Results";
    UIBarButtonItem *saveAllButton = [[UIBarButtonItem alloc]
    initWithTitle:@"Save All"style:UIBarButtonItemStylePlain
    target:self action:@selector(getSection)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.rightBarButtonItem = saveAllButton;
    [self.navigationController.navigationBar.layer setBorderColor:[[UIColor libraryLight] CGColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 function-getSection
 params-none
 description-An alert view that asks the user to input a section title they would like to save the results under in their SavedListTable
 */
-(void)getSection{
    self.insertNameAlert = [[UIAlertView alloc] initWithTitle:@"Save Results" message:@"To organize your saved list you may enter a section name you would like to store these results under (ex: Course Title, Book Subject/Author, Research Topic) :" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    self.insertNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[self.insertNameAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeAlphabet];
    [self.insertNameAlert show];
}
/*
 function-alertView clickedButtonAtIndex
 params-UIAlertView, NSInteger
 description-Called when a button on an alertview is pressed. If button index is 1 saving of results begins in a background thread and showActivityViewer is called
 */
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        [NSThread detachNewThreadSelector: @selector(saveThread) toTarget:self withObject:nil];
        [self showActivityViewer];
    }
}
/*
 function-saveThread
 params-none
 description-A thread is made so that the save function can process separately from the main thread and push an alert to the main thread telling the user if the results were saved successfully or not
 */
-(void)saveThread{
    UITextField *newSectionField=[self.insertNameAlert textFieldAtIndex:0];
    NSString *newSection=newSectionField.text;
    BOOL didSave=[self save:newSection];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(didSave) {
            [self successAddAlert];
        }else{
            [self failAddAlert];
        }
    });
}
/*
 function-showActivityViewer
 params-none
 description-a view is added to the result table covering it fully with an activity indicator to show the user they must wait while a process is happening
 */
-(void)showActivityViewer
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   
    self.activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    self.activityView.backgroundColor = [UIColor blackColor];
    self.activityView.alpha = 0.5;
    
    UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(screenRect.size.width / 2 - 12, screenRect.size.height / 2 - 12, 24, 24)];
    activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin);
    [self.activityView addSubview:activityWheel];
    [self.tableView addSubview: self.activityView];
    
    [[[self.activityView subviews] objectAtIndex:0] startAnimating];
}
/*
 function-hideActivityViewer
 params-none
 description-Everything that is turned on showActivityViewer is turned off
 */
-(void)hideActivityViewer
{
    [[[self.activityView subviews] objectAtIndex:0] stopAnimating];
    [self.activityView removeFromSuperview];
    self.activityView = nil;
}
/*
 function-save
 params-NSString section
 description-Save class functions are called to update the savedBooksDict.plist with the new book to be saved
 */
-(BOOL) save:(NSString*)sectionName{
    self.saver=[[Save alloc]init];
    self.savedListPath=[self.saver loadSavedBooksFilePath:self.savedListPath];
    return [self.saver saveItems:sectionName :self.results :self.savedListPath];
       
}
/*
 function-sectionAddAlert
 params-none
 description-An alert to let the user know their book has been saved successfully
 */
-(void)successAddAlert{
    [self hideActivityViewer];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"All results have been saved. To view click the \"Saved Books\" tab."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
/*
 function-failAddAlert
 params-none
 description-An alert to let the user know their book has not been saved successfully
 */

-(void)failAddAlert{
    [self hideActivityViewer];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh No!" message:@"Something went wrong and we could not add your results to your \"Saved Books\""delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    
    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // Return the number of rows in the section
    return [self.results count];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 150)];
    [wrapper setBackgroundColor:[UIColor libraryTan]];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    [textLabel setFont:[UIFont systemFontOfSize:11]];
    if(isSimResults){
        textLabel.text=[NSString stringWithFormat:@" \"%@\" Not Found, Showing related items/editions:",self.query];
    }else{
        textLabel.text=[NSString stringWithFormat:@" Showing results for \"%@\":",self.query];
    }

    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [textLabel setNumberOfLines:0];
    [wrapper addSubview:textLabel];
    return wrapper;
}
//changes height of cell dynamically dependeing on height of text inside
-(CGFloat)heightForText:(NSString *)str width:(int)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode) lineBreakMode
{
    CGSize textSize;
    textSize = [str boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return textSize.height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Result *currBook = self.results[indexPath.row];
    return [self heightForText:currBook.fullTitle width:300 font:[UIFont systemFontOfSize:16.0] lineBreakMode:0]+30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"resultCell"];
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"resultCell"];
    }

    Result *book=self.results[indexPath.row];
    cell.textLabel.text=book.title;
    
    cell.detailTextLabel.text=book.subTitle;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"resultDetails"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Result *bookClicked=self.results[indexPath.row];
        [[segue destinationViewController] setBook:bookClicked];
        [[segue destinationViewController] setSeggedFrom:@"result"];
        
    }
}
@end
