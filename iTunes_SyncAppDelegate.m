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

	// Set main window size and position
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *f = [prefs objectForKey:@"frame"];
	if ( f != nil )
	{
		NSPoint pos;
		NSSize size;
		pos.x = [prefs floatForKey:@"windowX"];
		pos.y = [prefs floatForKey:@"windowY"];
		size.width = [prefs floatForKey:@"windowW"];
		size.height = [prefs floatForKey:@"windowH"];
		[window setFrame:NSMakeRect(pos.x, pos.y, size.width, size.height) display:YES];
	}
	
	// Show main window
	[window makeKeyAndOrderFront:self];
	
	// Open database
	db = [DB alloc];
	[[db init] retain];
	
	if ([db openDB:dbFile] == NO)
		[self displayError:@"Error: Could not open database."];
	
	// Look for iTunes
	itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	if ([itunes isRunning] == NO)
		[self openNoiTunesPanel];
	
	// Fill fields vector
	[self fillFields];
	
	// Set Threaded animation for loadProgress ( so it will animate )
	[loadProgress setUsesThreadedAnimation:YES];
}

- (void) endErrorAndQuit:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[NSApp terminate:nil];
}

-(void)addObject:(id)obj toArray:(NSMutableArray *)array
{
	if (obj != nil)
		[array addObject:obj];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return true;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	[db closeDB];
	[db release];
	
	// Record current window position
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setFloat:[window frame].origin.x forKey:@"windowX"];
	[prefs setFloat:[window frame].origin.y forKey:@"windowY"];
	[prefs setFloat:[window frame].size.width forKey:@"windowW"];
	[prefs setFloat:[window frame].size.height forKey:@"windowH"];
	[prefs setObject:@"saved" forKey:@"frame"];
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
	int ID;
	// Find which column we are at and return the value
	ID = [[tableColumn identifier] integerValue]-1;
	
	if ( ID != 29 ) // 29 -> Rating Field ID
		return [a objectAtIndex:ID];
	else
		return [NSString stringWithFormat:@"%d", [[a objectAtIndex:ID] integerValue] / 20];
	
	/*
	for ( i=0; i<[[tableView tableColumns] count]; i++ )
		if ( [tableColumn identifier] == [[[tableView tableColumns] objectAtIndex:i] identifier] )
			return [a objectAtIndex:i];
	*/
	// If the column was not found, retun nil ( also avoid annoing warning )
	return nil;
}

#pragma mark SQL Methods

