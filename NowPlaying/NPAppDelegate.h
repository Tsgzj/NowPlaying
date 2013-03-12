//
//  NPAppDelegate.h
//  NowPlaying
//
//  Created by SunWenxiang on 3/4/13.
//  Copyright (c) 2013 SunWenxiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
extern NSString * const ShouldShowArtist;
extern NSString * const ShouldShowAlbum;
extern NSString * const ShouldShowArtwork;
extern NSString * const ShouldShowRating;
extern NSString * const ShouldShowURL;

@interface NPAppDelegate : NSObject <NSApplicationDelegate,NSSharingServiceDelegate>
{
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    IBOutlet NSMenuItem *weibo;
    IBOutlet NSMenuItem *twitter;
    IBOutlet NSMenuItem *login;
    IBOutlet NSMenuItem *showArtistMenuItem;
    IBOutlet NSMenuItem *showAlbumMenuItem;
    IBOutlet NSMenuItem *showArtworkMenuItem;
    IBOutlet NSMenuItem *showRatingMenuItem;
    IBOutlet NSMenuItem *showShareURLMenuItem;
}

@property (strong) IBOutlet NSMenuItem *login;
@property (nonatomic, retain) IBOutlet NSMenuItem *showArtistMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *showAlbumMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *showArtworkMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *showRatingMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *showShareURLMenuItem;

@end
