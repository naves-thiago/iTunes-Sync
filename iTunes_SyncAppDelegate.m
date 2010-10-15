//
//  iTunes_SyncAppDelegate.m
//  iTunes Sync
//
//  Created by Thiago Naves on 27/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iTunes_SyncAppDelegate.h"

@implementation iTunes_SyncAppDelegate

@synthesize window, noiTunesPanel, loadingPanel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	dataset = [[NSMutableArray alloc] init];
	saveDir = @"~/Library/Application Support/iTunes Sync/";
	saveDir =[[saveDir stringByExpandingTildeInPath] retain];
	dbFile = [[saveDir stringByAppendingPathComponent:@"sync.db"] retain];
	bakDir = [[saveDir stringByAppendingPathComponent:@"sync.bak"] retain];
	
	// Open database
	db = [DB alloc];
	[[db init] retain];
	
	if ([db openDB:dbFile] == NO)
		[self displayError:@"Error: Could not open database."];
	
	// Look for iTunes
	itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	if ([itunes isRunning] == NO)
		[self openNoiTunesPanel];
}

- (void) endErrorAndQuit:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
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

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [dataset count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(int)row
{
	NSMutableArray * a = [dataset objectAtIndex:row];
	int i;
	
	// Find which column we are at and return the value
	for ( i=0; i<[[tableView tableColumns] count]; i++ )
		if ( [tableColumn identifier] == [[[tableView tableColumns] objectAtIndex:i] identifier] )
			return [a objectAtIndex:i];
	
	// If the column was not found, retun nil ( also avoid annoing warning )
	return nil;
}

-(IBAction)retryiTunes:(id)sender
{
	// Check if iTunes is open
	if ([itunes isRunning])
		[self closeNoiTunesPanel];
}

-(IBAction)iTunesQuit:(id)sender
{
	[self closeNoiTunesPanel];
	[NSApp terminate:nil];
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

-(IBAction)fill:(id)sender
{
	// Show loading sheet
	[self openLoadingPanel];
	
	// Start filling DB
	[NSThread detachNewThreadSelector:@selector(fillDB) toTarget:self withObject:nil];
}

-(IBAction)abort:(id)sender
{
	abortFlag = TRUE;
}

-(IBAction)listDB:(id)sender
{
	// Show loading panel
	[self openLoadingPanel];
	
	// Start loading db on a separate thread
	[NSThread detachNewThreadSelector:@selector(readDB) toTarget:self withObject:nil];
}

-(void)displayError:(NSString *)message
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Error"];
	[alert setInformativeText:message];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(endErrorAndQuit:returnCode:contextInfo:) contextInfo:nil];
}

-(void)openNoiTunesPanel
{
	[NSApp beginSheet:noiTunesPanel
	   modalForWindow:[self window] modalDelegate:self
	   didEndSelector:nil
		  contextInfo:nil];
}

-(void)closeNoiTunesPanel
{
	[noiTunesPanel orderOut:self];
	[NSApp endSheet:noiTunesPanel];
}

-(void)openLoadingPanel
{
	[NSApp beginSheet:loadingPanel
	   modalForWindow:[self window] modalDelegate:self
	   didEndSelector:nil
		  contextInfo:nil];
}

-(void)closeLoadingPanel
{
	[loadingPanel orderOut:self];
	[NSApp endSheet:loadingPanel];
}

-(void)animateProgress:(BOOL)anim
{
	if ( anim )
	{
		[loadProgress setIndeterminate:TRUE];
		[loadProgress startAnimation:self];
	}
	else
	{
		[loadProgress stopAnimation:self];
		[loadProgress setIndeterminate:FALSE];
	}
}

-(BOOL)createDB
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// Create the iTunes Sync folder
	if ([fileManager fileExistsAtPath: saveDir] == NO) 
		[fileManager createDirectoryAtPath:saveDir withIntermediateDirectories:YES attributes:nil error:nil];
	
	// Copy the default ( empty ) db
	if ([fileManager fileExistsAtPath:dbFile] == NO )
	{
		NSBundle *mainBundle = [NSBundle mainBundle];
		[fileManager copyItemAtPath:[mainBundle pathForResource:@"sync" ofType:@"db"] toPath:dbFile error:nil];		
	}
	
	// Test if copy was successiful
	if ([fileManager fileExistsAtPath:dbFile] == NO )
	{
		[self displayError:[NSString stringWithFormat:@"Error: Could not create database at path: %@", saveDir]];
		return NO;
	}
	
	return YES;
		
}

-(BOOL)backupDB
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// If theres already a backup, delete it first
	[fileManager removeItemAtPath:bakDir error:nil];
	
	// Copy current DB to a temporary file
	[fileManager copyItemAtPath:dbFile toPath:bakDir error:nil];
	
	// Check if move was successiful
	if ( [fileManager fileExistsAtPath:bakDir] == NO )
	{
		[self displayError:[NSString stringWithFormat:@"Error: Could not backup database at path: %@", saveDir]];
		return NO;
	}
	
	return YES;
}