-(void)fillFields
{
	int i;
	
	for (i=0; i<QTD_FIELDS; i++)
		fields[i].visible = NO;
	
	i=0;
	fields[i].type = FT_STRING;
	fields[i].name = @"name";
	fields[i].displayName = @"Title";
	fields[i].visible = YES;
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"album";
	fields[i].displayName = @"Album";
	fields[i].visible = YES;
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"albumArtist";
	fields[i].displayName = @"Album Artist";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"albumRating";
	fields[i].displayName = @"Album Rating";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"artist";
	fields[i].displayName = @"Artist";
	fields[i].visible = YES;
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"bitRate";
	fields[i].displayName = @"Bit Rate";
	i+=1;
	fields[i].type = FT_DOUBLE;
	fields[i].name = @"bookmark";
	fields[i].displayName = @"Bookmark";
	i+=1;
	fields[i].type = FT_BOOL;
	fields[i].name = @"bookmarkable";
	fields[i].displayName = @"Bookmarkable";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"bpm";
	fields[i].displayName = @"BPM";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"category";
	fields[i].displayName = @"Category";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"comment";
	fields[i].displayName = @"Comment";
	i+=1;
	fields[i].type = FT_BOOL;
	fields[i].name = @"compilation";
	fields[i].displayName = @"Compilation";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"composer";
	fields[i].displayName = @"Composer";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"databaseID";
	fields[i].displayName = @"Database ID";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"objectDescription";
	fields[i].displayName = @"Object Description";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"discCount";
	fields[i].displayName = @"Disc Count";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"discNumber";
	fields[i].displayName = @"Disc Number";
	i+=1;
	fields[i].type = FT_BOOL;
	fields[i].name = @"enabled";
	fields[i].displayName = @"Enabled";
	fields[i].visible = YES;
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"episodeID";
	fields[i].displayName = @"Episode ID";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"episodeNumber";
	fields[i].displayName = @"Episode Number";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"EQ";
	fields[i].displayName = @"EQ";
	i+=1;
	fields[i].type = FT_DOUBLE;
	fields[i].name = @"finish";
	fields[i].displayName = @"Finish";
	i+=1;
	fields[i].type = FT_BOOL;
	fields[i].name = @"gapless";
	fields[i].displayName = @"Gapless";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"genre";
	fields[i].displayName = @"Genre";
	fields[i].visible = YES;
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"grouping";
	fields[i].displayName = @"Grouping";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"longDescription";
	fields[i].displayName = @"Long Description";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"lyrics";
	fields[i].displayName = @"Lyrics";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"playedCount";
	fields[i].displayName = @"Played Count";
	i+=1;
	fields[i].type = FT_DATE;
	fields[i].name = @"playedDate";
	fields[i].displayName = @"Played Date";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"rating";
	fields[i].displayName = @"Rating";
	fields[i].visible = YES;
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"seasonNumber";
	fields[i].displayName = @"Season Number";
	i+=1;
	fields[i].type = FT_BOOL;
	fields[i].name = @"shufflable";
	fields[i].displayName = @"Shufflable";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"skippedCount";
	fields[i].displayName = @"Skipped Count";
	i+=1;
	fields[i].type = FT_DATE;
	fields[i].name = @"skippedDate";
	fields[i].displayName = @"Skipped Date";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"show";
	fields[i].displayName = @"Show";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"sortAlbum";
	fields[i].displayName = @"Sort Album";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"sortArtist";
	fields[i].displayName = @"Sort Artist";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"sortAlbumArtist";
	fields[i].displayName = @"Sort Album Artist";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"sortName";
	fields[i].displayName = @"Sort Name";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"sortComposer";
	fields[i].displayName = @"Sort Composer";
	i+=1;
	fields[i].type = FT_STRING;
	fields[i].name = @"sortShow";
	fields[i].displayName = @"Sort Show";
	i+=1;
	fields[i].type = FT_DOUBLE;
	fields[i].name = @"start";
	fields[i].displayName = @"Start";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"trackCount";
	fields[i].displayName = @"Track Count";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"trackNumber";
	fields[i].displayName = @"Track Number";
	i+=1;
	fields[i].type = FT_BOOL;
	fields[i].name = @"unplayed";
	fields[i].displayName = @"Unplayed";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"volumeAdjustment";
	fields[i].displayName = @"Volume Adjustment";
	i+=1;
	fields[i].type = FT_INTEGER;
	fields[i].name = @"year";
	fields[i].displayName = @"Year";	
}

-(NSString *)selectSQL
{
	// Generate select SQL statement based on fields vector
	int i;
	NSString *sql = @"select ";
	
	for (i=0; i<QTD_FIELDS-1; i++)
		sql = [sql stringByAppendingFormat:@"%@,", fields[i].name];
	
	sql = [sql stringByAppendingFormat:@"%@ from music", fields[QTD_FIELDS-1].name];
	return sql;
}

-(NSString *)insertSQL
{
	// Generate insert SQL statement based on fields vector
	int i;
	NSString *sql = @"insert into music (";
	
	for (i=0; i<QTD_FIELDS-1; i++)
		sql = [sql stringByAppendingFormat:@"%@,", fields[i].name];
	
	sql = [sql stringByAppendingFormat:@"%@) values (", fields[QTD_FIELDS-1].name];
	
	for (i=1; i<QTD_FIELDS; i++)
		sql = [sql stringByAppendingFormat:@"?%03d,", i];
	
	sql = [sql stringByAppendingFormat:@"?%03d)", QTD_FIELDS];
	
	return sql;
}

#pragma mark Find iTunes Panel buttons

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

#pragma mark Main Window buttons

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

-(IBAction)defaultCols:(id)sender
{
	[self setDefaultVisibleColumns];
}

