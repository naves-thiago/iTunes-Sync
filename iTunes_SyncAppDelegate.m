//
//  iTunes_SyncAppDelegate.m
//  iTunes Sync
//
//  Created by Thiago Naves on 27/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iTunes_SyncAppDelegate.h"

@implementation iTunes_SyncAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	dataset = [[NSMutableArray alloc] init];
	saveDir = @"~/Library/Application Support/iTunes Sync/";
	saveDir = [saveDir stringByExpandingTildeInPath];
	dbDir = [saveDir stringByAppendingPathComponent:@"sync.db"];
	
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if ([fileManager fileExistsAtPath: saveDir] == NO) 
	{ 
		// Create the iTunes Sync folder
		[fileManager createDirectoryAtPath:saveDir withIntermediateDirectories:YES attributes:nil error:nil];
	} 
	
	if ([fileManager fileExistsAtPath:dbDir] == NO )
	{
		// Copy the default ( empty ) db
		NSBundle *mainBundle = [NSBundle mainBundle];
		[fileManager copyItemAtPath:[mainBundle pathForResource:@"sync" ofType:@"db"] toPath:dbDir error:nil];		
	}
}

- (void) endShowMessage:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if ([alert messageText] == @"Error")
		[[NSApplication alloc] terminate:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return true;
}

-(IBAction)play:(id)sender
{
	iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	
	// check if iTunes is running
	if ([iTunes isRunning])
	{
		[iTunes playpause];
	}	
}

-(IBAction)list:(id)sender
{
	iTunesApplication* itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	
	// check if iTunes is running
	if ([itunes isRunning])
	{
		[dataset removeAllObjects];
		SBElementArray *tracks = [[[[[itunes sources] objectAtIndex:0] userPlaylists] objectAtIndex:0] fileTracks];

		iTunesTrack * track;
		for ( track in tracks )
			[dataset addObject:[NSString stringWithString:track.name]];
		
//		for (int i=0; i<[tracks count]; i++ )
//			[dataset addObject:[NSString stringWithString:[[tracks objectAtIndex:i] title]]];
		
		
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert setMessageText:@"Sheet Title"];
		[alert setInformativeText:[NSString stringWithFormat:@"%d", [tracks	count]]];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
		
		[grid reloadData];
	}
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [dataset count];
}

- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row
{
    return [dataset objectAtIndex:row];
}

@end
