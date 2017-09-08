//
//  AppDelegate.m
//  GPX Combiner
//
//  Created by Tyler Williamson on 9/6/17.
//  Copyright © 2017 Tyler Williamson Software. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSApplication sharedApplication]
     setPresentationOptions:NSApplicationPresentationFullScreen];

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return YES;
}

@end
