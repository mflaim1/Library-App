//
//  Save.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/10/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Search.h"
#import "Result.h"
@interface Save : NSObject
@property Search* searcher;
-(BOOL)saveItems:(NSString*)sectionName :(NSArray*) results :(NSString*) filePath;
-(NSString*)loadSavedBooksFilePath: (NSString*) savedListPath;
@end
