//
//  DB.h
//  iTunes Sync
//
//  Created by Thiago Naves on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>

@interface DB : NSObject {
	sqlite3 *database;
	NSString *path;
	sqlite3_stmt *statement;
}

-(BOOL)openDB:(NSString *)fileName;
-(BOOL)execSQL:(NSString *)sql;
-(BOOL)next;
-(NSString *)fieldString:(int)ID;
-(int)fieldInt:(int)ID;
-(void)endExec;
-(void)closeDB;
-(NSString *)error;
-(NSString *)encodeString:(NSString *)s;
-(NSString *)decodeString:(NSString *)s;

@end
