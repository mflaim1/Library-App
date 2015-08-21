//
//  UIColor+LibraryColors.m
//  LibraryBooks
//
//  Created by Mariah Flaim on 8/21/15.
//  Copyright (c) 2015 Mariah Flaim. All rights reserved.
//

#import "UIColor+LibraryColors.h"

@implementation UIColor (LibraryColors)
+ (UIColor *)libraryBlue {
    return[UIColor colorWithRed:((float)((0x360000 & 0xFF0000) >> 16))/255.0 \
                    green:((float)((0x009800 & 0x00FF00) >>  8))/255.0 \
                     blue:((float)((0x0000BF & 0x0000FF) >>  0))/255.0 \
                    alpha:1.0];
}

+ (UIColor *)libraryTan {
    return [UIColor colorWithRed:((float)((0xE60000 & 0xFF0000) >> 16))/255.0 \
                           green:((float)((0x00E000 & 0x00FF00) >>  8))/255.0 \
                            blue:((float)((0x0000D2 & 0x0000FF) >>  0))/255.0 \
                           alpha:1.0];
}

+ (UIColor *)libraryLight{
    return [UIColor colorWithRed:((float)((0xEF0000 & 0xFF0000) >> 16))/255.0 \
                    green:((float)((0x00EF00 & 0x00FF00) >>  8))/255.0 \
                     blue:((float)((0x0000EF & 0x0000FF) >>  0))/255.0 \
                           alpha:1.0];
}


@end
