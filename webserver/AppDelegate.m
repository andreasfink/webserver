//
//  AppDelegate.m
//  webserver
//
//  Created by Andreas Fink on 15.11.13.
//  Copyright (c) 2013 Andreas Fink. All rights reserved.
//


/*
    this is a simple webserver to demonstrate how
    ulib can be used for serving
    webpages directly from within an application
*/


#import "AppDelegate.h"
#import <ulib/ulib.h>

@implementation AppDelegate

- (AppDelegate *)init
{
    self = [super init];
    if(self)
    {
        /* we create a log handler and a log feed
         * a log feed is a object to stuff log entries into
         * you can have multiple log feeds, one for every part of your code
         * they then get combined into a log handler which can enable/disable
         * certain parts or route certain messages to the console or a logfile
         * or both.
        */
        logHandler = [[UMLogHandler alloc]initWithConsole];
        stdLogFeed = [[UMLogFeed alloc]initWithHandler:logHandler];
    }
    return self;

}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* we set up our webserver on port 8080 */
    int webPort = 8080;
    UMHTTPServer *webServer = [[UMHTTPServer alloc]initWithPort:webPort];

    /* we tell the webserver to send GET or POST page requests to ourselves */
    webServer.httpGetPostDelegate = self;

    /* we attach our standard logfeed to the webserver so it can print debug messages */
    webServer.logFeed = [[UMLogFeed alloc]initWithHandler:logHandler section:@"http"];

    /* we fire up the webserver */
    [webServer start];

}


/* this is getting called for every page request */

- (void)  httpGetPost:(UMHTTPRequest *)req
{
    @autoreleasepool
    {
        if([req.method isEqualToString: @"GET"])
        {
            /* if we have a GET request, we have to extract the parameters from the URL */
            [req extractGetParams];
        }

        if([req.url.relativePath isEqualToString:@"/"])
        {
            /* this is serving a HTML webpage for the root / */
            [req setResponseHtmlString:[self mainPage]];
        }
        else if([req.url.relativePath isEqualToString:@"/css/style.css"])
        {
            /* this is serving the CSS stylesheet */
            [req setResponseCssString:[self css]];
        }
        else if([req.url.relativePath isEqualToString:@"/sync"])
        {
            /* this is serving a plaintext page */
            [req setResponsePlainText:@"hello world in synchronous plaintext"];
        }

        else if([req.url.relativePath isEqualToString:@"/async"])
        {
            /* this is serving the page asynchronously at a later time. 
             for this example we simply ask a timer call us back in 5 seconds
             */

            callMeLater = [[UMTimer alloc]initWithTarget:self
                                                selector:@selector(asyncCallback:)
                                                  object:req
                                                duration:5000000 /* microseconds */
                                                    name:@"callMeLater"
                                                 repeats:NO];
            [callMeLater start];

            /* if we dont get called back in 20 seconds we close anyway */
            [req makeAsyncWithTimeout:20];
        }
        else
        {
            /* the famous 404 */
            [req setNotFound];
        }
    }
}

- (void)asyncCallback:(UMHTTPRequest *)req
{
    [callMeLater stop];
    [req setResponsePlainText:@"I'm back"];
    [req resumePendingRequest];
}


- (NSString *)  mainPage
{
    NSString *p =
    @"<html>\n"
    @"<header>\n"
    @"    <link rel=\"stylesheet\" href=\"/css/style.css\">\n"
    @"</header>\n"
    @"<body>\n"
    @"<H1>Hello World? Hello Web!</H1>\n"
    @"<UL>\n"
    @"<LI><a href=\"sync\">synchronous-page</a></LI>\n"
    @"<LI><a href=\"async\">asynchronous-page</a></LI>\n"
    @"</UL>\n";
    return p;
}

- (void)  handleSync:(UMHTTPRequest *)req
{
    /* this is a synchronous request returning plaintext */
    [req setResponsePlainText:@"hello world in plaintext"];

}
- (void)  handleAsync:(UMHTTPRequest *)req
{
    /* this is a asynchronous request */
}

- (void)  handleCss:(UMHTTPRequest *)req
{
    [req setResponseCssString:[self css]];
}

- (NSString *)css
{
    static NSMutableString *s = NULL;
    if(s)
    {
        return s;
    }
    s = [[NSMutableString alloc]init];

    [s appendString:@"body\n"];
    [s appendString:@"{\n"];
    [s appendString:@"	border: none;\n"];
    [s appendString:@"	padding: 20px;\n"];
    [s appendString:@"	margin: 0px;\n"];
    [s appendString:@"	background-color:white;\n"];
    [s appendString:@"	color: black;\n"];
    [s appendString:@"	font-family: 'Metrophobic', \"Lucida Grande\", \"Lucida Sans Unicode\", arial, Helvetica, Verdana;\n"];
    [s appendString:@"	font-size: 11px;\n"];
    [s appendString:@"}\n"];
    return s;
}
@end
