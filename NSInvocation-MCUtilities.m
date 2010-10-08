//
//  NSInvocation-MCUtilities.m
//  Visioneer
//
//  Created by jeff on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSInvocation-MCUtilities.h"


@implementation NSInvocation(MCUtilities)
-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait
{
    [self performSelectorOnMainThread:@selector(invoke)
                           withObject:nil
                        waitUntilDone:wait];
}
+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments, ...
{
    va_list ap;
    va_start(ap, retainArguments);
    char* args = (char*)ap;
    NSMethodSignature* signature = [target methodSignatureForSelector:aSelector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (retainArguments) {
        [invocation retainArguments];
    }
    [invocation setTarget:target];
    [invocation setSelector:aSelector];
    for (int index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:index];
        NSUInteger size, align;
        NSGetSizeAndAlignment(type, &size, &align);
        NSUInteger mod = (NSUInteger)args % align;
        if (mod != 0) {
            args += (align - mod);
        }
        [invocation setArgument:args atIndex:index];
        args += size;
    }
    va_end(ap);
    return invocation;
}
@end
