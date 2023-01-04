//
//  BinDiff_DB_Instruction.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB_Instruction.h"
#import <WCDB/WCDB.h>

@implementation BinDiff_DB_Instruction

WCDB_IMPLEMENTATION(BinDiff_DB_Instruction)

WCDB_SYNTHESIZE(BinDiff_DB_Instruction, basicblockid)
WCDB_SYNTHESIZE(BinDiff_DB_Instruction, address1)
WCDB_SYNTHESIZE(BinDiff_DB_Instruction, address2)

@end


@interface BinDiff_DB_Instruction (BinDiff_DB_Instruction) <WCTTableCoding>

WCDB_PROPERTY(basicblockid)
WCDB_PROPERTY(address1)
WCDB_PROPERTY(address2)

@end
