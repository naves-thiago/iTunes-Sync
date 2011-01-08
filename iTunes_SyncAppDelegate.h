//
//  iTunes_SyncAppDelegate.h
//  iTunes Sync
//
//  Created by Thiago Naves on 27/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "DB.h"

#define	ITUNES_USER_LIB 0
#define ITUNES_MUSIC 0
#define QTD_FIELDS 48

typedef enum Field_type {
	FT_STRING,
	FT_BOOL,
	FT_DATE,
	FT_DOUBLE,
	FT_INTEGER
} field_type;

typedef struct Field
{
	NSString *name;
	NSString *displayName;
	field_type type;
	BOOL visible;
} field;

@interface iTunes_SyncAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;			// Main window
	NSWindow *noiTunesPanel;	// iTunes not open error panel
	NSWindow *loadingPanel;		// Loading panel
	
	IBOutlet NSTableView *grid;					// Main display grid
	IBOutlet NSProgressIndicator *loadProgress; // Progress bar in loading panel
	IBOutlet NSImageView *loadImage;			// Image in loading panel
	
	NSString *saveDir;				// Save DB path ( folder only )
	NSString *dbFile;				// DB file path
	NSString *bakDir;				// Backup DB file path
	NSMutableArray *dataset;		// Buffer to store the grid data
	DB *db;							// Database handle
	iTunesApplication* itunes;		// iTunes handle
	BOOL abortFlag;					// I.e. the abort button has been clicked
	field fields[QTD_FIELDS];		// List of supported music properties
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *noiTunesPanel;
@property (assign) IBOutlet NSWindow *loadingPanel;

// Play / Pause button
-(IBAction)play:(id)sender;

// List button ( displays the iTunes music Library data on the table view )
-(IBAction)list:(id)sender;
-(void)listTraks;

// No iTunes Panel buttons
-(IBAction)retryiTunes:(id)sender;
-(IBAction)iTunesQuit:(id)sender;

// Fill DB button ( calls fillDB method )
-(IBAction)fill:(id)sender;

// Loading panel abort button
-(IBAction)abort:(id)sender;

// ListDB button ( shows DB data on the table view )
-(IBAction)listDB:(id)sender;

// Changes current visible columns to those set as default on the fields vector
-(IBAction)defaultCols:(id)sender;
-(void)setDefaultVisibleColumns;

// If iTunes is not open ask user what to do
-(void)openNoiTunesPanel;
-(void)closeNoiTunesPanel;

// Show the progress of a slow process
-(void)openLoadingPanel;
-(void)closeLoadingPanel;

// If anime = YES sets the progress indicator as indeterminate
-(void)animateProgress:(BOOL)anim;

// Table view ( dataset ) methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
	  row:(int)row;

// Display an Alert Panel with a error message
-(void)displayError:(NSString *)message;

// Close the error message and quit app
-(void)endErrorAndQuit:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// Helper method to add objects to the array ( avoids problems with null objects )
-(void)addObject:(id)obj toArray:(NSMutableArray *)array;

// Fill the fields vector with supported song properties
-(void)fillFields;

// Returns the select SQL statement based on the fields vector
-(NSString *)selectSQL;

// Returns the insert SQL statement based on the fields vector
-(NSString *)insertSQL;

// Deletes all rows from music table
-(void)emptyDB;

// Helper function to fill parameters data from the track properties
-(void)bindTrack:(iTunesTrack *)track;

// Reads iTunes music library and stores the data in the DB
-(void)fillDB;

// Reads the DB and display the data on the table view
-(void)readDB;

// Creates an writable copy of the default ( empty ) DB
-(BOOL)createDB;

// Copy the current DB to a temporary file
-(BOOL)backupDB;

// Move the current DB to a temporary file
-(BOOL)moveDB;

// Restores the backup DB to the current working file
-(BOOL)restoreDB;

// Delete the temporary DB file
-(void)removeBackup;

// Reads the iTunes Library and compares with the old Library stored in the DB
-(void)makeDiff;

// Clears the Diff table to start a new sync
-(void)clearDiffTable;

@end
