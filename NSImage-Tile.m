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
    
    NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:[self CGImageForProposedRect:NULL context:NULL hints:nil]] autorelease];
    int width = [imageRep pixelsWide];
    int height = [imageRep pixelsHigh];
    int bytesPerPixel = [imageRep bitsPerPixel] / 8;

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
//    BOOL print = NO;
//    NSLog(@"theRow: %d", theRow);
//    NSLog(@"tileHeight: %f", tileHeight);
//    NSLog(@"Height: %d", height);
    int lastRow, outputHeight;
    if (theRow + tileHeight > height)
    {
        lastRow = height;
        outputHeight = (height - theRow);
//        print = YES;
    }
    else
    {
        lastRow = theRow + tileHeight;
        outputHeight = tileHeight;
    }    
//    NSLog(@"width: %d\nheight: %d", width, height);
//    NSLog(@"outputHeight: %d", outputHeight);
//    NSLog(@"outputWidth: %d", outputWidth);
    
    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(outputWidth,outputHeight)];

    NSBitmapImageRep *retRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL 
                                                                    pixelsWide:outputWidth 
                                                                    pixelsHigh:outputHeight 
                                                                 bitsPerSample:[imageRep bitsPerSample]
                                                               samplesPerPixel:[imageRep samplesPerPixel]
                                                                      hasAlpha:[imageRep hasAlpha]
                                                                      isPlanar:[imageRep isPlanar]
                                                                colorSpaceName:[imageRep colorSpaceName]
                                                                  bitmapFormat:[imageRep bitmapFormat]
                                                                   bytesPerRow:[imageRep bytesPerRow]
                                                                  bitsPerPixel:[imageRep bitsPerPixel]];
                                
    unsigned char *srcData = [imageRep bitmapData];
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
-(NSUInteger)columnsWithTileWidth:(CGFloat)tileWidth
{
    return [self size].width / tileWidth + 1;
}
-(NSUInteger)rowsWithTileHeight:(CGFloat)tileHeight
{
    return [self size].height / tileHeight + 1;
}
@end