-(void)setDefaultVisibleColumns
{
	int i;
	
	// Create a cell for rating
	NSLevelIndicatorCell * cell;
	cell = [[NSLevelIndicatorCell alloc] init];
	[cell setLevelIndicatorStyle:NSRatingLevelIndicatorStyle];
	[cell setIntValue:0];
	[cell setMaxValue:5.0];
	[cell setMinValue:0.0];
	
	// Clear current columns
	while ( [[grid tableColumns] count] > 0 )
		[grid removeTableColumn:[[grid tableColumns] objectAtIndex:0]];
	
	// Add new columns
	NSTableColumn *col;
	for (i=0; i<QTD_FIELDS; i++)
		if ( fields[i].visible )
		{
			col = [[NSTableColumn alloc] init];
			[col setIdentifier:[NSString stringWithFormat:@"%d", i+1]];
			[[col headerCell] setStringValue:fields[i].displayName];
			
			if ( [fields[i].name isEqualToString:@"rating"] )
				[col setDataCell:cell];
			
			[grid addTableColumn:col];
			[col release];
		}
	
	[cell release];
}

#pragma mark Show Panel Methods

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

#pragma mark DB Methods

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
	
	// Create SQL statement
	NSString *sql;
	sql = [self insertSQL];
	
	// Iterate
	iTunesTrack *track; // Iterator
	
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
		[db bindString:track.name toId: 1];
		[db bindString:track.album toId: 2];
		[db bindString:track.albumArtist toId: 3];
		[db bindInteger:track.albumRating toId: 4];
		[db bindString:track.artist toId: 5];
		[db bindInteger:track.bitRate toId: 6];
		[db bindDouble:track.bookmark toId: 7];
		[db bindBoolean:track.bookmarkable toId: 8];
		[db bindInteger:track.bpm toId: 9];
		[db bindString:track.category toId: 10];
		[db bindString:track.comment toId: 11];
		[db bindBoolean:track.compilation toId: 12];
		[db bindString:track.composer toId: 13];
		[db bindInteger:track.databaseID toId: 14];
		[db bindString:track.objectDescription toId: 15];
		[db bindInteger:track.discCount toId: 16];
		[db bindInteger:track.discNumber toId: 17];
		[db bindBoolean:track.enabled toId: 18];
		[db bindString:track.episodeID toId: 19];
		[db bindInteger:track.episodeNumber toId: 20];
		[db bindString:track.EQ toId: 21];
		[db bindDouble:track.finish toId: 22];
		[db bindBoolean:track.gapless toId: 23];
		[db bindString:track.genre toId: 24];
		[db bindString:track.grouping toId: 25];
		[db bindString:track.longDescription toId: 26];
		[db bindString:track.lyrics toId: 27];
		[db bindInteger:track.playedCount toId: 28];
		[db bindDate:track.playedDate toId: 29];
		[db bindInteger:track.rating toId: 30];
		[db bindInteger:track.seasonNumber toId: 31];
		[db bindBoolean:track.shufflable toId: 32];
		[db bindInteger:track.skippedCount toId: 33];
		[db bindDate:track.skippedDate toId: 34];
		[db bindString:track.show toId: 35];
		[db bindString:track.sortAlbum toId: 36];
		[db bindString:track.sortArtist toId: 37];
		[db bindString:track.sortAlbumArtist toId: 38];
		[db bindString:track.sortName toId: 39];
		[db bindString:track.sortComposer toId: 40];
		[db bindString:track.sortShow toId: 41];
		[db bindDouble:track.start toId: 42];
		[db bindInteger:track.trackCount toId: 43];
		[db bindInteger:track.trackNumber toId: 44];
		[db bindBoolean:track.unplayed toId: 45];
		[db bindInteger:track.volumeAdjustment toId: 46];
		[db bindInteger:track.year toId: 47];		
		
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
	[db prepareSQL:[self selectSQL]];
	
	NSMutableArray *array; // Buffer
	int i;				   // Loop
	
	while ([db next])
	{
		array = [[NSMutableArray alloc] init];
		
		for (i=0; i<QTD_FIELDS; i++)
		{
			if (( fields[i].type == FT_STRING ) || ( fields[i].type == FT_DATE ))
				[self addObject:[db fieldString:i] toArray:array];
			else if ( fields[i].type == FT_INTEGER )
				[array addObject:[NSString stringWithFormat:@"%d", [db fieldInt:i]]];
			else if ( fields[i].type == FT_DOUBLE )
				[array addObject:[NSString stringWithFormat:@"%f", [db fieldDouble:i]]];
			else if ( fields[i].type == FT_BOOL )
				[array addObject:[db fieldBoolean:i] ? @"True":@"False"];
		}
		
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
