//
//  BinDiff_DB_File.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_File.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_File

WCDB_IMPLEMENTATION(BinDiff_DB_File)

WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_File, ID, "id");
WCDB_SYNTHESIZE(BinDiff_DB_File, filename)
WCDB_SYNTHESIZE(BinDiff_DB_File, exefilename)
WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_File, hashStr, "hash");
WCDB_SYNTHESIZE(BinDiff_DB_File, functions)
WCDB_SYNTHESIZE(BinDiff_DB_File, libfunctions)
WCDB_SYNTHESIZE(BinDiff_DB_File, calls)
WCDB_SYNTHESIZE(BinDiff_DB_File, basicblocks)
WCDB_SYNTHESIZE(BinDiff_DB_File, edges)
WCDB_SYNTHESIZE(BinDiff_DB_File, libedges)
WCDB_SYNTHESIZE(BinDiff_DB_File, instructions)
WCDB_SYNTHESIZE(BinDiff_DB_File, libinstructions)

@end


@interface BinDiff_DB_File (BinDiff_DB_File) <WCTTableCoding>

WCDB_PROPERTY(id)
WCDB_PROPERTY(filename)
WCDB_PROPERTY(exefilename)
WCDB_PROPERTY(hashStr)
WCDB_PROPERTY(functions)
WCDB_PROPERTY(libfunctions)
WCDB_PROPERTY(calls)
WCDB_PROPERTY(basicblocks)
WCDB_PROPERTY(edges)
WCDB_PROPERTY(libedges)
WCDB_PROPERTY(instructions)
WCDB_PROPERTY(libinstructions)

@end
