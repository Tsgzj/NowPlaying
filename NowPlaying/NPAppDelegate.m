//
//  NPAppDelegate.m
//  NowPlaying
//
//  Created by SunWenxiang on 3/4/13.
//  Copyright (c) 2013 SunWenxiang. All rights reserved.
//

#import "NPAppDelegate.h"



@interface NPAppDelegate()

@property (strong) NSSharingService *weiboSharingService;
@property (strong) NSSharingService *twitterSharingService;


@end

@implementation NPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (void)awakeFromNib{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"music.png"]];
    [statusItem setHighlightMode:YES];
}

- (NSString *)getNowPlayingInfo
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack *current = [iTunes currentTrack];
    
    NSString *podcast;
    if (current.podcast)
        podcast = @" Podcast: ";
    else
        podcast = @"";
    
    NSString *track_name = current.name;
    if (!track_name)
        return nil;
    
    NSString *track_artist = current.artist;
    if (![track_artist isEqualToString:@""])
        track_artist = [NSString stringWithFormat:@"- %@ ", track_artist];

    NSString *track_album = current.album;
    if (![track_album isEqualToString:@""])
        track_album = [NSString stringWithFormat:@"- %@ ", track_album];
    
    int track_rating_number = (int)current.rating/20;
    NSString *track_rating = @" Rating:";
    for(int i=0; i<track_rating_number; i++)
        track_rating = [track_rating stringByAppendingString:@"★"];
    for(int i=0; i<5-track_rating_number; i++)
        track_rating = [track_rating stringByAppendingString:@"☆"];
    
    return [NSString stringWithFormat:@"%@%@%@%@%@", podcast, track_name, track_artist, track_album, track_rating];
}

- (NSImage *)getTrackArtwork
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack *current = [iTunes currentTrack];
    
    iTunesArtwork *artwork = (iTunesArtwork *)[[[current artworks] get] lastObject];
    return [[NSImage alloc] initWithData:[artwork rawData]];
}

- (IBAction)shareUsingWeibo:(id)sender
{
    NSString *nowPlayingString = [self getNowPlayingInfo];
    if (!nowPlayingString){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"NowPlaying"];
        [alert setInformativeText:@"No Music Playing!"];
        [alert runModal]; 
        return;
    }
    else
        nowPlayingString = [NSString stringWithFormat:@"#NowPlaying#   %@", nowPlayingString];
    if (nowPlayingString.length >= 240) {
        nowPlayingString = [nowPlayingString substringToIndex:239];
    }
    NSMutableArray *shareItems = [[NSMutableArray alloc] initWithObjects:nowPlayingString, nil];
    if([self getTrackArtwork])
        [shareItems addObject:[self getTrackArtwork]];
    
    NSSharingService *weiboSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnSinaWeibo];
    weiboSharingService.delegate = self;
    self.weiboSharingService = weiboSharingService;
    [self.weiboSharingService performWithItems:shareItems];
}

- (IBAction)shareUsingTwitter:(id)sender
{
    NSString *nowPlayingString = [self getNowPlayingInfo];
    if (!nowPlayingString){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"NowPlaying"];
        [alert setInformativeText:@"No Music Playing!"];
        [alert runModal];
        return;
    }
    else
        nowPlayingString = [NSString stringWithFormat:@"#NowPlaying   %@", nowPlayingString];
    if (nowPlayingString.length >= 120) {
        nowPlayingString = [nowPlayingString substringToIndex:119];
    }
    NSMutableArray *shareItems = [[NSMutableArray alloc] initWithObjects:nowPlayingString, nil];
    if([self getTrackArtwork])
        [shareItems addObject:[self getTrackArtwork]];
    
    NSSharingService *twitterSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    twitterSharingService.delegate = self;
    self.twitterSharingService = twitterSharingService;
    [self.twitterSharingService performWithItems:shareItems];
}

- (IBAction)quit:(id)sender;
{
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)openPreferencePanel:(id)sender
{
//TODO: show preference window
    PreferenceWindow *preferenceWindow=[[PreferenceWindow alloc] initWithWindowNibName:@"PreferenceWindow"];
    [preferenceWindow loadWindow];
    [[preferenceWindow window] center];
    [[preferenceWindow window] resignFirstResponder];
}


@end
