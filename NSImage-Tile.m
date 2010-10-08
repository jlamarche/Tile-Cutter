//
//  NSImage-Tile.m
//  Crimson
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSImage-Tile.h"


@implementation NSImage(Tile)
-(NSImage *)subImageWithTileWidth:(CGFloat)tileWidth tileHeight:(CGFloat)tileHeight column:(NSUInteger)column row:(NSUInteger)row
{
    if (column >= [self columnsWithTileWidth:tileWidth])
        return nil;
    if (row >= [self rowsWithTileHeight:tileHeight])
        return nil;
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:[self CGImageForProposedRect:NULL context:NULL hints:nil]];
    int width = [imageRep pixelsWide];
    int height = [imageRep pixelsHigh];
    int bpp = [imageRep bitsPerPixel] / 8;
    

    
    int theRow = row * tileHeight;
    int theCol = column * tileWidth;
    
    int i,x,y;
    unsigned char *p1, *p2;
    
    int lastCol;
    int outputWidth;
    if (theCol + tileWidth > width)
    {
        lastCol = width;
        outputWidth = width - theCol;
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
        outputHeight = height - theRow;
    }
    else
    {
        lastRow = theRow + tileHeight;
        outputHeight = tileHeight;
    }    
    
    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(outputWidth,outputHeight)];
    
    NSMutableData *retData = [NSMutableData dataWithLength:bpp * tileWidth * tileHeight];
    
    unsigned char *srcData = [imageRep bitmapData];
    unsigned char *destData = [retData mutableBytes];
    
    
    for (x = theCol; x < lastCol; x++)
    {
        for (y = theRow; y < lastRow; y++)
        {
            p1 = srcData + bpp * (y * width + x);
            p2 = destData + bpp * ((y - theRow) * width + (x - theCol));
            for (i = 0; i < bpp; i++)
                p2[i] = p1[i];
        }
    }
    NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&destData 
                                                                    pixelsWide:tileWidth 
                                                                    pixelsHigh:tileHeight 
                                                                 bitsPerSample:[imageRep bitsPerSample]
                                                               samplesPerPixel:[imageRep samplesPerPixel]
                                                                      hasAlpha:[imageRep hasAlpha]
                                                                      isPlanar:[imageRep isPlanar]
                                                                colorSpaceName:[imageRep colorSpaceName]
                                                                  bitmapFormat:[imageRep bitmapFormat]
                                                                   bytesPerRow:[imageRep bytesPerRow]
                                                                  bitsPerPixel:[imageRep bitsPerPixel]] autorelease];

    [ret addRepresentation:rep];
    return [ret autorelease];
    
}
-(NSUInteger)columnsWithTileWidth:(CGFloat)tileWidth
{
    return [self size].width / tileWidth;
}
-(NSUInteger)rowsWithTileHeight:(CGFloat)tileHeight
{
    return [self size].height / tileHeight;
}
@end
