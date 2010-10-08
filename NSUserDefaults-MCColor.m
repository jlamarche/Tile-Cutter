//
//  NSUserDefaults-MCColor.m
//  Tile Cutter
//
//  Created by jeff on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSUserDefaults-MCColor.h"


@implementation NSUserDefaults(MCColor)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey 
{
    NSData* theData = [NSArchiver archivedDataWithRootObject:aColor] ;
    [self setObject:theData forKey:aKey] ;
}

- (NSColor*)colorForKey:(NSString *)aKey 
{
    NSColor* theColor = nil ;
    NSData* theData = [self dataForKey:aKey] ;
    if (theData != nil) 
        theColor = (NSColor*)[NSUnarchiver unarchiveObjectWithData:theData] ;
    
    return theColor ;
}
@end
