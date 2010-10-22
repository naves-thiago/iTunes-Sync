//
//  DB.m
//  iTunes Sync
//
//  Created by Thiago Naves on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DB.h"

@implementation DB

-(BOOL)openDB:(NSString *)fileName
{
	path = [NSString stringWithString:fileName];
	statement = nil;
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
		return YES;
	else
	{
		sqlite3_close(database);
		return NO;
	}
}

-(BOOL)prepareSQL:(NSString *)sql
{
	return sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK;
}

-(BOOL)execute
{
	return sqlite3_step(statement) == SQLITE_DONE;
}

-(BOOL)next
{
	return sqlite3_step(statement) == SQLITE_ROW;
}

-(NSString *)fieldString:(int)ID
{
	return [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, ID)];
}

-(int)fieldInt:(int)ID
{
	return sqlite3_column_int(statement, ID);
}

-(BOOL)fieldBoolean:(int)ID
{
	return [self fieldInt:id] == 1;
}

-(double)fieldDouble:(int)ID
{
	return sqlite3_column_double(statement, ID);
}

-(NSDate)fieldDate:(int)ID
{
	return [NSDate dateWithString:[self fieldString:ID]];
}

-(void)endExec
{
//	sqlite3_finalize(statement);
	sqlite3_reset(statement);
}

-(void)closeDB
{
	sqlite3_close(database);
}

-(NSString *)error
{
	return [NSString stringWithUTF8String:(char*)sqlite3_errmsg(database)];
}

-(void)bindString:(NSString *)str toId:(int)ID
{
	sqlite3_bind_text(statement, ID, [str UTF8String], -1, SQLITE_TRANSIENT);
}

-(void)bindInteger:(int)i toId:(int)ID
{
	sqlite3_bind_int(statement, ID, i);
}

-(void)bindDouble:(double)d toId:(int)ID
{
	sqlite3_bind_double(statement, ID, d);
}

-(void)bindBoolean:(BOOL)b toId:(int)ID
{
	sqlite3_bind_int(statement, ID, b ? 1:0);
}

-(void)bindDate:(NSDate)d toId:(int)ID
{
	[self bindString:[d description] toId:ID];
}

/*
-(NSString *)encodeString:(NSString *)s
{
	return [[s stringByReplacingOccurrencesOfString:@"#" withString:@"#23"] stringByReplacingOccurrencesOfString:@"\"" withString:@"#22"];
}

-(NSString *)decodeString:(NSString *)s
{
	return [[s stringByReplacingOccurrencesOfString:@"#22" withString:@"\""] stringByReplacingOccurrencesOfString:@"#23" withString:@"#"];
}
*/

@end
