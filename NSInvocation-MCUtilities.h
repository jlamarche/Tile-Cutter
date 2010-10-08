//
//  NSInvocation-MCUtilities.h
//  Visioneer
//
//  Created by jeff on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSInvocation(MCUtilities)
-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;
+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments, ...;
@end
