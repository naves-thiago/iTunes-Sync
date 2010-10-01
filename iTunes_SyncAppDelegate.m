//
//  iTunes_SyncAppDelegate.m
//  iTunes Sync
//
//  Created by Thiago Naves on 27/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iTunes_SyncAppDelegate.h"

@implementation iTunes_SyncAppDelegate

@synthesize window, noiTunesPannel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	dataset = [[NSMutableArray alloc] init];
	saveDir = @"~/Library/Application Support/iTunes Sync/";
	saveDir = [saveDir stringByExpandingTildeInPath];
	dbDir = [saveDir stringByAppendingPathComponent:@"sync.db"];
	
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// Create the iTunes Sync folder
	if ([fileManager fileExistsAtPath: saveDir] == NO) 
		[fileManager createDirectoryAtPath:saveDir withIntermediateDirectories:YES attributes:nil error:nil];
	
	// Copy the default ( empty ) db
	if ([fileManager fileExistsAtPath:dbDir] == NO )
	{
		NSBundle *mainBundle = [NSBundle mainBundle];
		[fileManager copyItemAtPath:[mainBundle pathForResource:@"sync" ofType:@"db"] toPath:dbDir error:nil];		
	}
	
	// Test if copy was successiful
	if ([fileManager fileExistsAtPath:dbDir] == NO )
	{
		// Show a error message
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:[NSString stringWithFormat:@"Error: Could not create database at path: %@", saveDir]];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(endOpenDBMessage:returnCode:contextInfo:) contextInfo:nil];
	}
	
	// Open database
	db = [DB alloc];
	[[db init] retain];
	
	if ([db openDB:dbDir] == NO)
	{
		// Show a error message
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"Error: Could not open database."];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(endOpenDBMessage:returnCode:contextInfo:) contextInfo:nil];
	}
	
	// Look for iTunes
	itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	if ([itunes isRunning] == NO)
	{
		[NSApp beginSheet:noiTunesPannel
		    modalForWindow:[self window] modalDelegate:self
			didEndSelector:nil
			contextInfo:nil];
	}
	
}

-(IBAction)retryiTunes:(id)sender
{
	if ([itunes isRunning])
	{
		[noiTunesPannel orderOut:self];
		[NSApp endSheet:noiTunesPannel];
	}
}

-(IBAction)iTunesQuit:(id)sender
{
	[noiTunesPannel orderOut:self];
	[NSApp endSheet:noiTunesPannel];
	[NSApp terminate:nil];
}

- (void) endOpenDBMessage:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[NSApp terminate:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return true;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	[db closeDB];
	[db release];
}

-(IBAction)play:(id)sender
{
	[itunes playpause];
}

-(IBAction)list:(id)sender
{
	// Show iTunes music library on the gird
	
	// Clear dataset
	[dataset removeAllObjects];
	
	// Get the tracks
	SBElementArray *tracks = [[[[[itunes sources] objectAtIndex:0] userPlaylists] objectAtIndex:0] fileTracks];

	// Iterate
	iTunesTrack * track;
	for ( track in tracks )
		[dataset addObject:[NSString stringWithString:track.name]];
	
//	for (int i=0; i<[tracks count]; i++ )
//		[dataset addObject:[NSString stringWithString:[[tracks objectAtIndex:i] title]]];

	// Tell grid to reload
	[grid reloadData];
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

- (void)emptyDB
{
	[db execSQL:@"delete from music"];
}

- (void)fillDB
{
	// Copy iTunes' Music Library to DB
	
	// Clear DB
	[self emptyDB];
	
	// Get Tracks
	SBElementArray *tracks = [[[[[itunes sources] objectAtIndex:0] userPlaylists] objectAtIndex:0] fileTracks];
	
	// Iterate
	iTunesTrack *track; // Iterator
	NSString *sql; // SQL command
	for ( track in tracks )
	{
		sql = [NSString stringWithFormat:@"insert into music (title, artist) values (\"%@\", \"%@\")", [db encodeString:track.name], [db encodeString:track.artist]];
		if ([db execSQL:sql] == NO)
		{
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Error"];
			[alert setInformativeText:[NSString stringWithFormat:@"Could not add song %@ to database.\nError: %@", track.name, [db error]]];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(endOpenDBMessage:returnCode:contextInfo:) contextInfo:nil];
			break;
		}
		[db next];
		[db endExec];		
	}
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Fill DB:"];
	[alert setInformativeText:@"Done."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)readDB
{
	
}

-(IBAction)fill:(id)sender
{
	[self fillDB];
}

@end
