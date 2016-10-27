//
//  main.m
//  webserver
//
//  Created by Andreas Fink on 15.11.13.
//  Copyright (c) 2013 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import "AppDelegate.h"

time_t g_startup_time = 0;
BOOL must_quit = NO;
AppDelegate *g_app_delegate = NULL;

int main(int argc, const char * argv[])
{
    time_t	tim;
    char	state_array[16];
    NSRunLoop *runLoop;

    [NSUserDefaults standardUserDefaults];

    @autoreleasepool
    {
        tim = time(&g_startup_time);
        initstate((unsigned  int)tim,  state_array,  16);

        runLoop = [NSRunLoop currentRunLoop];
        g_app_delegate = [[AppDelegate alloc]init];
        [NSOperationQueue mainQueue];
        NSNotification *notif = [NSNotification notificationWithName:@"dummy" object:NULL];
        [g_app_delegate applicationDidFinishLaunching:notif];
    }
    while(must_quit==0)
    {
        @autoreleasepool
        {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    @autoreleasepool
    {
        NSLog(@"******************* SYSTEM TERMINATING *******************");
    }
    return 0;
}
