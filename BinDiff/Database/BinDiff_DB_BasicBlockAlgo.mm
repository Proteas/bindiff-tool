//
//  BinDiff_DB_BasicBlockAlgo.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_BasicBlockAlgo.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_BasicBlockAlgo

WCDB_IMPLEMENTATION(BinDiff_DB_BasicBlockAlgo)

WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_BasicBlockAlgo, ID, "id");
WCDB_SYNTHESIZE(BinDiff_DB_BasicBlockAlgo, name)

@end


@interface BinDiff_DB_BasicBlockAlgo (BinDiff_DB_BasicBlockAlgo) <WCTTableCoding>

WCDB_PROPERTY(id)
WCDB_PROPERTY(name)

@end
