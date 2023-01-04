//
//  BinDiff_DB_Function.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_Function.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_Function

WCDB_IMPLEMENTATION(BinDiff_DB_Function)

WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_Function, ID, "id");
WCDB_SYNTHESIZE(BinDiff_DB_Function, address1)
WCDB_SYNTHESIZE(BinDiff_DB_Function, name1)
WCDB_SYNTHESIZE(BinDiff_DB_Function, address2)
WCDB_SYNTHESIZE(BinDiff_DB_Function, name2)
WCDB_SYNTHESIZE(BinDiff_DB_Function, similarity)
WCDB_SYNTHESIZE(BinDiff_DB_Function, confidence)
WCDB_SYNTHESIZE(BinDiff_DB_Function, flags)
WCDB_SYNTHESIZE(BinDiff_DB_Function, algorithm)
WCDB_SYNTHESIZE(BinDiff_DB_Function, evaluate)
WCDB_SYNTHESIZE(BinDiff_DB_Function, commentsported)
WCDB_SYNTHESIZE(BinDiff_DB_Function, basicblocks)
WCDB_SYNTHESIZE(BinDiff_DB_Function, edges)
WCDB_SYNTHESIZE(BinDiff_DB_Function, instructions)

@end


@interface BinDiff_DB_Function (BinDiff_DB_Function) <WCTTableCoding>

WCDB_PROPERTY(id)
WCDB_PROPERTY(address1)
WCDB_PROPERTY(name1)
WCDB_PROPERTY(address2)
WCDB_PROPERTY(name2)
WCDB_PROPERTY(similarity)
WCDB_PROPERTY(confidence)
WCDB_PROPERTY(flags)
WCDB_PROPERTY(algorithm)
WCDB_PROPERTY(evaluate)
WCDB_PROPERTY(commentsported)
WCDB_PROPERTY(basicblocks)
WCDB_PROPERTY(edges)
WCDB_PROPERTY(instructions)

@end
