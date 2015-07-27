//
//  Search.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/9/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "Search.h"
#import "TFHpple.h"
#import "Reachability.h"
NSString* noCover=@"http://jonathanwoodauthor.com/wp-content/uploads/2013/10/noCoverArt.gif";
NSString* cd=@"http://www.clker.com/cliparts/D/O/1/I/0/8/cd-icon-md.png";
@implementation Search
/*
 function- checkConnection
 params-none
 return-NetworkStatus
 description-this calls the Apple Reachability class to check if there is network connection
 */
-(NetworkStatus)checkConnection{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus;

}
/*
 function- checkISBN
 params-(NSUInteger) isbnLength- the length of isbn entered
 return-NSString, check10 or check13 return value or invalid length
 description-if the isbn number has 13 numbers the check13 function is called. if it has 10 numbers the check10 function is called. If it is incorrect length the failSearchAlert function is called
 */
-(NSString*)checkISBN:(NSString*)isbn{
    NSUInteger isbnLength=[isbn length];
    if(isbnLength==13){
        return[self check13:isbn];
    }else if(isbnLength==10){
        return[self check10:isbn];
    }else{
        return @"invalid length";
    }
}
/*
 function-check13
 params-none
 return-NSString, invalid or valid
 description-checks a 13 number isbn to make sure it follows correct pattern for a valid isbn number. Calls failSearchAlert function if it is found to not be valid.
 */
-(NSString*)check13:(NSString*)isbn{
    NSInteger sum=0;
    NSString *numAtI;
    for(NSInteger i = 0; i < 12; i++){
        if(i % 2 == 0) {
            numAtI=[isbn substringWithRange:NSMakeRange(i, 1)];
            sum += [numAtI integerValue];
        } else {
            numAtI=[isbn substringWithRange:NSMakeRange(i, 1)];
            sum += [numAtI integerValue] * 3;
        }
    }
    NSString* numAt12=[isbn substringWithRange:NSMakeRange(12, 1)];
    sum=sum%10;
    sum=10-sum;
    if([numAt12 integerValue] ==sum){
        return @"valid";
    }else{
        return @"invalid";
    }
    
}
/*
 function-check10
 params-none
 return=NSString, invalid or valid
 description-checks a 10 number isbn to make sure it follows correct pattern for a valid isbn number. Calls failSearchAlert function if it is found to not be valid.
 */

-(NSString*)check10:(NSString*) isbn{
    NSInteger sum=0;
    NSString *numAtI;
    for(NSInteger i = 0; i < 10; i++) {
        numAtI=[isbn substringWithRange:NSMakeRange(i, 1)];
        NSInteger numInt=[numAtI integerValue]*(10-i);
        
        sum += numInt;
    }
    sum=sum%11;
    if(0 == sum){
        return @"valid";
    }else{
        return @"invalid";
    }
}
/*
 function-getImageAndDesc
 params-NSString isbn, NSString callNumber,NSString title,NSString location
 return-NSMutableArray, index 0 is image url and index 1 is description
 description-checks if an item is a cd or dvd, if not it calls the function getGoogleImageAndDesc
 */

-(NSMutableArray*)getImageAndDesc:(NSString*)isbn :(NSString*)location :(NSString*)callNumber :(NSString*)title{
    NSMutableArray *returnValues=[[NSMutableArray alloc]init];
    //this means we do not have a book, but a cd or dvd, therefore it should not be searched for in google books
    if([@"Multimedia Services"isEqual:location]||[@"Technical Services" isEqual:location]){
        [returnValues addObject:cd];
        [returnValues addObject:@"No description found"];
        return returnValues;
        
    }else if([isbn isEqual:@"No ISBN Found"]||[callNumber isEqual:@"No Call Number Found"]||[callNumber isEqual:@"Electronic book"]){

        [returnValues addObject:noCover];
        [returnValues addObject:@"No description found"];
        return returnValues;
        //this means the book can be searched with google books api
    }else{

        return[self getGoogleImageAndDesc:isbn:title];
    }
    
    
}
/*
 function-accessGoogleAPI
 params-NSString isbn
 return-NSDictionary, json googleAPI result
 description-searches the google book api for an isbn and return results
 */
