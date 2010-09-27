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
	IBOutlet NSButton *pp;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)play:(id)sender;

@end
