//
//  BinDiff_ListChanged.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BDT_ChangesCmdPrinter.h"
#import "BinDiff_Helper.h"
#import "BinExport_Helper.h"
#import "BinDiff_DB.h"

#import "UDF_Module.h"
#import "BDLM_Module.h"
#import "BELM_Module.h"

#import "UDF_Function.h"
#import "BDLM_Function.h"
#import "BELM_Function.h"

#import "UDF_BasicBlock.h"
#import "BDLM_BasicBlock.h"
#import "BELM_BasicBlock.h"

#import "UDF_Instruction.h"
#import "BDLM_Instruction.h"
#import "BELM_Instruction.h"

@interface BDT_ChangesCmdPrinter ()
{
    UDF_Module *_udfModule;
    BlockInstructionPrintType _blockInstPrintType;
    FunctionNameOutputFlag _funcNameOutputFlag;
    BOOL _printSwitch;
}

@property(nonatomic, retain) UDF_Module *udfModule;
@property(nonatomic, assign) BlockInstructionPrintType blockInstPrintType;
@property(nonatomic, assign) FunctionNameOutputFlag funcNameOutputFlag;
@property(nonatomic, assign) BOOL printSwitch;

- (void)printFunction:(UDF_Function *)udfFunc;
- (void)printBasicBlock:(UDF_BasicBlock *)udfBlock;

- (NSString *)formatFunctionName:(NSString *)funcName;

@end

@implementation BDT_ChangesCmdPrinter

@synthesize udfModule = _udfModule;
@synthesize blockInstPrintType = _blockInstPrintType;
@synthesize funcNameOutputFlag = _funcNameOutputFlag;
@synthesize printSwitch = _printSwitch;

- (instancetype)initWithModule:(UDF_Module *)udfModule;
{
    if ((self = [super init])) {
        self.udfModule = udfModule;
        _blockInstPrintType = BlockInstructionPrintType_All;
        _funcNameOutputFlag = FunctionNameOutputFlag_Full;
        _printSwitch = YES;
    }
    
    return self;
}

- (void)dealloc
{
    self.udfModule = nil;
    
    [super dealloc];
}

- (NSString *)formatFunctionName:(NSString *)funcName
{
    if (_funcNameOutputFlag == FunctionNameOutputFlag_Full) {
        return funcName;
    }
    
    NSRange subRange = [funcName rangeOfString:@"("];
    if (subRange.location != NSNotFound) {
        funcName = [funcName substringToIndex:subRange.location];
    }
    
    return funcName;
}

- (void)printFunctions_Deleted:(FunctionSortType)sortType;
{
    if (_printSwitch == NO) {
        return;
    }
    
    @autoreleasepool {
        NSArray *udfFuncArray = [_udfModule getFunction_Deleted_Normal];
        if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByInstructionBlockEdgeCountV1:)];
        }
        else if (sortType == FunctionSortType_BlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByBlockEdgeCountV1:)];
        }
        else if (sortType == FunctionSortType_WeaknessScore) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByWeaknessScoreV1:)];
        }
        else {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByAddrV1:)];
        }
        printf("[+] deleted function count: %lu\n", udfFuncArray.count);
        
        for (int idx = 0; idx < udfFuncArray.count; ++idx) {
            UDF_Function *udfFunc = udfFuncArray[idx];
            
            printf("    ");
            printf("0x%06llX, ", udfFunc.exportV1.addr);
            if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
                printf("block: %02lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                printf("edge: %02lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
            }
            else if (sortType == FunctionSortType_WeaknessScore) {
                printf("score: %f, ", [udfFunc getWeaknessScoreV1]);
            }
            else {
                printf("block: %02lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                printf("edge: %02lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
            }
            printf("%s", [self formatFunctionName:[udfFunc.exportV1 getName]].UTF8String);
            printf("\n");
        }
        
        if (udfFuncArray.count > 0) {
            printf("\n");
        }
    }
}