-(NSDictionary*)accessGoogleAPI:(NSString*)isbn{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //isbn=[isbn stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=%@",isbn];
    
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data options:kNilOptions error:&error];
    return json;
    
}
/*
 function-getGoogleImageAndDesc
 params-NSString isbn,NSString title
 return-NSMutableArray, index 0 is image url and index 1 is description
 description-calls the accessGoogleAPI function and tries to get the image url and description from the first result if it is the right item
 */
-(NSMutableArray*)getGoogleImageAndDesc:(NSString*)isbn :(NSString*)title{
    NSMutableArray *returnValues=[[NSMutableArray alloc]init];
    NSDictionary *json=[self accessGoogleAPI:isbn];
    
    NSString* lowTitle=[title lowercaseString];
    NSString* lowResultTitle=[json[@"items"][0][@"volumeInfo"][@"title"] lowercaseString];
    //if searched isbn matches 1st results 13 isbn or if 1st results title is in searched books title (validating that this is correct book)

    if(json[@"items"][0][@"volumeInfo"][@"industryIdentifiers"][0][@"identifier"]){
        
        if([isbn isEqual:json[@"items"][0][@"volumeInfo"][@"industryIdentifiers"][0][@"identifier"]]||[lowResultTitle containsString:lowTitle]||[lowTitle containsString:lowResultTitle]){

            self.imageURL=json[@"items"][0][@"volumeInfo"][@"imageLinks"][@"thumbnail"];
            self.bookDesc=json[@"items"][0][@"volumeInfo"][@"description"];
            
        }else{
            //if reaches else then result was not the correct book
            self.imageURL=noCover;
            self.bookDesc=@"No Description Found";
            
        }
    }else{
        //this will be if google search came up with no results
        self.imageURL=noCover;
        self.bookDesc=@"No Description Found";
        NSLog(@"%@",self.imageURL);
    }
    //this will be true if the google search result did not have a picture
    if(!self.imageURL){

        self.imageURL=noCover;
    }
    if(!self.bookDesc){
        self.bookDesc=@"No Description Found";
    }
    
    [returnValues addObject:self.imageURL];
    [returnValues addObject:self.bookDesc];
    return returnValues;
}
/*
 function-findSubjects
 params-NSString isbn
 description-this searches for a book with a library of congress api to get its subjects. It then searches for each subject in the library database and adds the results to a list
 */
-(void)findSubjects:(NSString*)isbn{
    self.subjects=[[NSMutableArray alloc]init];
    self.subjectResults=[[NSMutableArray alloc]init];
    self.simScores=[[NSMutableDictionary alloc]init];
    NSString *subjectsLink=[NSString stringWithFormat:@"http://lx2.loc.gov:210/lcdb?version=1.1&operation=searchRetrieve&query=bath.isbn=%@&maximumRecords=1&recordSchema=mods",isbn];
    
    NSData *xmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:subjectsLink]];
    
    //Instantiate our NSXMLParser with the generated URL
    self.parser = [[NSXMLParser alloc]initWithData:xmlData];
    [self.parser setDelegate:self];
    [self.parser parse];
    self.simScores=[[NSMutableDictionary alloc]init];
    self.queryType=@"subject";
    if(self.subjects){
        for(NSString* subject in self.subjects){
            NSString *subjectNoQuotes = [subject
            stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            self.query=subjectNoQuotes;
            [self search];
            [self.subjectResults addObjectsFromArray:self.results];
        }
    }
    
}
/*
 function-findSimilair
 params-none
 description-calls findSubjects, goes through the list of subject results and figures out which same results came up for multiple subject searches. Creates a dictionary with the key as the result isbn and the value as an integer representing how many times that result came up in the subject searches
 */
-(void)findSimilair{
    [self findSubjects:self.query];
    if([self.subjectResults count]>0){
        for(Result* result in self.subjectResults){
            if(self.simScores[result.isbn]){
                NSNumber *value=self.simScores[result.isbn];
                NSInteger intValue=[value intValue];
                value = [NSNumber numberWithInt:intValue+1];
                [self.simScores setObject:value forKey:result.isbn];
            }else{
                NSNumber *value=[NSNumber numberWithInt:1];
                [self.simScores setObject:value forKey:result.isbn];
            }
        }
        [self getTopSim];
        NSMutableArray *toDelete=[[NSMutableArray alloc]init];
        for(Result *edition in self.editionsResults){
            for(Result *simBook in self.subjectResults){
                if ([edition.isbn isEqual:simBook.isbn]){
                    [toDelete addObject:simBook];
                }
            }
        }
        [self.subjectResults removeObjectsInArray:toDelete];
    }
    
}
/*
 function-getTopSim
 params-none
 description-finds which subject results showed up in a third of the original books subject searches and uses them as final results to segue with
 */
