//
//  TileCutterOperation.m
//  Tile Cutter
//
//  Created by jeff on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TileCutterOperation.h"
#import "NSInvocation-MCUtilities.h"
#import "NSImage-Tile.h"

@implementation TileCutterOperation
@synthesize delegate, source, tileWidth, tileHeight, row, column;

- (void)informDelegateOfFailure
{
    if ([delegate respondsToSelector:@selector(tileCutterOperationDidFail:)])
    {
        [delegate performSelectorOnMainThread:@selector(tileCutterOperationDidFail:) 
                                   withObject:self 
                                waitUntilDone:YES];
    }
}

- (void)informDelegateOfSuccess:(NSImage *)image
{
    if ([delegate respondsToSelector:@selector(tileCutterOperation:didFinishSuccessfully:)])
    {
        [self retain]; // LEAKING
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate 
                                                             selector:@selector(tileCutterOperation:didFinishSuccessfully:) 
                                                      retainArguments:YES, self, image];
        [invocation invokeOnMainThreadWaitUntilDone:YES];
    } 
}
- (void)main 
{
    @try 
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSImage *subImage = [source subImageWithTileWidth:(float)tileWidth tileHeight:(float)tileHeight column:column row:row];
        
        if (subImage == nil)
        {
            [self informDelegateOfFailure]; 
            goto finish;
        }

        [self informDelegateOfSuccess:subImage];
        
    finish:
        [pool drain];
    }
    @catch (NSException * e) 
    {
        NSLog(@"Exception: %@", e);
        [self informDelegateOfFailure];
    }
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (row %d, col %d)", [self className], row, column];
}
- (void)dealloc
{
    delegate = nil;
    [source release], source = nil;
    [source release], source = nil;
    [source release], source = nil;
    [source release], source = nil;
    [source release], source = nil;
    
    [super dealloc];
}
@end
