//
//  TileOperation.m
//  Tile Cutter
//
//  Created by jeff on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TileOperation.h"
#import "NSImage-Tile.h"
#import "NSInvocation-MCUtilities.h"
#import "NSBitmapImageRep-Tile.h"

@implementation TileOperation
@synthesize delegate, imageRep, row, baseFilename, tileHeight, tileWidth, outputFormat;
#pragma mark -
- (void)informDelegateOfError:(NSString *)message
{
    
    if ([delegate respondsToSelector:@selector(operation:didFailWithMessage:)])
    {
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate 
                                                             selector:@selector(operation:didFailWithMessage:) 
                                                      retainArguments:YES, self, message];
        [invocation invokeOnMainThreadWaitUntilDone:YES];
    }
}
- (void)main 
{
    @try 
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSString *extension = nil;
        NSBitmapImageFileType fileType;

        switch (outputFormat)
        {
            case TileCutterOutputPrefsJPEG:
                extension = @"jpg";
                fileType = NSJPEGFileType;
                break;
            case TileCutterOutputPrefsGIF:
                extension = @"gif";
                fileType = NSGIFFileType;
                break;
            case TileCutterOutputPrefsTIFF:
                extension = @"tiff";
                fileType = NSTIFFFileType;
                break;
            case TileCutterOutputPrefsBMP:
                extension = @"bmp";
                fileType = NSBMPFileType;
                break;
            case TileCutterOutputPrefsPNG:
                extension = @"png";
                fileType = NSPNGFileType;
                break;
            case TileCutterOutputPrefsJPEG2000:
                extension = @"jpx";
                fileType = NSJPEG2000FileType;
                break;
            default:
                NSLog(@"Bad preference detected, assuming JPEG");
                extension = @"jpg";
                fileType = NSJPEGFileType;
                break;
        }
        
		int tileColCount = [imageRep columnsWithTileWidth:tileWidth];
        for (int column = 0; column < tileColCount; column++)
        {
            NSImage *subImage = [imageRep subImageWithTileWidth:(float)tileWidth tileHeight:(float)tileHeight column:column row:row];
            
            if (subImage == nil)
            {
                [self informDelegateOfError:NSLocalizedString(@"Error creating tile", @"")];
                goto finish;
            }
            
            NSArray * representations = [subImage representations];
            
            if ([self isCancelled])
                goto finish;
            
            NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations 
                                                                          usingType:fileType properties:nil];
            
            if (bitmapData == nil)
            {
                [self informDelegateOfError:NSLocalizedString(@"Error retrieving bitmap data from result", @"")];
                goto finish;
            }
            
            
            if ([self isCancelled])
                goto finish;
            
            NSString *outPath = [NSString stringWithFormat:@"%@_%d_%d.%@", baseFilename, row, column, extension];
            [bitmapData writeToFile:outPath atomically:YES];
            
            if ([delegate respondsToSelector:@selector(operationDidFinishTile:)])
                [delegate performSelectorOnMainThread:@selector(operationDidFinishTile:) 
                                           withObject:self 
                                        waitUntilDone:NO];
            
        }
        
        if ([delegate respondsToSelector:@selector(operationDidFinishSuccessfully:)])
            [delegate performSelectorOnMainThread:@selector(operationDidFinishSuccessfully:) 
                                       withObject:self 
                                    waitUntilDone:NO];
    finish:
        [pool drain];
    }
    @catch (NSException * e) 
    {
        NSLog(@"Exception: %@", e);
    }
}

- (void)dealloc
{
    delegate = nil;
    [imageRep release], imageRep = nil;
    [baseFilename release], baseFilename = nil;
    
    [super dealloc];
}
@end
