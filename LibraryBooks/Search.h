//
//  Search.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/9/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Result.h"
#import "Reachability.h"
@interface Search : NSObject<NSXMLParserDelegate>
@property (strong) NSString* query;
@property (strong) NSString* queryType;
@property (strong) NSXMLParser* parser;
@property (strong) NSString* name;

@property (strong) Result* currResult;
@property (strong) NSMutableArray* editionsISBNS;
@property (strong) NSMutableArray* results;
@property (strong) NSMutableArray* editionsResults;
@property (strong) NSMutableArray* subjects;
@property (strong) NSMutableArray* subjectResults;
@property (strong) NSMutableDictionary* simScores;
@property (strong) NSString* imageURL;
@property (strong) NSString* bookDesc;
@property BOOL didConnect;

-(void)findEditions;
-(void)findSimilair;
-(NSMutableArray*)getImageAndDesc :(NSString*) isbn :(NSString*) location :(NSString*) callNumber :(NSString*)title;
-(void)search;
-(NSString*)checkISBN:(NSString*)isbn;
-(NetworkStatus)checkConnection;
@end
