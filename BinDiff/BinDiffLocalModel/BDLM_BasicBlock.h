//
//  BDLM_BasicBlock.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>

@class BinDiff_DB;
@class BinDiff_DB_BasicBlock;
@class BDLM_Instruction;

@interface BDLM_BasicBlock : NSObject
{
    BinDiff_DB_BasicBlock *_refBasicBlock;
    NSString *_algorithm;
}

@property(nonatomic, retain, readonly) BinDiff_DB_BasicBlock *refBasicBlock;
@property(nonatomic, retain, readonly) NSString *algorithm;
@property(nonatomic, retain) NSMutableArray<BDLM_Instruction *> *instArray;

- (instancetype)initWithDB:(BinDiff_DB *)db basicBlock:(BinDiff_DB_BasicBlock *)basicBlock;

- (BOOL)isInstAddrInV1:(uint64_t)addr;
- (BOOL)isInstAddrInV2:(uint64_t)addr;

- (BDLM_Instruction *)getInstructionWithAddrV1:(uint64_t)addr;
- (BDLM_Instruction *)getInstructionWithAddrV2:(uint64_t)addr;

@end
