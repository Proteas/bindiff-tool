//
//  BELM_Function.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import <Foundation/Foundation.h>
#import "BELM_Edge.h"

typedef enum _BELM_FunctionType {
    BELM_FunctionType_Normal = 0,
    BELM_FunctionType_Library = 1,
    BELM_FunctionType_Imported = 2,
    BELM_FunctionType_Thunk = 3,
    BELM_FunctionType_Invalid = 4,
} BELM_FunctionType;

@class BinExport2;
@class BinExport2_CallGraph_Vertex;
@class BinExport2_FlowGraph;
@class BELM_BasicBlock;
@class BELM_Module;

@interface BELM_Function : NSObject
{
    uint64_t _addr;
    NSString *_mangledName;
    NSString *_demangledName;
    NSMutableArray<BELM_Edge *> *_edgeArray;
    BELM_FunctionType _type;
    NSMutableArray *_callTargetAddrArray;
    NSMutableArray *_callTargetNameArray;
}

@property(nonatomic, assign) uint64_t addr;
@property(nonatomic, assign) BELM_FunctionType type;
@property(nonatomic, retain) NSMutableArray<BELM_BasicBlock *> *bbArray;
@property(nonatomic, retain) NSMutableArray<BELM_Edge *> *edgeArray;
@property(nonatomic, retain) NSMutableArray *callTargetAddrArray;
@property(nonatomic, retain) NSMutableArray *callTargetNameArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 flowGraph:(BinExport2_FlowGraph *)flowGraph vertex:(BinExport2_CallGraph_Vertex *)vertex;

- (NSString *)getName;
- (BELM_BasicBlock *)getBasicBlockWithAddr:(uint64_t)addr;
- (BOOL)hasBasicBlockWithAddr:(uint64_t)addr;

- (void)dumpBasicBlocks;

- (void)postProcess:(BELM_Module *)belmModule;
- (NSUInteger)getInstructionCount;

@end
