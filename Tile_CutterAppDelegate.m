//
//  Tile_CutterAppDelegate.m
//  Tile Cutter
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tile_CutterAppDelegate.h"
#import "TileCutterView.h"
#import "NSImage-Tile.h"
#import "TileCutterOperation.h"
@interface Tile_CutterAppDelegate()
{
    int tileHeight, tileWidth;
}
@end


@implementation Tile_CutterAppDelegate

@synthesize window, tileCutterView, widthTextField, heightTextField, rowBar, columnBar, progressWindow, progressLabel, baseFilename, queue;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue setMaxConcurrentOperationCount:1];
    [queue setSuspended:NO];
}
- (void)saveThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:tileCutterView.filename];
    
//    [rowBar setIndeterminate:NO];
//    [columnBar setIndeterminate:NO];
//    [rowBar setMaxValue:(double)[image rowsWithTileHeight:[heightTextField floatValue]]];
//    [rowBar setMinValue:0.];
//    [rowBar setDoubleValue:0.];
//    [columnBar setMinValue:0.];
//    [columnBar setMaxValue:(double)[image columnsWithTileWidth:[widthTextField floatValue]]];
//    [columnBar setDoubleValue:0.];
    
    for (int row = 0; row < [image rowsWithTileHeight:tileHeight]; row++)
    {
        //[rowBar setDoubleValue:(double)row];
        for (int col = 0; col < [image columnsWithTileWidth:tileWidth]; row++)
        {

            //[columnBar setDoubleValue:(double)col];
//            NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
            NSImage *subImage = [image subImageWithTileWidth:(float)tileWidth tileHeight:(float)tileHeight column:col row:row];
            NSArray * representations = [subImage representations];

            NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations 
                                                                          usingType:NSJPEGFileType properties:nil];
            
            NSString *outPath = [NSString stringWithFormat:@"%@_%d_%d.jpg", baseFilename, col, row];
            [bitmapData writeToFile:outPath atomically:YES];
            
            
//            [innerPool drain];
        }
    }
    
     
    //[NSApp endSheet:progressWindow];
    [pool drain];
}
- (IBAction)saveButtonPressed:(id)sender
{
    NSSavePanel *sp = [NSSavePanel savePanel];
    [sp setRequiredFileType:@"jpg"];
    
    [sp beginSheetForDirectory:nil 
                          file:@"output.jpg" 
                modalForWindow:window
                 modalDelegate:self 
                didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:) 
                   contextInfo:nil];
    
    
    //[NSApp endSheet:myCustomSheet];
}
-(void)didEndSaveSheet:(NSSavePanel *)savePanel
            returnCode:(int)returnCode conextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton) 
    {
        self.baseFilename = [[savePanel filename] stringByDeletingPathExtension];
        tileHeight = [heightTextField intValue];
        tileWidth = [widthTextField intValue];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:tileCutterView.filename];
        for (int row = 0; row < [image rowsWithTileHeight:tileHeight]; row++)
        {
            for (int col = 0; col < [image columnsWithTileWidth:tileWidth]; row++)
            {
                TileCutterOperation *op = [[TileCutterOperation alloc] init];
                op.source = image;
                op.tileHeight = tileHeight;
                op.tileWidth = tileWidth;
                op.row = row;
                op.column = col;
                op.delegate = self;
                [queue addOperation:op];
            }
        }
        
//        [self performSelector:@selector(delayPresentSheet) withObject:nil afterDelay:0.1];
//        [self performSelectorInBackground:@selector(saveThread) withObject:nil];
    }
}
- (void)delayPresentSheet
{
    [progressLabel setStringValue:@"Analyzing image for tile cutting…"];
    [rowBar startAnimation:self];
    [columnBar startAnimation:self];
    
    [NSApp beginSheet: progressWindow
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];

}
- (void)tileCutterOperation:(TileCutterOperation *)op didFinishSuccessfully:(NSImage *)tile
{
    NSLog(@"Operation %@ did succeed", op);
    NSArray * representations = [tile representations];
    
    NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations 
                                                                  usingType:NSJPEGFileType properties:nil];
    
    NSString *outPath = [NSString stringWithFormat:@"%@_%d_%d.jpg", baseFilename, op.row, op.column];
    [bitmapData writeToFile:outPath atomically:YES];
}
- (void)tileCutterOperationDidFail:(TileCutterOperation *)op
{
    NSLog(@"Operation %@ failed!", op);
}
- (void)dealloc
{
    [columnBar release], columnBar = nil;
    [rowBar release], rowBar = nil;
    [progressWindow release], progressWindow = nil;
    [progressLabel release], progressLabel = nil;
    [baseFilename release], baseFilename = nil;
    [queue release], queue = nil;
    [super dealloc];
}
@end