- (void)printFunctions_Added:(FunctionSortType)sortType;
{
    if (_printSwitch == NO) {
        return;
    }
    
    @autoreleasepool {
        NSArray *udfFuncArray = [_udfModule getFunction_Added_Normal];
        if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByInstructionBlockEdgeCountV2:)];
        }
        else if (sortType == FunctionSortType_BlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByBlockEdgeCountV2:)];
        }
        else if (sortType == FunctionSortType_WeaknessScore) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByWeaknessScoreV2:)];
        }
        else {
            [udfFuncArray sortedArrayUsingSelector:@selector(compareByAddrV2:)];
        }
        printf("[+] added function count: %lu\n", udfFuncArray.count);
        
        for (int idx = 0; idx < udfFuncArray.count; ++idx) {
            UDF_Function *udfFunc = udfFuncArray[idx];
            
            printf("    ");
            printf("0x%06llX, ", udfFunc.exportV2.addr);
            if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV2 getInstructionCount]);
                printf("block: %02lu, ", (unsigned long)udfFunc.exportV2.bbArray.count);
                printf("edge: %02lu, ", (unsigned long)udfFunc.exportV2.edgeArray.count);
            }
            else if (sortType == FunctionSortType_WeaknessScore) {
                printf("score: %f, ", [udfFunc getWeaknessScoreV2]);
            }
            else {
                printf("block: %02lu, ", (unsigned long)udfFunc.exportV2.bbArray.count);
                printf("edge: %02lu, ", (unsigned long)udfFunc.exportV2.edgeArray.count);
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV2 getInstructionCount]);
            }
            printf("%s", [self formatFunctionName:[udfFunc.exportV2 getName]].UTF8String);
            printf("\n");
        }
        
        if (udfFuncArray.count > 0) {
            printf("\n");
        }
    }
}

- (void)printFunctions_Changed:(FunctionSortType)sortType;
{
    if (_printSwitch == NO) {
        return;
    }
    
    @autoreleasepool {
        NSArray *udfFuncArray = [_udfModule getFunction_Changed_Normal];
        if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByInstructionBlockEdgeCountV1:)];
        }
        else if (sortType == FunctionSortType_BlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByBlockEdgeCountV1:)];
        }
        else if (sortType == FunctionSortType_WeaknessScore) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByWeaknessScoreV1:)];
        }
        else {
            [udfFuncArray sortedArrayUsingSelector:@selector(compareByAddrV2:)];
        }
        printf("[+] changed function count: %lu\n", udfFuncArray.count);
        
        for (int idx = 0; idx < udfFuncArray.count; ++idx) {
            UDF_Function *udfFunc = udfFuncArray[idx];
            /*
            BOOL cntNotEqualBlock = udfFunc.exportV1.bbArray.count != udfFunc.exportV2.bbArray.count;
            BOOL cntNotEqualEdge = udfFunc.exportV1.edgeArray.count != udfFunc.exportV2.edgeArray.count;
            
            if (cntNotEqualBlock || cntNotEqualEdge) {
                printf(COLOR_LRED);
            }
             */
            
            printf("addr1: 0x%06llX, ", udfFunc.diff.refFunc.address1);
            printf("addr2: 0x%06llX, ", udfFunc.diff.refFunc.address2);
            printf("flag: %s, ", [udfFunc getFuncDiffFlagsStr].UTF8String);
            if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
                printf("block: %03lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                printf("edge: %03lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
            }
            else if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
                printf("block: %03lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                printf("edge: %03lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
            }
            else if (sortType == FunctionSortType_WeaknessScore) {
                printf("score: %f, ", [udfFunc getWeaknessScoreV1]);
            }
            else {
                //printf("block: %04lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                //printf("edge: %04lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
                //printf("block-v2: %04lu, ", (unsigned long)udfFunc.exportV2.bbArray.count);
                //printf("edge-v2: %04lu, ", (unsigned long)udfFunc.exportV2.edgeArray.count);
            }
            printf("%s", [self formatFunctionName:udfFunc.diff.refFunc.name1].UTF8String);
            printf("\n");
            
            /*
            if (cntNotEqualBlock || cntNotEqualEdge) {
                printf(COLOR_RESET);
            }
             */
        }
        printf("\n\n");
        
        for (int idx = 0; idx < udfFuncArray.count; ++idx) {
            UDF_Function *udfFunc = udfFuncArray[idx];
            
            printf("%d/%lu, ", idx + 1, (unsigned long)udfFuncArray.count);
            printf("addr1: 0x%06llX, ", udfFunc.diff.refFunc.address1);
            printf("addr2: 0x%06llX, ", udfFunc.diff.refFunc.address2);
            printf("flag: %s, ", [udfFunc getFuncDiffFlagsStr].UTF8String);
            printf("%s", [self formatFunctionName:udfFunc.diff.refFunc.name1].UTF8String);
            printf("\n\n");
            
            [self printFunction:udfFunc];
            
            printf("==============================================================================================\n\n\n");
        }
    }
}

