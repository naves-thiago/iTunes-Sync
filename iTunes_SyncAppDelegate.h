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
	NSWindow *noiTunesPanel;
	NSWindow *loadingPanel;
	IBOutlet NSTableView *grid;
	IBOutlet NSProgressIndicator *loadProgress;
	IBOutlet NSImageView *loadImage;
	NSString *saveDir;
	NSString *dbDir;
	NSMutableArray *dataset;
	DB *db;
	iTunesApplication* itunes;
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

-(void)openNoiTunesPanel;
-(void)closeNoiTunesPanel;
-(void)openLoadingPanel;
-(void)closeLoadingPanel;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
	  row:(int)row;
- (void)endOpenDBMessage:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)emptyDB;
- (void)fillDB;
- (void)readDB;

@end
