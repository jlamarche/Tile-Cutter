//
//  NSImage-Tile.h
//  Crimson
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage(Tile)
-(NSImage *)subImageWithTileWidth:(CGFloat)tileWidth tileHeight:(CGFloat)tileHeight column:(NSUInteger)column row:(NSUInteger)row;
-(NSUInteger)columnsWithTileWidth:(CGFloat)tileWidth;
-(NSUInteger)rowsWithTileHeight:(CGFloat)tileHeight;
@end
