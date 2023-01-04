//
//  BinDiff_DB_BasicBlock.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_BasicBlock.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_BasicBlock

WCDB_IMPLEMENTATION(BinDiff_DB_BasicBlock)

WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_BasicBlock, ID, "id");
WCDB_SYNTHESIZE(BinDiff_DB_BasicBlock, functionid)
WCDB_SYNTHESIZE(BinDiff_DB_BasicBlock, address1)
WCDB_SYNTHESIZE(BinDiff_DB_BasicBlock, address2)
WCDB_SYNTHESIZE(BinDiff_DB_BasicBlock, algorithm)
WCDB_SYNTHESIZE(BinDiff_DB_BasicBlock, evaluate)

@end


@interface BinDiff_DB_BasicBlock (BinDiff_DB_BasicBlock) <WCTTableCoding>

WCDB_PROPERTY(id)
WCDB_PROPERTY(functionid)
WCDB_PROPERTY(address1)
WCDB_PROPERTY(address2)
WCDB_PROPERTY(algorithm)
WCDB_PROPERTY(evaluate)

@end
