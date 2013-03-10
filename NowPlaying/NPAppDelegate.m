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
@synthesize login;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSLog(@"Lauching!");
    if([self isAppFromLoginItem])
        [[self login] setState:NSOnState];
    else
        [[self login] setState:NSOffState];
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

- (IBAction)changeStatus:(id)sender
{
    if([self isAppFromLoginItem])
    {
        [[self login] setState:NSOffState];
        [self deleteAppFromLoginItem];
    }
    else
    {
        [[self login] setState:NSOnState];
        [self addAppAsLoginItem];
    }
}


-(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

- (BOOL)isAppFromLoginItem{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    BOOL flag = false;
    if (loginItems)
    {
        UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                                         objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
                NSLog(@"%@", urlPath);
				if ([urlPath compare:appPath] == NSOrderedSame)
                    flag = true;
			}
		}
	}    
    return flag;
}


@end