- (void)printFunction:(UDF_Function *)udfFunc
{
    @autoreleasepool {
        NSArray<UDF_BasicBlock *> *bbArray = [udfFunc getBasicBlock_WithoutIdentical];
        bbArray = [bbArray sortedArrayUsingSelector:@selector(compareByAddrAndDeltaV1V2:)];
        for (int idx = 0; idx < bbArray.count; ++idx) {
            UDF_BasicBlock *udfBBObj = bbArray[idx];
            if ((udfBBObj.actionType & UDF_ActionType_ActionMask) == UDF_ActionType_Changed) {
                printf("    [C] 0x%06llX, 0x%06llX, %d/%lu\n", udfBBObj.exportV1.addr, udfBBObj.exportV2.addr, idx + 1, (unsigned long)bbArray.count);
            }
            else if ((udfBBObj.actionType & UDF_ActionType_ActionMask) == UDF_ActionType_Deleted) {
                printf("    [D] 0x%06llX, %d/%lu\n", udfBBObj.exportV1.addr, idx + 1, (unsigned long)bbArray.count);
            }
            else if ((udfBBObj.actionType & UDF_ActionType_ActionMask) == UDF_ActionType_Added) {
                printf("    [A] 0x%06llX, %d/%lu\n", udfBBObj.exportV2.addr, idx + 1, (unsigned long)bbArray.count);
            }
            else if ((udfBBObj.actionType & UDF_ActionType_ActionMask) == UDF_ActionType_Identical) {
                printf("    [I] 0x%06llX, 0x%06llX, %d/%lu\n", udfBBObj.exportV1.addr, udfBBObj.exportV2.addr, idx + 1, (unsigned long)bbArray.count);
            }
            
            [self printBasicBlock:udfBBObj];
            if (idx != bbArray.count - 1) {
                printf("    ----------------------------------------------------------------\n");
                printf("\n");
            }
        }
    }
}

- (void)printBasicBlock:(UDF_BasicBlock *)udfBlock
{
    @autoreleasepool {
        NSArray<UDF_Instruction *> *instArray = nil;
        if (self.blockInstPrintType == BlockInstructionPrintType_Changed) {
            instArray = [udfBlock getInstruction_Changed_Deleted_Sorted];
        }
        else {
            instArray = [udfBlock getInstruction_All_Sorted];
        }
        
        for (int idx = 0; idx < instArray.count; ++idx) {
            UDF_Instruction *udfInstObj = instArray[idx];
            NSString *disStrV1 = [udfInstObj.exportV1 getDisassembly];
            NSString *disStrV2 = [udfInstObj.exportV2 getDisassembly];
            [self printInstruction:udfInstObj.actionType disStrV1:disStrV1 disStrV2:disStrV2];
        }
    }
}

