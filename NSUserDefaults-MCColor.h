//
//  NSUserDefaults-MCColor.h
//  Tile Cutter
//
//  Created by jeff on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSUserDefaults(MCColor)

- (void)setColor:(NSColor*)aColor forKey:(NSString*)aKey ;

- (NSColor*)colorForKey:(NSString*)aKey ;
@end
