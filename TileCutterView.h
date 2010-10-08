//
//  TileCutterView.h
//  Tile Cutter
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TileCutterView : NSView
{

}
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) IBOutlet NSTextField *tileWidthField;
@property (nonatomic, retain) IBOutlet NSTextField *tileHeightField;
@property (nonatomic, retain) IBOutlet NSColorWell *guideColorWell;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) IBOutlet NSButton *guideCheckbox;
@property (nonatomic, retain) IBOutlet NSButton *saveButton;
- (IBAction) valueChanged:(id)sender;
@end
