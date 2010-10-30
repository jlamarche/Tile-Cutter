//
//  NSBitmapImageRep-Tile.m
//  Tile Cutter
//
//  Created by jeff on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSBitmapImageRep-Tile.h"


@implementation NSBitmapImageRep(Tile)
-(NSImage *)subImageWithTileWidth:(CGFloat)tileWidth tileHeight:(CGFloat)tileHeight column:(NSUInteger)column row:(NSUInteger)row
{
    int width = [self pixelsWide];
    int height = [self pixelsHigh];
    int bytesPerPixel = [self bitsPerPixel] / 8;
    
    int theRow = row * tileHeight;
    int theCol = column * tileWidth;
    
    int i,x,y;
    unsigned char *p1, *p2;
    
    int lastCol;
    int outputWidth;
    
    if (theCol + tileWidth > width) // last column, not full size
    {
        lastCol = width;
        outputWidth = (width - theCol);
    }
    else
    {
        lastCol = theCol + tileWidth;
        outputWidth = tileWidth;
    }
    
    int lastRow, outputHeight;
    if (theRow + tileHeight > height)
    {
        lastRow = height;
        outputHeight = (height - theRow);
        
    }
    else
    {
        lastRow = theRow + tileHeight;
        outputHeight = tileHeight;
    }    
    
    
    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(outputWidth,outputHeight)];
    
    NSBitmapImageRep *retRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL 
                                                                       pixelsWide:outputWidth 
                                                                       pixelsHigh:outputHeight 
                                                                    bitsPerSample:[self bitsPerSample]
                                                                  samplesPerPixel:[self samplesPerPixel]
                                                                         hasAlpha:[self hasAlpha]
                                                                         isPlanar:[self isPlanar]
                                                                   colorSpaceName:[self colorSpaceName]
                                                                     bitmapFormat:[self bitmapFormat]
                                                                      bytesPerRow:[self bytesPerRow]
                                                                     bitsPerPixel:[self bitsPerPixel]];
    
    unsigned char *srcData = [self bitmapData];
    unsigned char *destData = [retRep bitmapData];  
    
    
    for (x = theCol; x < lastCol; x++)
    {
        for (y = theRow; y < lastRow; y++)
        {
            p1 = srcData + bytesPerPixel * (y * width + x);
            p2 = destData + bytesPerPixel * ((y - theRow) * width + (x - theCol));
            for (i = 0; i < bytesPerPixel; i++)
                p2[i] = p1[i];
        }
    }
    
    [ret addRepresentation:retRep];
    [retRep release];
    return [ret autorelease];
    
}

@end