-(void)getTopSim{
    self.queryType=@"isbn";
    self.subjectResults=[[NSMutableArray alloc]init];
    [self.simScores removeObjectForKey:@"No ISBN Found"];
    for(NSString *isbn in self.simScores){
        NSInteger score=[self.simScores[isbn] integerValue];
        if(score>([self.subjects count]/3)){
            self.query=isbn;
            [self search];
            
            [self.subjectResults addObjectsFromArray:self.results];
        }
    }
}
/*
 function-findEditions
 params-none
 description-searches worldcat API for different editions of a specific book then searches for those editions in the library database and adds it to final results to seque if it is there.
 */
-(void)findEditions{
    self.editionsISBNS=[[NSMutableArray alloc]init];
    self.editionsResults=[[NSMutableArray alloc]init];
    NSString *editionsLink=[NSString stringWithFormat:@"http://xisbn.worldcat.org/webservices/xid/isbn/%@?method=getEditions&format=xml&fl=form,year,lang,ed,title",self.query];
    
    NSData *xmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:editionsLink]];
   
    //Instantiate our NSXMLParser with the generated URL
    self.parser = [[NSXMLParser alloc]initWithData:xmlData];
    [self.parser setDelegate:self];
    [self.parser parse];
       self.queryType=@"isbn";
       for(NSString* edition in self.editionsISBNS){
        self.query=edition;
        [self search];
        if([self.results count]>0){
            [self.editionsResults addObjectsFromArray:self.results];
        }
    }
    
}/*
  function-cleanTitle
  params-none
  description-remove 'a' and 'the' from the title query to get better search results
  */

