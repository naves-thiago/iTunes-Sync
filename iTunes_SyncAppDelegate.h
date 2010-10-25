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
#define QTD_FIELDS 47

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

-(IBAction)play:(id)sender;
-(IBAction)list:(id)sender;
-(IBAction)retryiTunes:(id)sender;
-(IBAction)iTunesQuit:(id)sender;
-(IBAction)fill:(id)sender;
-(IBAction)abort:(id)sender;
-(IBAction)listDB:(id)sender;

-(void)openNoiTunesPanel;
-(void)closeNoiTunesPanel;
-(void)openLoadingPanel;
-(void)closeLoadingPanel;
-(void)animateProgress:(BOOL)anim;

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
	  row:(int)row;

-(void)displayError:(NSString *)message;
-(void)endErrorAndQuit:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
-(void)addObject:(id)obj toArray:(NSMutableArray *)array;

-(void)fillFields;
-(NSString *)selectSQL;
-(NSString *)insertSQL;

-(void)emptyDB;
-(void)fillDB;
-(void)readDB;

-(BOOL)createDB;
-(BOOL)backupDB;
-(BOOL)restoreDB;
-(BOOL)moveDB;
-(void)removeBackup;
@end
