//
//  NPAppDelegate.m
//  NowPlaying
//
//  Created by SunWenxiang on 3/4/13.
//  Copyright (c) 2013 SunWenxiang. All rights reserved.
//

#import "NPAppDelegate.h"
NSString * const ShouldShowArtist = @"showArtist";
NSString * const ShouldShowAlbum = @"showAlbum";
NSString * const ShouldShowArtwork = @"showArtWork";
NSString * const ShouldShowRating = @"showRating";
NSString * const ShouldShowURL = @"showURL";

@interface NPAppDelegate()

@property (strong) NSSharingService *weiboSharingService;
@property (strong) NSSharingService *twitterSharingService;
@property (strong) NSSharingService *facebookSharingService;

@end

@implementation NPAppDelegate
@synthesize login;
@synthesize showArtistMenuItem;
@synthesize showAlbumMenuItem;
@synthesize showArtworkMenuItem;
@synthesize showRatingMenuItem;
@synthesize showShareURLMenuItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (void)awakeFromNib{
    if([self isAppFromLoginItem])
        [[self login] setState:NSOnState];
    else
        [[self login] setState:NSOffState];
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtwork] == YES)
        [showArtworkMenuItem setState:NSOnState];
    else
        [showArtworkMenuItem setState:NSOffState];
    
    if ([accountDefaults boolForKey:ShouldShowArtist] == YES)
        [showArtistMenuItem setState:NSOnState];
    else
        [showArtistMenuItem setState:NSOffState];
    
    if ([accountDefaults boolForKey:ShouldShowAlbum] == YES)
        [showAlbumMenuItem setState:NSOnState];
    else
        [showAlbumMenuItem setState:NSOffState];
    
    if ([accountDefaults boolForKey:ShouldShowRating] == YES)
        [showRatingMenuItem setState:NSOnState];
    else
        [showRatingMenuItem setState:NSOffState];
    
    if ([accountDefaults boolForKey:ShouldShowURL] == YES)
        [showShareURLMenuItem setState:NSOnState];
    else
        [showShareURLMenuItem setState:NSOffState];

    
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
    
    NSString *track_artist = @"";
    NSString *track_album = @"";
    NSString *track_rating = @"";
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtist] == YES)
    {
        track_artist = current.artist;
        if (![track_artist isEqualToString:@""])
            track_artist = [NSString stringWithFormat:@"- %@ ", track_artist];
    }

    if ([accountDefaults boolForKey:ShouldShowAlbum] == YES)
    {
        track_album = current.album;
        if (![track_album isEqualToString:@""])
            track_album = [NSString stringWithFormat:@"- %@ ", track_album];
    }
    
    if ([accountDefaults boolForKey:ShouldShowRating] == YES)
    {
        int track_rating_number = (int)current.rating/20;
        track_rating = @" Rating:";
        for(int i=0; i<track_rating_number; i++)
            track_rating = [track_rating stringByAppendingString:@"★"];
        if((current.rating%20) != 0)
            track_rating = [track_rating stringByAppendingString:@"½"];
    }
        
    return [NSString stringWithFormat:@"%@%@%@%@%@", podcast, track_name, track_artist, track_album, track_rating];
}

- (NSImage *)getTrackArtwork
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack *current = [iTunes currentTrack];
    
    iTunesArtwork *artwork = (iTunesArtwork *)[[[current artworks] get] lastObject];
    return [[NSImage alloc] initWithData:[artwork rawData]];
}

- (NSRect) sharingService: (NSSharingService *) sharingService
sourceFrameOnScreenForShareItem: (id<NSPasteboardWriting>) item
{
    if([item isKindOfClass: [NSURL class]])
    {
        //return a rect from where the image will fly
        return NSZeroRect;
    }
    
    return NSZeroRect;
}

- (NSImage *) sharingService: (NSSharingService *) sharingService
 transitionImageForShareItem: (id <NSPasteboardWriting>) item
                 contentRect: (NSRect *) contentRect
{
    if([item isKindOfClass: [NSURL class]])
    {
        
        return [self getTrackArtwork];
    }
    
    return nil;
}


