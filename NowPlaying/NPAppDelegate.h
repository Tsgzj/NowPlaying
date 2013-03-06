//
//  NPAppDelegate.h
//  NowPlaying
//
//  Created by SunWenxiang on 3/4/13.
//  Copyright (c) 2013 SunWenxiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "PreferenceWindow.h"

@interface NPAppDelegate : NSObject <NSApplicationDelegate,NSSharingServiceDelegate>
{
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    IBOutlet NSMenuItem *weibo;
}

@end
