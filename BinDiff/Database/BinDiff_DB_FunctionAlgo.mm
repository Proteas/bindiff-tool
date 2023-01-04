//
//  BinDiff_DB_FunctionAlgo.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_FunctionAlgo.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_FunctionAlgo

WCDB_IMPLEMENTATION(BinDiff_DB_FunctionAlgo)

WCDB_SYNTHESIZE_COLUMN(BinDiff_DB_FunctionAlgo, ID, "id");
WCDB_SYNTHESIZE(BinDiff_DB_FunctionAlgo, name)

@end


@interface BinDiff_DB_FunctionAlgo (BinDiff_DB_FunctionAlgo) <WCTTableCoding>

WCDB_PROPERTY(id)
WCDB_PROPERTY(name)

@end
