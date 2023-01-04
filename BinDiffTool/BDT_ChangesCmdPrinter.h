//
//  BinDiff_ListChanged.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class UDF_Module;
@class UDF_Function;

typedef enum _FunctionSortType {
    FunctionSortType_Address = 1,
    FunctionSortType_BlockEdgeCount = 2,
    FunctionSortType_InstructionBlockEdgeCount = 3,
    FunctionSortType_WeaknessScore = 4,
} FunctionSortType;

typedef enum _BlockInstructionPrintType {
    BlockInstructionPrintType_All = 1,
    BlockInstructionPrintType_Changed = 2,
} BlockInstructionPrintType;

typedef enum _FunctionNameOutputFlag {
    FunctionNameOutputFlag_Full = 1,
    FunctionNameOutputFlag_Tiny = 2,
} FunctionNameOutputFlag;

@protocol JS_BDT_ChangesCmdPrinter <JSExport>

- (void)printFunctions_Deleted:(FunctionSortType)sortType;
- (void)printFunctions_Added:(FunctionSortType)sortType;
- (void)printFunctions_Changed:(FunctionSortType)sortType;
- (void)setBlockInstructionsPrintType:(BlockInstructionPrintType)blockInstPrintType;
- (void)printFunctions_Identical:(FunctionSortType)sortType;

- (void)setFunctionNameOutputFlag:(FunctionNameOutputFlag)funcNameOutputFlag;

- (void)printFunctionsSummaryV1:(NSArray<UDF_Function *> *)udfFuncArray sortType:(FunctionSortType)sortType;
- (void)printFunctionsSummaryV2:(NSArray<UDF_Function *> *)udfFuncArray sortType:(FunctionSortType)sortType;

- (void)enablePrint;
- (void)disablePrint;

@end

@interface BDT_ChangesCmdPrinter : NSObject <JS_BDT_ChangesCmdPrinter>
{
    //
}

- (instancetype)initWithModule:(UDF_Module *)udfModule;
- (void)printModule;

@end
