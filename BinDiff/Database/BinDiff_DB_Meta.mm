//
//  BinDiff_DB_Meta.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_Meta.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_Meta

WCDB_IMPLEMENTATION(BinDiff_DB_Meta)

WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_Meta, ver, "version");
WCDB_SYNTHESIZE(BinDiff_DB_Meta, file1)
WCDB_SYNTHESIZE(BinDiff_DB_Meta, file2)
WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_Meta, desp, "description");
WCDB_SYNTHESIZE(BinDiff_DB_Meta, created)
WCDB_SYNTHESIZE(BinDiff_DB_Meta, modified)
WCDB_SYNTHESIZE(BinDiff_DB_Meta, similarity)
WCDB_SYNTHESIZE(BinDiff_DB_Meta, confidence)

@end


@interface BinDiff_DB_Meta (BinDiff_DB_Meta) <WCTTableCoding>

WCDB_PROPERTY(version)
WCDB_PROPERTY(file1)
WCDB_PROPERTY(file2)
WCDB_PROPERTY(description)
WCDB_PROPERTY(created)
WCDB_PROPERTY(modified)
WCDB_PROPERTY(similarity)
WCDB_PROPERTY(confidence)

@end
