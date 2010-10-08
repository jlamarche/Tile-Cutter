//
//  TileCutterOperation.h
//  Tile Cutter
//
//  Created by jeff on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TileCutterOperation;

@protocol TileCutterOperationDelegate

- (void)tileCutterOperation:(TileCutterOperation *)op didFinishSuccessfully:(NSImage *)tile;
@optional
- (void)tileCutterOperationDidFail:(TileCutterOperation *)op;
@end


@interface TileCutterOperation : NSOperation 
{

}
@property (assign) NSObject<TileCutterOperationDelegate> *delegate;
@property (retain) NSImage *source;
@property CGFloat tileWidth;
@property CGFloat tileHeight;
@property NSUInteger row;
@property NSUInteger column;
@end