- (void)printInstruction:(UDF_ActionType)actionType disStrV1:(NSString *)disStrV1 disStrV2:(NSString *)disStrV2
{
    static int const part1Len = 42;
    int count = 0;
    
    if (actionType & UDF_ActionType_Deleted) {
        count = printf(COLOR_HRED "        %s", disStrV1.UTF8String);
        count -= strlen(COLOR_HRED);
        
        while (count < part1Len) {
            printf(" ");
            ++count;
        }
        
        printf("\n" COLOR_RESET);
    }
    else if (actionType & UDF_ActionType_Added) {
        count = 0;
        while (count < part1Len) {
            printf(" ");
            ++count;
        }
        printf(COLOR_LBLU " %s\n" COLOR_RESET, disStrV2.UTF8String);
    }
    // UDF_ActionType_Changed
    else if (actionType & UDF_ActionType_Changed) {
        count = printf(COLOR_HMAG "        %s" COLOR_RESET, disStrV1.UTF8String);
        count -= strlen(COLOR_HMAG) + strlen(COLOR_RESET);
        
        while (count < part1Len) {
            printf(" ");
            ++count;
        }
        
        printf(COLOR_HMAG " %s\n" COLOR_RESET, disStrV2.UTF8String);
    }
    // UDF_ActionType_Identical
    else if (actionType & UDF_ActionType_Identical) {
        if ([disStrV1 isEqualToString:disStrV2]) {
            count = printf("        %s", disStrV1.UTF8String);
            while (count < part1Len) {
                printf(" ");
                ++count;
            }
            printf(" %s\n", disStrV2.UTF8String);
        }
        else {
            count = printf(COLOR_GRN "        %s" COLOR_RESET, disStrV1.UTF8String);
            count -= strlen(COLOR_GRN) + strlen(COLOR_RESET);
            
            while (count < part1Len) {
                printf(" ");
                ++count;
            }
            
            printf(COLOR_GRN " %s\n" COLOR_RESET, disStrV2.UTF8String);
        }
    }
}

- (void)setBlockInstructionsPrintType:(BlockInstructionPrintType)blockInstPrintType
{
    self.blockInstPrintType = blockInstPrintType;
}

- (void)setFunctionNameOutputFlag:(FunctionNameOutputFlag)funcNameOutputFlag
{
    self.funcNameOutputFlag = funcNameOutputFlag;
}

- (void)printFunctions_Identical:(FunctionSortType)sortType
{
    if (_printSwitch == NO) {
        return;
    }
    
    @autoreleasepool {
        NSArray *udfFuncArray = [_udfModule getFunction_Identical_Normal];
        if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByInstructionBlockEdgeCountV1:)];
        }
        else if (sortType == FunctionSortType_BlockEdgeCount) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByBlockEdgeCountV1:)];
        }
        else if (sortType == FunctionSortType_WeaknessScore) {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByWeaknessScoreV1:)];
        }
        else {
            udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByAddrV1:)];
        }
        printf("[+] identical function count: %lu\n", udfFuncArray.count);
        
        for (int idx = 0; idx < udfFuncArray.count; ++idx) {
            UDF_Function *udfFunc = udfFuncArray[idx];
            
            printf("addr1: 0x%06llX, ", udfFunc.diff.refFunc.address1);
            printf("addr2: 0x%06llX, ", udfFunc.diff.refFunc.address2);
            if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
                printf("block: %03lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                printf("edge: %03lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
            }
            else if (sortType == FunctionSortType_WeaknessScore) {
                printf("score: %f, ", [udfFunc getWeaknessScoreV1]);
            }
            else {
                printf("block: %03lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
                printf("edge: %03lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
                printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
            }
            
            printf("%s", [self formatFunctionName:udfFunc.diff.refFunc.name1].UTF8String);
            printf("\n");
        }
        
        if (udfFuncArray.count > 0) {
            printf("\n");
        }
    }
}

