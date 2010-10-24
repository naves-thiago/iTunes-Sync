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
-(BOOL)prepareSQL:(NSString *)sql;
-(BOOL)next;
-(BOOL)execute;
-(void)endExec;
-(void)closeDB;
-(NSString *)error;

-(NSString *)fieldString:(int)ID;
-(int)fieldInt:(int)ID;
-(BOOL)fieldBoolean:(int)ID;
-(double)fieldDouble:(int)ID;
-(NSDate *)fieldDate:(int)ID;

-(void)bindString:(NSString *)str toId:(int)ID;
-(void)bindInteger:(int)i toId:(int)ID;
-(void)bindDouble:(double)d toId:(int)ID;
-(void)bindBoolean:(BOOL)b toId:(int)ID;
-(void)bindDate:(NSDate *)d toId:(int)ID;
@end
