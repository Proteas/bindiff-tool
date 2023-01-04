//
//  BinDiff_DB.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "BinDiff_DB_Meta.h"
#import "BinDiff_DB_File.h"
#import "BinDiff_DB_FunctionAlgo.h"
#import "BinDiff_DB_Function.h"
#import "BinDiff_DB_BasicBlockAlgo.h"
#import "BinDiff_DB_BasicBlock.h"
#import "BinDiff_DB_Instruction.h"

@interface BinDiff_DB : NSObject
{
    NSArray<BinDiff_DB_Meta *> *_metaArray;
    NSArray<BinDiff_DB_File *> *_fileArray;
    NSArray<BinDiff_DB_FunctionAlgo *> *_funcAlgoArray;
    NSArray<BinDiff_DB_Function *> *_funcArray;
    NSArray<BinDiff_DB_BasicBlockAlgo *> *_bbAlgoArray;
    NSArray<BinDiff_DB_BasicBlock *> *_bbArray;
    NSArray<BinDiff_DB_Instruction *> *_instArray;
}

@property(retain) NSArray<BinDiff_DB_Meta *> *metaArray;
@property(retain) NSArray<BinDiff_DB_File *> *fileArray;
@property(retain) NSArray<BinDiff_DB_FunctionAlgo *> *funcAlgoArray;
@property(retain) NSArray<BinDiff_DB_Function *> *funcArray;
@property(retain) NSArray<BinDiff_DB_BasicBlockAlgo *> *bbAlgoArray;
@property(retain) NSArray<BinDiff_DB_BasicBlock *> *bbArray;
@property(retain) NSArray<BinDiff_DB_Instruction *> *instArray;

- (instancetype)initWithPath:(NSString *)dbPath;

- (NSArray<BinDiff_DB_BasicBlock *> *)getBasicBlocksWithFunctionID:(int)funcID;
- (NSArray<BinDiff_DB_Instruction *> *)getInstructionsWithBasicBlockID:(int)basicBlockID;

- (NSArray<BinDiff_DB_BasicBlock *> *)getBasicBlocksWithFunctionID2:(int)funcID;
- (NSArray<BinDiff_DB_Instruction *> *)getInstructionsWithBasicBlockID2:(int)basicBlockID;

- (void)dumpDiff;

@end
