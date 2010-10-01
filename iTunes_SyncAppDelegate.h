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

@interface iTunes_SyncAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSWindow *noiTunesPannel;
	NSString *saveDir;
	NSString *dbDir;
	IBOutlet NSTableView *grid;
	NSMutableArray *dataset;
	DB *db;
	iTunesApplication* itunes;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *noiTunesPannel;

-(IBAction)play:(id)sender;
-(IBAction)list:(id)sender;
-(IBAction)retryiTunes:(id)sender;
-(IBAction)iTunesQuit:(id)sender;
-(IBAction)fill:(id)sender;

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
	  row:(int)row;
- (void)endOpenDBMessage:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)emptyDB;
- (void)fillDB;
- (void)readDB;

@end