- (void)printFunctionsSummaryV1:(NSArray<UDF_Function *> *)udfFuncArray sortType:(FunctionSortType)sortType
{
    if (_printSwitch == NO) {
        return;
    }
    
    if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByInstructionBlockEdgeCountV1:)];
    }
    else if (sortType == FunctionSortType_BlockEdgeCount) {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByBlockEdgeCountV1:)];
    }
    else if (sortType == FunctionSortType_WeaknessScore) {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByWeaknessScoreV1:)];
    }
    else {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByAddrV1:)];
    }
    printf("[+] v1 function count: %lu\n", udfFuncArray.count);
    
    for (int idx = 0; idx < udfFuncArray.count; ++idx) {
        UDF_Function *udfFunc = udfFuncArray[idx];
        
        printf("addr: 0x%06llX, ", udfFunc.diff.refFunc.address1);
        if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
            printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
            printf("block: %03lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
            printf("edge: %03lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
        }
        else if (sortType == FunctionSortType_WeaknessScore) {
            //printf("score: %06.3f, ", [udfFunc getWeaknessScoreV1]);
            printf("score: %.3f, ", [udfFunc getWeaknessScoreV1]);
        }
        else {
            printf("block: %03lu, ", (unsigned long)udfFunc.exportV1.bbArray.count);
            printf("edge: %03lu, ", (unsigned long)udfFunc.exportV1.edgeArray.count);
            printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV1 getInstructionCount]);
        }
        
        printf("%s", [self formatFunctionName:[udfFunc.exportV1 getName]].UTF8String);
        printf("\n");
    }
    
    if (udfFuncArray.count > 0) {
        printf("\n");
    }
}

- (void)printFunctionsSummaryV2:(NSArray<UDF_Function *> *)udfFuncArray sortType:(FunctionSortType)sortType
{
    if (_printSwitch == NO) {
        return;
    }
    
    if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByInstructionBlockEdgeCountV2:)];
    }
    else if (sortType == FunctionSortType_BlockEdgeCount) {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByBlockEdgeCountV2:)];
    }
    else if (sortType == FunctionSortType_WeaknessScore) {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByWeaknessScoreV2:)];
    }
    else {
        udfFuncArray = [udfFuncArray sortedArrayUsingSelector:@selector(compareByAddrV2:)];
    }
    printf("[+] v2 function count: %lu\n", udfFuncArray.count);
    
    for (int idx = 0; idx < udfFuncArray.count; ++idx) {
        UDF_Function *udfFunc = udfFuncArray[idx];
        
        printf("addr: 0x%06llX, ", udfFunc.diff.refFunc.address2);
        if (sortType == FunctionSortType_InstructionBlockEdgeCount) {
            printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV2 getInstructionCount]);
            printf("block: %03lu, ", (unsigned long)udfFunc.exportV2.bbArray.count);
            printf("edge: %03lu, ", (unsigned long)udfFunc.exportV2.edgeArray.count);
        }
        else if (sortType == FunctionSortType_WeaknessScore) {
            printf("score: %.3f, ", [udfFunc getWeaknessScoreV2]);
        }
        else {
            printf("block: %03lu, ", (unsigned long)udfFunc.exportV2.bbArray.count);
            printf("edge: %03lu, ", (unsigned long)udfFunc.exportV2.edgeArray.count);
            printf("inst: %04lu, ", (unsigned long)[udfFunc.exportV2 getInstructionCount]);
        }
        
        printf("%s", [self formatFunctionName:[udfFunc.exportV2 getName]].UTF8String);
        printf("\n");
    }
    
    if (udfFuncArray.count > 0) {
        printf("\n");
    }
}

- (void)printModule
{
    [self printFunctions_Deleted:FunctionSortType_Address];
    [self printFunctions_Added:FunctionSortType_Address];
    [self printFunctions_Changed:FunctionSortType_Address];
    
    printf("\n");
}

- (void)enablePrint
{
    _printSwitch = YES;
}

- (void)disablePrint
{
    _printSwitch = NO;
}

@end