-(void)cleanTitle{
    self.query=[self.query lowercaseString];
    self.query=[NSString stringWithFormat:@" %@ ",self.query];
    self.query=[self.query stringByReplacingOccurrencesOfString:@" a " withString:@" "];
    self.query=[self.query stringByReplacingOccurrencesOfString:@" the " withString:@" "];
    self.query=[self.query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}
/*
 function-search
 params-none
 description-searches the library database for a specific query and search type and then starts to parse the resulting xml
 */
-(void)search{
    self.didConnect=NO;
    //Generate URL string to query the Ithaca College Library
    self.query=[self.query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    self.query=[self.query stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    self.results=[[NSMutableArray alloc]init];
    NSString *baseURL=@"http://phoebe.ithaca.edu:7014/vxws/SearchService?searchCode=%@&maxResultsPerPage=25&recCount=25&searchArg=%@";
    NSString *url_string;
    
    if([self.queryType isEqualToString:@"isbn"]){
        url_string = [NSString stringWithFormat:baseURL,@"isbn",self.query];
    }else if([self.queryType isEqualToString:@"title"]){
        [self cleanTitle];
        url_string = [NSString stringWithFormat:baseURL,@"TALL",self.query];
    }else if([self.queryType isEqualToString:@"key"]){
        url_string = [NSString stringWithFormat:baseURL,@"GKEY",self.query];
    }else if([self.queryType isEqualToString:@"subject"]){
        url_string = [NSString stringWithFormat:baseURL,@"SKEY",self.query];
    }
    else if([self.queryType isEqualToString:@"author"]){
        url_string = [NSString stringWithFormat:baseURL,@"NKEY",self.query];
    }
    //Convert url_string to NSURL to pass as a parameter into our XML parser
    
    NSData *xmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url_string]];
    if(xmlData){
        self.didConnect=YES;
    }
    //Instantiate our NSXMLParser with the generated URL
    self.parser = [[NSXMLParser alloc]initWithData:xmlData];
    
    [self.parser setDelegate:self];
    [self.parser parse];
}



// MARK: – NSXMLParserDelegate methods
// http://rshankar.com/blogreader-app-in-swift/

/**
 * @description - First stage of parsing. Set the name to the current element being parsed from the XML document.
 *   if the name is equal to "sear:result", create a new Result object instance to populate as we parse the XML document
 *
 * @returns     - [void]
 *
 */
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
attributes: (NSDictionary *)attributeDict
{      //Holding on to the element name state within the controller class for future referencing
    self.name=elementName;
    //Create a new Result object instance to populate as we parse the XML document
    if ([self.name isEqualToString:@"sear:result"]){
        self.currResult=[[Result alloc]init];
        self.currResult.fullTitle=[NSMutableString stringWithString:@""];
    }
}
/**
 * @description - Intermediary stage of parsing. This method is where we gather any information that is to be displayed
 *   and append it to the current result.
 * @params      - [NSXMLParser] parser
 *              - [String?] foundCharacters : characters found in the current element
 * @returns     - [void]
 */
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *data = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([data length]!=0) {
        //tags in library database
        if ([self.name isEqualToString:@"sear:bibText2"]){
            if([self.queryType isEqualToString:@"isbn" ]||[self.queryType isEqualToString:@"author"]){
                [self.currResult.fullTitle appendString:data];
                
            }
        } else if([self.name isEqualToString:@"sear:callNumber"]){
            self.currResult.callNumber = data;
        }else if([self.name isEqualToString:@"sear:isbn"]){
            NSArray *dataArr=[data componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.currResult.isbn=dataArr[0];
        }else if([self.name isEqualToString:@"sear:bibText1"]){
            if(![self.queryType isEqualToString:@"isbn" ]&&![self.queryType isEqualToString:@"author"]){
                [self.currResult.fullTitle appendString:data];
                
            }
        }else if([self.name isEqualToString:@"sear:bibId"]){
            self.currResult.bibId=data;
        }else if([self.name isEqualToString:@"sear:locationName"])
        {
            self.currResult.location=data;
        //tag for worldcat api
        }else if([self.name isEqualToString:@"sear:mfhdCount"]){
            self.currResult.holdings=data;
        }else if([self.name isEqualToString:@"isbn"]){
            [self.editionsISBNS addObject:data];
        //tags for library of congress api
        }else if([self.name isEqualToString:@"namePart"]){
            [self.subjects addObject:data];
        }else if([self.name isEqualToString:@"topic"]){
            [self.subjects addObject:data];
        }else if([self.name isEqualToString:@"geographic"]){
            [self.subjects addObject:data];
        }else if([self.name isEqualToString:@"genre"]){
            [self.subjects addObject:data];
        }
    }
                 
}

/**
 * @description - Final stage of parsing. If the elementName is "sear:result", that means we reached the end of the result element.
 *   Once we reach the end of the result element, we append a pointer to the result object we created to an array containing all results.
 * @returns     - [void]
 */
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    //Append a pointer to our currentResult instance to the results array
    if( [elementName isEqualToString:@"sear:result"])
    {   if([self.currResult.holdings integerValue]>1){
            self.currResult.callNumber=@"Multiple Holdings";
        }
        if(!self.currResult.isbn){
            self.currResult.isbn=@"No ISBN Found";
        }if(!self.currResult.callNumber){
            self.currResult.callNumber=@"No Call Number Found";
        }if(!self.currResult.location){
            self.currResult.location=@"No Location Found";
        }
        [self splitTitle];
        [self.results addObject:self.currResult];

    }
    
    
    
}
/*
 function-splitTitle
 params-none
 description-splits up the title grabbed from the xml into the main title and subtitle
 */
-(void)splitTitle{
    NSArray *cellTitles1=[[NSArray alloc]init];
    NSArray *cellTitles2=[[NSArray alloc]init];
    cellTitles1=[self.currResult.fullTitle componentsSeparatedByString:@":"];
    if([cellTitles1 count]>1){
        self.currResult.title=cellTitles1[0];
        self.currResult.subTitle=cellTitles1[1];
    }else{
        cellTitles2=[self.currResult.fullTitle componentsSeparatedByString:@"/"];
        self.currResult.title=cellTitles2[0];
        if([cellTitles2 count]>1){
            self.currResult.subTitle=cellTitles2[1];
        }else{
            self.currResult.subTitle=@"no subtitle";
        }
    }

}
@end