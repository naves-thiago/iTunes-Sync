//
//  iTunes_SyncAppDelegate.h
//  iTunes Sync
//
//  Created by Thiago Naves on 27/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"

@interface iTunes_SyncAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSString *saveDir;
	NSString *dbDir;
	IBOutlet NSTableView *grid;
	NSMutableArray *dataset;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)play:(id)sender;
-(IBAction)list:(id)sender;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
	  row:(int)row;
- (void) endShowMessage:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
