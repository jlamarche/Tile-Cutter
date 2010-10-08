//
//  TileCutterView.m
//  Tile Cutter
//
//  Created by jeff on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TileCutterView.h"


@implementation TileCutterView
@synthesize filename, tileWidthField, tileHeightField, guideColorWell, image, guideCheckbox, saveButton;

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSTIFFPboardType, NSPDFPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] || [[pboard types] containsObject:NSTIFFPboardType] || [[pboard types] containsObject:NSPDFPboardType] ) 
    {
        if (sourceDragMask & NSDragOperationLink) 
            return NSDragOperationLink;
        else if (sourceDragMask & NSDragOperationCopy) 
            return NSDragOperationCopy;
        
    }
    return NSDragOperationNone;
}

- (void)drawRect:(NSRect)dirtyRect 
{
    NSColor *pattern = [NSColor colorWithPatternImage:[NSImage imageNamed:@"image.png"]];
    [pattern setFill];
    NSRectFill(NSUnionRect([self bounds], dirtyRect));

    if (image == nil)
        return;
    
    NSRect sourceRect = NSMakeRect(0.f, 0.f, image.size.width, image.size.height);
    
    NSRect destRect = [self bounds];
    
    float srcAspectRatio = image.size.width / image.size.height;
    float dstAspectRatio = destRect.size.width / destRect.size.height;
    

    if (srcAspectRatio > dstAspectRatio)
        destRect.size.height = (1.f / srcAspectRatio) * destRect.size.width;
    else
        destRect.size.width = destRect.size.height * (srcAspectRatio);
    
    if (destRect.size.width < [self bounds].size.width)
    {
        float delta = [self bounds].size.width - destRect.size.width;
        destRect.origin.x += delta/2.f;
    }
    else if (destRect.size.height < [self bounds].size.height)
    {
        float delta = [self bounds].size.height - destRect.size.height;
        destRect.origin.y += delta/2.f;               
    }

    [image drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
    
    if (![guideCheckbox intValue])
        return;
    
    NSColor *color = [guideColorWell color];
    [color set];
    NSFrameRect(destRect);
    
    float pctChange = destRect.size.width / sourceRect.size.width;
    
    float tileWidth = [tileWidthField floatValue];
    float tileHeight = [tileHeightField floatValue];
    
    tileWidth *= pctChange;
    tileHeight *= pctChange;
    
    // Horizontal Slizes
    float curPos = destRect.size.height + destRect.origin.y;
    while (curPos > destRect.origin.y)
    {
        NSBezierPath *linePath = [NSBezierPath bezierPath];
        [linePath moveToPoint:NSMakePoint(destRect.origin.x, curPos)];
        [linePath lineToPoint:NSMakePoint(destRect.size.width + destRect.origin.x, curPos)];
        [linePath setLineWidth:1.0f];
        [linePath stroke];
        curPos -= tileHeight;
    }
    
    curPos = destRect.origin.x;
    while (curPos < destRect.size.width + destRect.origin.x)
    {
        NSBezierPath *linePath = [NSBezierPath bezierPath];
        [linePath moveToPoint:NSMakePoint(curPos, destRect.origin.y)];
        [linePath lineToPoint:NSMakePoint(curPos, destRect.size.height + destRect.origin.y)];
        [linePath setLineWidth:1.0f];
        [linePath stroke];
        curPos += tileWidth;
    }
    
    
}
- (void)setImage:(NSImage *)newImage
{
    [newImage retain];
    [image release];
    image = newImage;
    
    [saveButton setEnabled:(image != nil)];
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) 
    {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        if ([files count] == 0)
            return NO;
        
        // Only handle first file, ignore rest
        self.filename = [files objectAtIndex:0];
        NSImage *theImage = [[NSImage alloc] initWithContentsOfFile:filename];
        [self setImage:theImage];
        [theImage release];
        [self setNeedsDisplay:YES];
    }
    return YES;
}
- (IBAction)valueChanged:(id)sender
{
    [self setNeedsDisplay:YES];
}
- (void)dealloc
{
    [tileWidthField release], tileWidthField = nil;
    [tileHeightField release], tileHeightField = nil;
    [guideColorWell release], guideColorWell = nil;
    [saveButton release], saveButton = nil;
        
    [image release], image = nil;
    [filename release], filename = nil;
    [super dealloc];
}
@end