-(BOOL)restoreDB
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// Check if backup does not exsist
	if ( [fileManager fileExistsAtPath:bakDir] == NO )
	{
		[self displayError:@"Backup not found."];
		return NO;
	}
		
	// Close db
	[db closeDB];
	
	// Delete current DB file
	[fileManager removeItemAtPath:dbFile error:nil];
	
	// Restore backup
	[fileManager moveItemAtPath:bakDir toPath:dbFile error:nil];
	
	// Open DB
	[db openDB:dbFile];
	
	return YES;
}

- (void)emptyDB
{
	[db prepareSQL:@"delete from music"];
	[db execute];
}

-(BOOL)moveDB
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// If theres already a backup, delete it first
	[fileManager removeItemAtPath:bakDir error:nil];

	// Close db
	[db closeDB];
	
	// Move current DB to a temporary file
	[fileManager moveItemAtPath:dbFile toPath:bakDir error:nil];
	
	// Check if move was successiful
	if ( [fileManager fileExistsAtPath:bakDir] == NO )
	{
		[self displayError:[NSString stringWithFormat:@"Error: Could not backup database at path: %@", saveDir]];
		return NO;
	}

	// Create a new DB file to work with
	[self createDB];
	
	// Open new DB
	[db openDB:dbFile];
	
	return YES;
}

-(void)removeBackup
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// If theres already a backup, delete it first
	[fileManager removeItemAtPath:bakDir error:nil];
}

- (void)fillDB
{
	// Copy iTunes' Music Library to DB
	
	// Create a auto release pool, since we are running on a thread
	[[NSAutoreleasePool alloc] init];
	
	// Error flag ( delete backup or restore it ? )
	BOOL fError = NO;
	
	// Move DB
	if ([self moveDB] == NO)
		return;
	
	// Get Tracks
	SBElementArray *tracks = [[[[[itunes sources] objectAtIndex:0] userPlaylists] objectAtIndex:0] fileTracks];
	
	// Set progress indicator
	[loadProgress setMaxValue:(double)[tracks count]];
	[loadProgress setDoubleValue:0.0];
	
	// Iterate
	iTunesTrack *track; // Iterator
	NSString *sql; // SQL command
	
	for ( track in tracks )
	{
		// Check abort flag
		if ( abortFlag )
		{
			// Stop current DB operation
			[db endExec];
			
			// Restore DB backup
			[self restoreDB];
			
			// Close the panel
			[self closeLoadingPanel];
			
			return;
		}
		
		// Create SQL statement
		sql = @"insert into music (name, artist, album) values ( ?1, ?2, ?3 )";
		
		
		// Prepare the SQL
		if ([db prepareSQL:sql] == NO)
		{
			// In case of an error, display it
			[self closeLoadingPanel];
			[self displayError:[NSString stringWithFormat:@"Could not prepare database.\nTrack: %@\nError: %@", track.name, [db error]]];
			
			// Set error flag
			fError = YES;
			
			break;
		}
		
		// Replace the parameters
		[db bindString:track.name toId:1];
		[db bindString:track.artist toId:2];
		[db bindString:track.album toId:3];
		
		// Try to execute SQL
		if ([db execute] == NO)	
		{
			// In case of an error, display it
			[self closeLoadingPanel];
			[self displayError:[NSString stringWithFormat:@"Could not add song %@ to database.\nError: %@", track.name, [db error]]];
			
			// Set error flag
			fError = YES;
			
			break;
		}
		
		[db endExec];
		[loadProgress incrementBy:1];
	}
	
	// Check for errors
	if (fError)
		[self restoreDB];
	else
		[self removeBackup];
	
	[self closeLoadingPanel];
	
	// Display Done message
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Fill DB:"];
	[alert setInformativeText:@"Done."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)readDB
{
	// Display data stored on DB in the grid
	
	// Create a auto release pool, since we are running on a thread
	[[NSAutoreleasePool alloc] init];
	
	// Clear current grid data
	[dataset removeAllObjects];
	
	// Set progress indicator
	[self animateProgress:YES];
	
	// Iterate
	[db prepareSQL:@"select name, artist, album from music"];
	
	NSMutableArray *array; // Buffer
	
	while ([db next])
	{
		array = [[NSMutableArray alloc] init];
		[array addObject:[NSString stringWithString:[db fieldString:0]]];
		[array addObject:[NSString stringWithString:[db fieldString:1]]];
		[array addObject:[NSString stringWithString:[db fieldString:2]]];

		[dataset addObject:array];
	}

	[db endExec];
	
	// Refresh grid
	[grid reloadData];
	
	// Stop animation and close panel
	[self animateProgress:NO];
	[self closeLoadingPanel];
	
	// Display Done message
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Fill DB:"];
	[alert setInformativeText:@"Done."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
