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

@interface Tile_CutterAppDelegate()
{
    int tileHeight, tileWidth;
}
@end


@implementation Tile_CutterAppDelegate

@synthesize window, tileCutterView, widthTextField, heightTextField, rowBar, columnBar, progressWindow, progressLabel, baseFilename;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{

}
- (void)saveThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:tileCutterView.filename];
    
    [rowBar setIndeterminate:NO];
    [columnBar setIndeterminate:NO];
    [rowBar setMaxValue:(double)[image rowsWithTileHeight:[heightTextField floatValue]]];
    [rowBar setMinValue:0.];
    [rowBar setDoubleValue:0.];
    [columnBar setMinValue:0.];
    [columnBar setMaxValue:(double)[image columnsWithTileWidth:[widthTextField floatValue]]];
    [columnBar setDoubleValue:0.];
    
    int rows = [image rowsWithTileHeight:tileHeight];
    int cols = [image columnsWithTileWidth:tileWidth];
    for (int row = 0; row < rows; row++)
    {
        [rowBar setDoubleValue:(double)row];
        for (int col = 0; col < cols; col++)
        {

            [columnBar setDoubleValue:(double)col];
            NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
            NSImage *subImage = [image subImageWithTileWidth:(float)tileWidth tileHeight:(float)tileHeight column:col row:row];
            NSArray * representations = [subImage representations];

            NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations 
                                                                          usingType:NSJPEGFileType properties:nil];
            
            NSString *outPath = [NSString stringWithFormat:@"%@_%d_%d.jpg", baseFilename, row, col];
            [bitmapData writeToFile:outPath atomically:YES];
            
            
            [innerPool drain];
        }
    }
    [image release];
     
    [NSApp endSheet:progressWindow];
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
}
-(void)didEndSaveSheet:(NSSavePanel *)savePanel
            returnCode:(int)returnCode conextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton) 
    {
        self.baseFilename = [[savePanel filename] stringByDeletingPathExtension];
        tileHeight = [heightTextField intValue];
        tileWidth = [widthTextField intValue];
        
        [self performSelector:@selector(delayPresentSheet) withObject:nil afterDelay:0.1];
        [self performSelectorInBackground:@selector(saveThread) withObject:nil];
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
- (void)dealloc
{
    [columnBar release], columnBar = nil;
    [rowBar release], rowBar = nil;
    [progressWindow release], progressWindow = nil;
    [progressLabel release], progressLabel = nil;
    [baseFilename release], baseFilename = nil;
    [super dealloc];
}
@end
