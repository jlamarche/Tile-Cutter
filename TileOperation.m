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

@implementation TileOperation
@synthesize delegate, image, column, row, baseFilename, tileHeight, tileWidth;
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
        NSImage *subImage = [image subImageWithTileWidth:(float)tileWidth tileHeight:(float)tileHeight column:column row:row];
        
        if (subImage == nil)
        {
            [self informDelegateOfError:NSLocalizedString(@"Error creating tile", @"")];
            goto finish;
        }
        
        NSArray * representations = [subImage representations];
        
        if ([self isCancelled])
            goto finish;
        
        NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations 
                                                                      usingType:NSJPEGFileType properties:nil];
        
        if (bitmapData == nil)
        {
            [self informDelegateOfError:NSLocalizedString(@"Error retrieving bitmap data from result", @"")];
            goto finish;
        }

        
        if ([self isCancelled])
            goto finish;
        
        NSString *outPath = [NSString stringWithFormat:@"%@_%d_%d.jpg", baseFilename, row, column];
        [bitmapData writeToFile:outPath atomically:YES];
        
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
    [image release], image = nil;
    [baseFilename release], baseFilename = nil;
    
    [super dealloc];
}
@end
