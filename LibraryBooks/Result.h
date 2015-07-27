//
//  Result.h
//  LibraryBooks
//
//  Created by Mariah Flaim on 6/1/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Result : NSObject
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSMutableString *fullTitle;
@property (nonatomic,strong) NSString *subTitle;
@property (nonatomic,strong) NSString *isbn;
@property (nonatomic,strong) NSString *callNumber;
@property (nonatomic,strong) NSString *bibId;
@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *holdings;



@end
