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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
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

@end
