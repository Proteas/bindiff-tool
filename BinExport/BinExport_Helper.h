//
//  BinExport_Helper.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "GPBProtocolBuffers.h"
#import "Binexport2.pbobjc.h"

// caller release
BinExport2 * BEH_LoadBinExport(NSString *filePath);
NSDictionary<NSNumber *, BinExport2_CallGraph_Vertex *> * BEH_BuildFunctionMap(BinExport2 *binExp2);

BinExport2_CallGraph_Vertex * BEH_FindVertexWithFuncName(BinExport2 *binExp2, const char *funcName);
BinExport2_CallGraph_Vertex * BEH_FindVertexWithFuncAddr(BinExport2 *binExp2, uint64_t funcAddr);
BinExport2_FlowGraph * BEH_FindFlowGraphWithAddr(BinExport2 *binExp2, uint64_t addr);
uint64_t BEH_GetFlowGraphEntryBasicBlockAddr(BinExport2 *binExp2, BinExport2_FlowGraph *flowGraph);

uint64_t BEH_GetInstAddr(BinExport2 *binExp2, int beginIndex);
uint64_t BEH_GetBBlockFirstInstAddr(BinExport2 *binExp2, int32_t bbIdx);
uint64_t BEH_GetBBlockFirstInstAddr2(BinExport2 *binExp2, BinExport2_BasicBlock *bblock);

NSString * BEH_GetFunctionName(BinExport2_CallGraph_Vertex *vertex);

void BEH_RenderExpression(BinExport2 *binExp2, BinExport2_Operand *opObj, int32_t expIdx, NSMutableString *output);

void BEH_PrintInst_Function(BinExport2 *binExp2, uint64_t addr);
void BEH_PrintInst_BasicBlock(BinExport2 *binExp2, int32_t bbIdx);
void BEH_PrintInst_InstructionRange(BinExport2 *binExp2, BinExport2_BasicBlock_IndexRange *instRange);
void BEH_PrintInst_Instruction(BinExport2 *binExp2, int32_t instIndex);

void BEH_PrintFunctionBasicBlocks(BinExport2 *binExp2, uint64_t addr);
void BEH_PrintFunctionBasicBlocks2(BinExport2 *binExp2, uint64_t addr);
