//
//  BinExport_Helper.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinExport_Helper.h"

BinExport2 * BEH_LoadBinExport(NSString *filePath)
{
    if ([filePath length] == 0) {
        NSLog(@"[-] invalid file path");
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    if (data == nil) {
        NSLog(@"[-] fail to load file data: %@", filePath);
        return nil;
    }
    
    NSError *error = nil;
    BinExport2 *binExp2 = [[BinExport2 alloc] initWithData:data error:&error];
    if (error) {
        [data release];
        data = nil;
        
        NSLog(@"[-] fail to load file: %@, %@", filePath, error);
        return nil;
    }
    
    [data release];
    data = nil;
    
    return binExp2;
}

BinExport2_CallGraph_Vertex * BEH_FindVertexWithFuncName(BinExport2 *binExp2, const char *funcName)
{
    for (BinExport2_CallGraph_Vertex *vertex in binExp2.callGraph.vertexArray) {
        if (vertex.hasDemangledName) {
            //printf("0x%llx: %s\n", vertex.address, vertex.demangledName.UTF8String);
            if (strcmp(funcName, vertex.demangledName.UTF8String) == 0){
                return vertex;
            }
        }
        else if (vertex.hasMangledName) {
            //printf("0x%llx: %s\n", vertex.address, vertex.mangledName.UTF8String);
            if (strcmp(funcName, vertex.mangledName.UTF8String) == 0){
                return vertex;
            }
        }
        else {
            //printf("0x%llx: sub_%llX\n", vertex.address, vertex.address);
        }
    }
    
    return nil;
}

NSDictionary<NSNumber *, BinExport2_CallGraph_Vertex *> * BEH_BuildFunctionMap(BinExport2 *binExp2)
{
    NSMutableDictionary *retMap = [NSMutableDictionary dictionaryWithCapacity:binExp2.callGraph.vertexArray_Count];
    
    for (BinExport2_CallGraph_Vertex *vertex in binExp2.callGraph.vertexArray) {
        if (vertex.hasAddress == NO) {
            printf("[-] %s: vertex has no address\n", __FUNCTION__);
            continue;;
        }
        
        NSNumber *addrObj = [NSNumber numberWithUnsignedLongLong:vertex.address];
        [retMap setObject:vertex forKey:addrObj];
    }
    
    return retMap;
    
}

BinExport2_CallGraph_Vertex * BEH_FindVertexWithFuncAddr(BinExport2 *binExp2, uint64_t funcAddr)
{
    for (BinExport2_CallGraph_Vertex *vertex in binExp2.callGraph.vertexArray) {
        if (vertex.hasAddress && (vertex.address == funcAddr)) {
            return vertex;
        }
    }
    
    return nil;
}

BinExport2_FlowGraph * BEH_FindFlowGraphWithAddr(BinExport2 *binExp2, uint64_t addr)
{
    for (BinExport2_FlowGraph *flowGraph in binExp2.flowGraphArray) {
        if (flowGraph.hasEntryBasicBlockIndex) {
            BinExport2_BasicBlock *bblock = [binExp2.basicBlockArray objectAtIndex:flowGraph.entryBasicBlockIndex];
            if (bblock.instructionIndexArray_Count > 0) {
                BinExport2_BasicBlock_IndexRange *instRange = bblock.instructionIndexArray[0];
                if (instRange.hasBeginIndex) {
                    BinExport2_Instruction *inst = [binExp2.instructionArray objectAtIndex:instRange.beginIndex];
                    if (inst != nil) {
                        if (inst.address == addr) {
                            return flowGraph;
                        }
                    }
                }
            }
        }
        else {
            printf("[-] no entry basic block index for addr: 0x%llx\n", addr);
        }
    }
    
    return nil;
}

uint64_t BEH_GetFlowGraphEntryBasicBlockAddr(BinExport2 *binExp2, BinExport2_FlowGraph *flowGraph)
{
    if (flowGraph.hasEntryBasicBlockIndex == 0) {
        printf("[-] %s: has no entry basic block index\n", __FUNCTION__);
        return -1;
    }
    
    BinExport2_BasicBlock *bblock = [binExp2.basicBlockArray objectAtIndex:flowGraph.entryBasicBlockIndex];
    if (bblock.instructionIndexArray_Count == 0) {
        printf("[-] %s: basic block has not instructions\n", __FUNCTION__);
        return -1;
    }
    
    BinExport2_BasicBlock_IndexRange *instRange = bblock.instructionIndexArray[0];
    if (instRange.hasBeginIndex == NO) {
        printf("[-] %s: instruction range has not begin index\n", __FUNCTION__);
        return -1;
    }
    
    return BEH_GetInstAddr(binExp2, instRange.beginIndex);
}

uint64_t BEH_GetInstAddr(BinExport2 *binExp2, int beginIndex)
{
    BinExport2_Instruction *inst = [binExp2.instructionArray objectAtIndex:beginIndex];
    if (inst.hasAddress) {
        return inst.address;
    }
    
    // search forward
    uint64_t delta = 0;
    for (int idx = beginIndex - 1; idx >= 0; --idx) {
        BinExport2_Instruction *inst = [binExp2.instructionArray objectAtIndex:idx];
        delta += inst.rawBytes.length;
        if (inst.hasAddress) {
            return (inst.address + delta);
        }
    }
    printf("[-] fail to get instruction address, index: %d\n", beginIndex);
    
    return 0;
}

uint64_t BEH_GetBBlockFirstInstAddr(BinExport2 *binExp2, int32_t bbIdx)
{
    BinExport2_BasicBlock *bblock = [binExp2.basicBlockArray objectAtIndex:bbIdx];
    return BEH_GetBBlockFirstInstAddr2(binExp2, bblock);
}

uint64_t BEH_GetBBlockFirstInstAddr2(BinExport2 *binExp2, BinExport2_BasicBlock *bblock)
{
    if (bblock.instructionIndexArray_Count == 0) {
        printf("[-] basic block has no inst array\n");
        return 0;
    }
    
#if (0)
    if (bblock.instructionIndexArray_Count > 1) {
        printf("\n");
        printf("[-] basic block has more than 1 inst array: \n");
        for (BinExport2_BasicBlock_IndexRange *instRange in bblock.instructionIndexArray) {
            printf("    0x%llX\n", BEH_GetInstAddr(binExp2, instRange.beginIndex));
        }
        printf("\n");
    }
#endif
    
    BinExport2_BasicBlock_IndexRange *instRange = bblock.instructionIndexArray[0];
    if (instRange.hasBeginIndex == NO) {
        printf("[-] inst range has no begin index");
        return 0;
    }
    
    return BEH_GetInstAddr(binExp2, instRange.beginIndex);
}

NSString * BEH_GetFunctionName(BinExport2_CallGraph_Vertex *vertex)
{
    if (vertex.hasDemangledName) {
        return vertex.demangledName;
    }
    else if (vertex.hasMangledName) {
        return vertex.mangledName;
    }
    else {
        if (vertex.hasAddress) {
            NSString *funcName = [NSString stringWithFormat:@"sub_0x%llX", vertex.address];
            return funcName;
        }
    }
    
    return nil;
}

// Ref: https://github.com/google/binexport/blob/main/tools/binexport2dump.cc#L38
void BEH_RenderExpression(BinExport2 *binExp2, BinExport2_Operand *opObj, int32_t expLoopIndex, NSMutableString *outStr)
{
    int32_t expIndex = [opObj.expressionIndexArray valueAtIndex:expLoopIndex];
    BinExport2_Expression *expObj = [binExp2.expressionArray objectAtIndex:expIndex];
    NSString *expSymbol = expObj.symbol;
    
    BOOL longMode = [binExp2.metaInformation.architectureName hasSuffix:@"64"];
    
    switch (expObj.type) {
        case BinExport2_Expression_Type_Operator:  {
            GPBInt32Array *childLoopIndexArray = [GPBInt32Array arrayWithCapacity:4];
            
            for (int32_t childExpLoopIdx = expLoopIndex + 1; childExpLoopIdx < opObj.expressionIndexArray_Count; ++childExpLoopIdx) {
                int32_t childExpIndex = [opObj.expressionIndexArray valueAtIndex:childExpLoopIdx];
                BinExport2_Expression *childExp = [binExp2.expressionArray objectAtIndex:childExpIndex];
                if (childExp.parentIndex == expIndex) {
                    [childLoopIndexArray addValue:childExpLoopIdx];
                }
            }
            
            if ([expSymbol isEqualToString:@"{"]) {
                [outStr appendString:@"{"];
                
                for (int32_t childLoopIdx = 0; childLoopIdx < childLoopIndexArray.count; ++childLoopIdx) {
                    BEH_RenderExpression(binExp2, opObj, [childLoopIndexArray valueAtIndex:childLoopIdx], outStr);
                    if (childLoopIdx != childLoopIndexArray.count - 1) {
                        [outStr appendString:@","];
                    }
                }
                
                [outStr appendString:@"}"];
            }
            else if (childLoopIndexArray.count == 1) {
                [outStr appendString:expSymbol];
                BEH_RenderExpression(binExp2, opObj, [childLoopIndexArray valueAtIndex:0], outStr);
            }
            else if (childLoopIndexArray.count > 1) {
                for (int32_t childLoopIdx = 0; childLoopIdx < childLoopIndexArray.count; ++childLoopIdx) {
                    BEH_RenderExpression(binExp2, opObj, [childLoopIndexArray valueAtIndex:childLoopIdx], outStr);
                    if (childLoopIdx != childLoopIndexArray.count - 1) {
                        BinExport2_Expression *childExp = [binExp2.expressionArray objectAtIndex:[childLoopIndexArray valueAtIndex:childLoopIdx + 1]];
                        BinExport2_Expression_Type childType = childExp.type;
                        if ([expSymbol isEqualToString:@"+"] && (childType == BinExport2_Expression_Type_ImmediateInt || childType == BinExport2_Expression_Type_ImmediateFloat)) {
                            int64_t childImmediate = longMode ? childExp.immediate : (int32_t)childExp.immediate;
                            if ((childImmediate < 0) && ([childExp.symbol length] == 0)) {
                                continue;
                            }
                            if (childImmediate == 0) {
                                ++childLoopIdx;
                                continue;
                            }
                        }
                        [outStr appendString:expSymbol];
                    }
                }
            }
            
            break;
        }
        case BinExport2_Expression_Type_Symbol:
        case BinExport2_Expression_Type_Register:  {
            [outStr appendString:expSymbol];
            break;
        }
        case BinExport2_Expression_Type_SizePrefix:  {
            if (((longMode == YES) && ([expSymbol isEqualToString:@"b8"] == NO)) ||
                ((longMode == NO) && ([expSymbol isEqualToString:@"b4"] == NO))) {
#if (0)
                [outStr appendString:expSymbol];
                [outStr appendString:@" "];
#endif
            }
            BEH_RenderExpression(binExp2, opObj, expLoopIndex + 1, outStr);
            break;
        }
        case BinExport2_Expression_Type_Dereference:  {
            [outStr appendString:@"["];
            if (expLoopIndex + 1 < opObj.expressionIndexArray_Count) {
                BEH_RenderExpression(binExp2, opObj, expLoopIndex + 1, outStr);
            }
            [outStr appendString:@"]"];
            break;
        }
        case BinExport2_Expression_Type_ImmediateInt:
        case BinExport2_Expression_Type_ImmediateFloat:  {
            if ([expSymbol length] == 0) {
                int64_t immediate = longMode ? expObj.immediate : (int32_t)expObj.immediate;
                if ((immediate <= 9) && (immediate > -0x4000)) {
                    [outStr appendFormat:@"%lld", immediate];
                }
                else {
                    [outStr appendFormat:@"0x%llX", immediate];
                }
            }
            else {
                [outStr appendString:expSymbol];
            }
            break;
        }
        default: {
            printf("[-] invalid express type: %d\n", expObj.type);
        }
    } // switch
}

void BEH_PrintInst_Function(BinExport2 *binExp2, uint64_t addr)
{
    BinExport2_FlowGraph *flowGraph = BEH_FindFlowGraphWithAddr(binExp2, addr);
    if (flowGraph == nil) {
        printf("[-] can't find flow graph: 0x%llx\n", addr);
        return;
    }
    
    for (int idx = 0; idx < flowGraph.basicBlockIndexArray_Count; ++idx) {
        int32_t bbIdx = [flowGraph.basicBlockIndexArray valueAtIndex:idx];
        BEH_PrintInst_BasicBlock(binExp2, bbIdx);
    }
}

NSArray<BinExport2_BasicBlock *> * BEH_GetFunctionBasicBlocks(BinExport2 *binExp2, uint64_t addr)
{
    BinExport2_FlowGraph *flowGraph = BEH_FindFlowGraphWithAddr(binExp2, addr);
    if (flowGraph == nil) {
        printf("[-] can't find flow graph: 0x%llx\n", addr);
        return nil;
    }
    
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (int idx = 0; idx < flowGraph.basicBlockIndexArray_Count; ++idx) {
        int32_t bbIdx = [flowGraph.basicBlockIndexArray valueAtIndex:idx];
        BinExport2_BasicBlock *bblock = [binExp2.basicBlockArray objectAtIndex:bbIdx];
        [retArray addObject:bblock];
    }
    
    return retArray;
}

NSArray<NSNumber *> * BEH_GetFunctionBasicBlockAddresses(BinExport2 *binExp2, uint64_t addr)
{
    NSArray<BinExport2_BasicBlock *> *bbArray = BEH_GetFunctionBasicBlocks(binExp2, addr);
    
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (BinExport2_BasicBlock *bbInfo in bbArray) {
        uint64_t addr = BEH_GetBBlockFirstInstAddr2(binExp2, bbInfo);
        if (addr == 0) {
            printf("[-] %s: fail to get basic block address\n", __FUNCTION__);
            continue;
        }
        
        NSNumber *addrObj = [NSNumber numberWithUnsignedLongLong:addr];
        [retArray addObject:addrObj];
    }
    
    return retArray;
}

NSDictionary<NSNumber *, BinExport2_BasicBlock *> * BEH_BuildBasicBlockMap(BinExport2 *binExp2, NSArray<BinExport2_BasicBlock *> *bbArray)
{
    NSMutableDictionary *retMap = [NSMutableDictionary dictionary];
    
    for (BinExport2_BasicBlock *bbInfo in bbArray) {
        uint64_t addr = BEH_GetBBlockFirstInstAddr2(binExp2, bbInfo);
        if (addr == 0) {
            printf("[-] %s: fail to get basic block address\n", __FUNCTION__);
            continue;
        }
        
        NSNumber *addrObj = [NSNumber numberWithUnsignedLongLong:addr];
        [retMap setObject:bbInfo forKey:addrObj];
    }
    
    return retMap;
}

NSDictionary<NSNumber *, BinExport2_BasicBlock *> * BEH_GetFunctionBasicBlockMap(BinExport2 *binExp2, uint64_t addr)
{
    NSArray<BinExport2_BasicBlock *> *bbArray = BEH_GetFunctionBasicBlocks(binExp2, addr);
    return BEH_BuildBasicBlockMap(binExp2, bbArray);
}

void BEH_PrintInst_BasicBlock(BinExport2 *binExp2, int32_t bbIdx)
{
    //printf("[+] bb index: %d\n", bbIdx);
    
    BinExport2_BasicBlock *bblock = [binExp2.basicBlockArray objectAtIndex:bbIdx];
    if (bblock.instructionIndexArray_Count == 0) {
        printf("[-] basic block has no inst array\n");
        return;
    }
    
    for (BinExport2_BasicBlock_IndexRange *instRange in bblock.instructionIndexArray) {
        BEH_PrintInst_InstructionRange(binExp2, instRange);
    }
    printf("-----------------------\n");
}

void BEH_PrintInst_InstructionRange(BinExport2 *binExp2, BinExport2_BasicBlock_IndexRange *instRange)
{
    if (instRange.hasBeginIndex == NO) {
        printf("[-] not has begin index\n");
    }
    
    int32_t idx = instRange.beginIndex;
    do {
        BEH_PrintInst_Instruction(binExp2, idx);
        printf("\n");
        
        ++idx;
    } while (instRange.hasEndIndex && (idx < instRange.endIndex));
}

void BEH_PrintInst_Instruction(BinExport2 *binExp2, int32_t instIndex)
{
    BinExport2_Instruction *inst = [binExp2.instructionArray objectAtIndex:instIndex];
    printf("0x%llX: ", BEH_GetInstAddr(binExp2, instIndex));
    
    NSMutableString *disStr = [[NSMutableString alloc] init];
    
    BinExport2_Mnemonic *mnem = [binExp2.mnemonicArray objectAtIndex:inst.mnemonicIndex];
    [disStr appendFormat:@"%@ ", mnem.name];
    
    for (int32_t opLoopIdx = 0; opLoopIdx < inst.operandIndexArray.count; ++opLoopIdx) {
        int32_t opIdx = [inst.operandIndexArray valueAtIndex:opLoopIdx];
        BinExport2_Operand *opObj = [binExp2.operandArray objectAtIndex:opIdx];
        
        for (int32_t expLoopIdx = 0; expLoopIdx < opObj.expressionIndexArray.count; ++expLoopIdx) {
            int32_t expIdx = [opObj.expressionIndexArray valueAtIndex:expLoopIdx];
            BinExport2_Expression *expObj = [binExp2.expressionArray objectAtIndex:expIdx];
            if (expObj.hasParentIndex == NO) {
                BEH_RenderExpression(binExp2, opObj, expLoopIdx, disStr);
            }
        }
        if (opLoopIdx != inst.operandIndexArray.count - 1) {
            [disStr appendString:@", "];
        }
    }
    
    printf("%s", disStr.UTF8String);
    [disStr release]; disStr = nil;
    
    // call target array
    if (inst.callTargetArray_Count > 0) {
        printf("; call: ");
        for (int32_t loopIdx = 0; loopIdx < inst.callTargetArray.count; ++loopIdx) {
            uint64_t targetAddr = [inst.callTargetArray valueAtIndex:loopIdx];
            printf("0x%llx", targetAddr);
            if (loopIdx != inst.callTargetArray.count - 1) {
                printf(", ");
            }
        }
    }
    
    // comment
    if (inst.commentIndexArray_Count > 0) {
        printf("; ");
        for (int32_t commentLoopIdx = 0; commentLoopIdx < inst.commentIndexArray_Count; ++commentLoopIdx) {
            int32_t commentIdx = [inst.commentIndexArray valueAtIndex:commentLoopIdx];
            BinExport2_Comment *comm = [binExp2.commentArray objectAtIndex:commentIdx];
            NSString *tmpStr = [binExp2.stringTableArray objectAtIndex:comm.stringTableIndex];
            printf("%s", tmpStr.UTF8String);
            if (commentLoopIdx != inst.commentIndexArray_Count - 1) {
                printf("; ");
            }
        }
    }
}

void BEH_PrintFunctionBasicBlocks(BinExport2 *binExp2, uint64_t addr)
{
    BinExport2_FlowGraph *flowGraph = BEH_FindFlowGraphWithAddr(binExp2, addr);
    if (flowGraph == nil) {
        printf("[-] can't find flow graph: 0x%llx\n", addr);
        return;
    }
    
    for (int idx = 0; idx < flowGraph.basicBlockIndexArray_Count; ++idx) {
        int32_t bbIdx = [flowGraph.basicBlockIndexArray valueAtIndex:idx];
        uint64_t bbAddr = BEH_GetBBlockFirstInstAddr(binExp2, bbIdx);
        printf("    %04d, %06d: 0x%llX\n", idx, bbIdx, bbAddr);
    }
}

void BEH_PrintFunctionBasicBlocks2(BinExport2 *binExp2, uint64_t addr)
{
    BinExport2_FlowGraph *flowGraph = BEH_FindFlowGraphWithAddr(binExp2, addr);
    if (flowGraph == nil) {
        printf("[-] can't find flow graph: 0x%llx\n", addr);
        return;
    }
    
    NSMutableArray<BinExport2_FlowGraph_Edge*> *edgeArray = flowGraph.edgeArray;
    for (BinExport2_FlowGraph_Edge *edge in edgeArray) {
        if (edge.hasSourceBasicBlockIndex == NO) {
            printf("[-] %s, invalid block edge, not have source\n", __FUNCTION__);
            continue;
        }
        
        if (edge.hasTargetBasicBlockIndex == NO) {
            printf("[-] %s, invalid block edge, not have target\n", __FUNCTION__);
            continue;
        }
        
        uint64_t sourceAddr = BEH_GetBBlockFirstInstAddr(binExp2, edge.sourceBasicBlockIndex);
        uint64_t targetAddr = BEH_GetBBlockFirstInstAddr(binExp2, edge.targetBasicBlockIndex);
        
        printf("0x%llX -> 0x%llX", sourceAddr, targetAddr);
        
        if (edge.hasType) {
            switch (edge.type) {
                case BinExport2_FlowGraph_Edge_Type_ConditionTrue: {
                    printf(", type: true");
                    break;
                }
                case BinExport2_FlowGraph_Edge_Type_ConditionFalse: {
                    printf(", type: false");
                    break;
                }
                case BinExport2_FlowGraph_Edge_Type_Unconditional: {
                    printf(", type: unconditional");
                    break;
                }
                case BinExport2_FlowGraph_Edge_Type_Switch: {
                    printf(", type: switch");
                    break;
                }
                    
                default: {
                    printf(", type: %d, unkown", edge.type);
                    break;
                }
            }
        } /* edge.hasType */
        else {
            printf(", type: none");
        }
        
        if (edge.hasIsBackEdge) {
            if (edge.isBackEdge) {
                printf(", back-edge: true\n");
            }
            else {
                printf(", back-edge: false\n");
            }
        }
        else {
            printf("\n");
        }
    }
}
