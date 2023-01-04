//
//  BELM_BasicBlock.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import <Foundation/Foundation.h>

@class BinExport2;
@class BELM_Instruction;
@class BELM_Module;

@interface BELM_BasicBlock : NSObject
{
    uint64_t _addr;
    NSMutableArray *_instArray;
    NSMutableArray *_callTargetAddrArray;
    NSMutableArray *_callTargetNameArray;
    
    int32_t _blockIndex;
    int64_t _deltaAddr;
    BOOL _isEntry;
}

@property(nonatomic, assign) uint64_t addr;
@property(nonatomic, retain) NSMutableArray *instArray;
@property(nonatomic, retain) NSMutableArray *callTargetAddrArray;
@property(nonatomic, assign) int32_t blockIndex;
@property(nonatomic, assign) int64_t deltaAddr; // bb addr - func addr
@property(nonatomic, assign) BOOL isEntry;
@property(nonatomic, retain) NSMutableArray *callTargetNameArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 index:(int32_t)index;

- (BELM_Instruction *)getInstructionWithAddr:(uint64_t)addr;
- (BOOL)hasInstructionWithAddr:(uint64_t)addr;

- (void)dumpInstructions;

- (BOOL)isEqual:(id)object;

- (void)postProcess:(BELM_Module *)belmModule;
- (NSUInteger)getInstructionCount;

@end
