//
//  Save.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/10/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "Save.h"

@implementation Save

/*
 function-saveItems
 params-NSString sectionName NSArray results NSString filePath
 description-updates the savedBookDict.plist with whatever results the user wants to save
 */
-(BOOL)saveItems:(NSString*) sectionName :(NSArray*) results :(NSString*) filePath{
    NSMutableDictionary *plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSMutableArray* arr=[[NSMutableArray alloc]init];
    self.searcher=[[Search alloc]init];
    
    for(Result *book in results){
        NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
        
        [dict setObject:book.title forKey:@"title"];
        [dict setObject:book.fullTitle forKey:@"fullTitle"];
        [dict setObject:book.subTitle forKey:@"subTitle"];
        [dict setObject:book.callNumber forKey:@"callNum"];
        [dict setObject:book.isbn forKey:@"isbn"];
        [dict setObject:book.bibId forKey:@"bibId"];
        [dict setObject:book.location forKey:@"location"];
        
        if(!book.imageURL||!book.desc){
            NSMutableArray *results=[self.searcher getImageAndDesc:book.isbn:book.location:book.callNumber:book.title];
            book.imageURL=results[0];
            book.desc=results[1];
        }
        [dict setObject:book.imageURL forKey:@"imageURL"];
       
        [dict setObject:book.desc forKey:@"description"];
        
        if(plistDict[sectionName]){
            if(![plistDict[sectionName] containsObject:dict]){
                [plistDict[sectionName] addObject:dict];
            }
        }else{
            [plistDict setObject:arr forKey:sectionName];
            [plistDict[sectionName] addObject:dict];
        }
        
    }
    return [plistDict writeToFile:filePath atomically:YES];
}
/*
 function-loadSavedBooksFilePath
 params-savedListPath
 description-loads the file path of the savedBookDict.plist so the most updated version of it can be used for various functions or creates the file path if the plist does not exist yet
 */

-(NSString*)loadSavedBooksFilePath: (NSString*) savedListPath{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    savedListPath = [documentsDirectory stringByAppendingPathComponent:@"savedBookDict.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: savedListPath])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"savedBookDict" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: savedListPath error:&error];
    }
    
    return savedListPath;
}



@end
