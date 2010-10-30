//
//  Tile_CutterAppDelegate.m
//  Tile Cutter
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include <dispatch/dispatch.h>
#import "Tile_CutterAppDelegate.h"
#import "TileCutterView.h"
#import "NSImage-Tile.h"
#import "NSUserDefaults-MCColor.h"
#import "TileOperation.h"

@interface Tile_CutterAppDelegate()
{
    int tileHeight, tileWidth;
    int tileRowCount, tileColCount;
    int progressCol, progressRow;
}
- (void)delayAlert:(NSString *)message;
@end


@implementation Tile_CutterAppDelegate

@synthesize window, tileCutterView, widthTextField, heightTextField, rowBar, columnBar, progressWindow, progressLabel, baseFilename, queue;

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{

    tileCutterView.filename = filename;
    NSImage *theImage = [[NSImage alloc] initWithContentsOfFile:filename];
    if (theImage == nil)
        return NO;
    
    tileCutterView.image = theImage;
    [theImage release];
    [tileCutterView setNeedsDisplay:YES];
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSColor *guideColor = [defaults colorForKey:@"guideColor"];
    if (guideColor == nil)
    {
        [defaults setColor:[NSColor redColor] forKey:@"guideColor"];
        [defaults setInteger:200 forKey:@"widthField"];
        [defaults setBool:YES forKey:@"showGuides"];
        [defaults setInteger:200 forKey:@"heightField"];
    }
    
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
}
- (void)saveThread
{
    NSLog(@"Save thread started");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    NSImage *image = [[[NSImage alloc] initWithContentsOfFile:tileCutterView.filename] autorelease];
    
    [rowBar setIndeterminate:NO];
    [columnBar setIndeterminate:NO];
    [rowBar setMaxValue:(double)[image rowsWithTileHeight:[heightTextField floatValue]]];
    [rowBar setMinValue:0.];
    [rowBar setDoubleValue:0.];
    [columnBar setMinValue:0.];
    [columnBar setMaxValue:(double)[image columnsWithTileWidth:[widthTextField floatValue]]];
    [columnBar setDoubleValue:0.];
    
    progressCol = 0;
    progressRow = 0;
    
    tileRowCount = [image rowsWithTileHeight:tileHeight];
    tileColCount = [image columnsWithTileWidth:tileWidth];
    
    for (int row = 0; row < tileRowCount; row++)
    {
        // Each row operation gets its own ImageRep to avoid contention
        NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:[image CGImageForProposedRect:NULL context:NULL hints:nil]] autorelease];
        TileOperation *op = [[TileOperation alloc] init];
        op.row = row;
        op.tileWidth = tileWidth;
        op.tileHeight = tileHeight;
        op.imageRep = imageRep;
        op.baseFilename = baseFilename;
        op.delegate = self;
        [queue addOperation:op];
        [op release];
    }
    
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
    }
}
- (void)delayPresentSheet
{
    [progressLabel setStringValue:@"Analyzing image for tile cutting…"];
    [rowBar setIndeterminate:YES];
    [columnBar setIndeterminate:YES];
    [rowBar startAnimation:self];
    [columnBar startAnimation:self];
    
    [NSApp beginSheet: progressWindow
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
    
    //[queue setSuspended:YES];
    [self performSelectorInBackground:@selector(saveThread) withObject:nil];
}
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    
}
- (IBAction)openSelected:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowedFileTypes:[NSImage imageFileTypes]];
    
    [op beginSheetModalForWindow:window completionHandler:^(NSInteger returnCode){
        if (returnCode == NSOKButton)
        {
            NSString *filename = [op filename];
            [self application:NSApp openFile:filename];
        }
    }];
    
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
#pragma mark -
- (void)operationDidFinishTile:(TileOperation *)op
{
    progressCol++;
    if (progressCol >= tileColCount)
    {
        progressCol = 0;
        progressRow++;
    }
    if (progressRow >= tileRowCount)
        [NSApp endSheet:progressWindow];
    
    [rowBar setDoubleValue:(double)progressRow];
    [columnBar setDoubleValue:(double)progressCol];
    [progressLabel setStringValue:[NSString stringWithFormat:@"Processing row %d, column %d", progressRow, progressCol]];
    
    
}
- (void)delayAlert:(NSString *)message
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"Crud"];
    [alert setMessageText:@"There was an error tiling this image."];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}
- (void)operation:(TileOperation *)op didFailWithMessage:(NSString *)message
{
    [NSApp endSheet:progressWindow];
    [self performSelector:@selector(delayAlert:) withObject:nil afterDelay:0.5];
}
@end
