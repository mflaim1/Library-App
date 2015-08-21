//
//  SavedListTableViewController.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/5/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "SavedListTableViewController.h"

@interface SavedListTableViewController ()

@end

@implementation SavedListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor libraryLight];

}
-(void)viewDidAppear:(BOOL)animated {
    self.saver=[[Save alloc]init];
    self.savedBooksPath=[self.saver loadSavedBooksFilePath:self.savedBooksPath];
    [self.tableView reloadData];
    
    self.plistMainDict= [NSMutableDictionary dictionaryWithContentsOfFile:self.savedBooksPath];
    self.plistSaveSections = [[self.plistMainDict allKeys]sortedArrayUsingSelector:
                              @selector(compare:)];
    
    self.navigationItem.title=@"Saved";
    
    if(![self.plistSaveSections count]==0){
            [self setUpNavButtons];
    }else{
        self.navigationItem.leftBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem=nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
/*
 function-setUpNavButtons
 params-none
 description-sets up the navigation bar
 */
-(void)setUpNavButtons{
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
    
    UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc]
    initWithTitle:@"Delete All"style:UIBarButtonItemStylePlain
    target:self action:@selector(deleteAllVerify)];
    self.navigationItem.rightBarButtonItem = deleteAllButton;

}
/*
 function-deleteAllVerify
 params-none
 description-Alert view to let the user know they have click to "delete all" button and to verify that is what they want
 */
-(void)deleteAllVerify{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete All" message:@"Continuing with this action will delete all sections and books from your Saved List. Please verify that this is what you would like to do."delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete All", nil];
    [alert show];
    
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        [self deleteAll];
    }
}
-(void)deleteAll{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.savedBooksPath];
    
    [dict removeAllObjects];
    
    [dict writeToFile:self.savedBooksPath atomically:YES];
    
    [self viewDidAppear:YES];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.plistSaveSections count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    NSString *currSection = self.plistSaveSections[section];
    NSArray *booksInSection = self.plistMainDict[currSection];
    return [booksInSection count];
}
-(NSString*)tableView: (UITableView*)tableView titleForHeaderInSection: (NSInteger)section {
    return self.plistSaveSections[section];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font=[UIFont systemFontOfSize:(11)];    
    view.tintColor = [UIColor libraryTan];
    
}
-(CGFloat)heightForText:(NSString *)str width:(int)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode) lineBreakMode
{
    CGSize textSize;
    textSize = [str boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return textSize.height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    
    return [self heightForText:self.currBook[@"fullTitle"] width:300 font:[UIFont systemFontOfSize:16.0] lineBreakMode:0]+25;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"saveCell" forIndexPath:indexPath];
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"saveCell"];
    }

    NSString *currSection = self.plistSaveSections[indexPath.section];
    NSArray *booksInSection = self.plistMainDict[currSection];
    self.currBook=booksInSection[indexPath.row];
    cell.textLabel.text=self.currBook[@"title"];
    
    cell.detailTextLabel.text=self.currBook[@"subTitle"];

    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSString *sectionTitle = self.plistSaveSections[indexPath.section];
        NSArray *sectionContents = self.plistMainDict[sectionTitle];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.savedBooksPath];
        NSMutableArray *arr=dict[sectionTitle];
        [arr removeObject:sectionContents[indexPath.row]];
        if([arr count]==0){
            [dict removeObjectForKey:sectionTitle];
        }else{
            [dict setObject:arr forKey:sectionTitle];
           
        }
        
        [dict writeToFile:self.savedBooksPath atomically:YES];
        
        [self viewDidAppear:YES];
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"saveDetails"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *currSection = self.plistSaveSections[indexPath.section];
        NSArray *booksInSection = self.plistMainDict[currSection];
        NSMutableDictionary *currBook=booksInSection[indexPath.row];
        Result* clickedBook=[[Result alloc]init];
        clickedBook.fullTitle=currBook[@"fullTitle"];
        clickedBook.subTitle=currBook[@"subTitle"];
        clickedBook.title=currBook[@"title"];
        clickedBook.bibId=currBook[@"bibId"];
        clickedBook.callNumber=currBook[@"callNum"];
        clickedBook.imageURL=currBook[@"imageURL"];
        clickedBook.isbn=currBook[@"isbn"];
        clickedBook.desc=currBook[@"description"];
        clickedBook.location=currBook[@"location"];
        [[segue destinationViewController] setBook:clickedBook];
        [[segue destinationViewController] setSeggedFrom:@"save"];
    }
}


@end