//- (NSString *)getShareURL
//{
//    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
//    iTunesTrack *current = [iTunes currentTrack];
//
//    NSString *track_name = current.name;
//   
//    NSString *searchURL = @"http://music.douban.com/subject_search?search_text=";
//    NSString *track_name_decoded = [track_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    return [NSString stringWithFormat:@"[%@%@&cat=1003]", searchURL, track_name_decoded];
//}

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

    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtwork] == YES)
    {
        if([self getTrackArtwork])
            [shareItems addObject:[self getTrackArtwork]];
    }
    
//    if ([accountDefaults boolForKey:ShouldShowURL] == YES)
//        [shareItems addObject:[self getShareURL]];
    
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
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtwork] == YES)
    {
        if([self getTrackArtwork])
            [shareItems addObject:[self getTrackArtwork]];
    }
    
    NSSharingService *twitterSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    twitterSharingService.delegate = self;
    self.twitterSharingService = twitterSharingService;
    [self.twitterSharingService performWithItems:shareItems];
}

- (IBAction)shareUsingFacebook:(id)sender
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
        nowPlayingString = [NSString stringWithFormat:@"I'm Listening :%@", nowPlayingString];
    if (nowPlayingString.length >= 240) {
        nowPlayingString = [nowPlayingString substringToIndex:239];
    }
    NSMutableArray *shareItems = [[NSMutableArray alloc] initWithObjects:nowPlayingString, nil];
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtwork] == YES)
    {
            if([self getTrackArtwork])
                [shareItems addObject:[self getTrackArtwork]];
    }
    
    NSSharingService *twitterSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    twitterSharingService.delegate = self;
    self.facebookSharingService = twitterSharingService;
    [self.facebookSharingService performWithItems:shareItems];
}

- (IBAction)quit:(id)sender;
{
    [[NSApplication sharedApplication] terminate:nil];
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

	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
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
    
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;

		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);

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
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                                         objectAtIndex:i]);
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
                if ([urlPath compare:appPath] == NSOrderedSame)
                    flag = true;
			}
		}
	}    
    return flag;
}

- (IBAction)showArtist:(id)sender
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtist] == YES)
    {
        [showArtistMenuItem setState:NSOffState];
        [accountDefaults setBool:NO forKey:ShouldShowArtist];
    }
    else
    {
        [showArtistMenuItem setState:NSOnState];
        [accountDefaults setBool:YES forKey:ShouldShowArtist];
    }

}

- (IBAction)showAlbum:(id)sender
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowAlbum] == YES)
    {
        [showAlbumMenuItem setState:NSOffState];
        [accountDefaults setBool:NO forKey:ShouldShowAlbum];
    }
    else
    {
        [showAlbumMenuItem setState:NSOnState];
        [accountDefaults setBool:YES forKey:ShouldShowAlbum];
    }
}

- (IBAction)showArtwork:(id)sender
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowArtwork] == YES)
    {
        [showArtworkMenuItem setState:NSOffState];
        [accountDefaults setBool:NO forKey:ShouldShowArtwork];
    }
    else
    {
        [showArtworkMenuItem setState:NSOnState];
        [accountDefaults setBool:YES forKey:ShouldShowArtwork];
    }
}

- (IBAction)showRating:(id)sender
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowRating] == YES)
    {
        [showRatingMenuItem setState:NSOffState];
        [accountDefaults setBool:NO forKey:ShouldShowRating];
    }
    else
    {
        [showRatingMenuItem setState:NSOnState];
        [accountDefaults setBool:YES forKey:ShouldShowRating];
    }
}

- (IBAction)showURL:(id)sender
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([accountDefaults boolForKey:ShouldShowURL] == YES)
    {
        [showShareURLMenuItem setState:NSOffState];
        [accountDefaults setBool:NO forKey:ShouldShowURL];
    }
    else
    {
        [showShareURLMenuItem setState:NSOnState];
        [accountDefaults setBool:YES forKey:ShouldShowURL];
    }
}



@end
