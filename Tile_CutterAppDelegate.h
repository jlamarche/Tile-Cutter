//
//  Tile_CutterAppDelegate.h
//  Tile Cutter
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TileCutterView;

@interface Tile_CutterAppDelegate : NSObject <NSApplicationDelegate> 
{
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet TileCutterView *tileCutterView;
@property (assign) IBOutlet NSTextField *widthTextField;
@property (assign) IBOutlet NSTextField *heightTextField;
@property (retain) IBOutlet NSProgressIndicator *columnBar;
@property (retain) IBOutlet NSProgressIndicator *rowBar;
@property (retain) IBOutlet NSWindow *progressWindow;
@property (retain) IBOutlet NSTextField *progressLabel;
@property (retain) IBOutlet NSString *baseFilename;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)openSelected:(id)sender;
@end
