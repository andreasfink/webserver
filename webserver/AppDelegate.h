//
//  AppDelegate.h
//  webserver
//
//  Created by Andreas Fink on 15.11.13.
//  Copyright (c) 2013 Andreas Fink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ulib/ulib.h>

@interface AppDelegate : UMObject <NSApplicationDelegate,UMHTTPServerHttpGetPostDelegate>
{
    UMLogHandler    *logHandler;
    UMLogFeed       *stdLogFeed;
    UMTimer         *callMeLater;
}
@end
