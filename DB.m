//
//  DB.m
//  iTunes Sync
//
//  Created by Thiago Naves on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DB.h"

//static sqlite3_stmt *statement = nil;
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

-(BOOL)execSQL:(NSString *)sql
{
	return sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK;
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

-(NSString *)encodeString:(NSString *)s
{
	return [[s stringByReplacingOccurrencesOfString:@"#" withString:@"#23"] stringByReplacingOccurrencesOfString:@"\"" withString:@"#22"];
}

-(NSString *)decodeString:(NSString *)s
{
	return [[s stringByReplacingOccurrencesOfString:@"#22" withString:@"\""] stringByReplacingOccurrencesOfString:@"#23" withString:@"#"];
}

@end