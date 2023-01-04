//
//  UDF_BasicBlock.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/26.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UDF_Common.h"

@class BDLM_BasicBlock;
@class BELM_BasicBlock;
@class UDF_Instruction;
@class UDF_Function;
@class UDF_BasicBlock;

@protocol JS_UDF_BasicBlock <JSExport>

- (UDF_ActionType)getActionType;
- (uint64_t)getAddr:(UDF_DataSelector)dataSel;

- (NSArray<UDF_Instruction *> *)getInstruction_Deleted;
- (NSArray<UDF_Instruction *> *)getInstruction_Added;
- (NSArray<UDF_Instruction *> *)getInstruction_Identical;
- (NSArray<UDF_Instruction *> *)getInstructionWithActionTypeSorted:(UDF_ActionType)actionType;

- (NSArray *)getCallTargetAddrs:(UDF_DataSelector)dataSel;
- (NSArray *)getCallTargetNames:(UDF_DataSelector)dataSel;

- (void)removeInstruction:(UDF_Instruction *)instObj;
- (void)removeInstructions:(NSArray *)instArray;

- (BOOL)isAllActionType:(UDF_ActionType)actionType;
- (void)manualSetActionType:(UDF_ActionType)actionType;

- (BOOL)isDeletedStrictEqualToAdded:(UDF_BasicBlock *)bbAdded;
- (BOOL)hasData:(UDF_DataSelector)dataSel;

@end

@interface UDF_BasicBlock : NSObject <JS_UDF_BasicBlock>
{
    UDF_ActionType _actionType;
    BDLM_BasicBlock *_diff;
    BELM_BasicBlock *_exportV1;
    BELM_BasicBlock *_exportV2;
    UDF_Function *_backRef;
}

@property(nonatomic, assign) UDF_ActionType actionType;
@property(nonatomic, retain, readonly) BDLM_BasicBlock *diff;
@property(nonatomic, retain, readonly) BELM_BasicBlock *exportV1;
@property(nonatomic, retain, readonly) BELM_BasicBlock *exportV2;
@property(nonatomic, assign) UDF_Function *backRef;

- (instancetype)initWithType:(UDF_ActionType)actionType
                        Diff:(BDLM_BasicBlock *)diff
                    exportV1:(BELM_BasicBlock *)exportV1
                    exportV2:(BELM_BasicBlock *)exportV2;

- (BOOL)isEqual:(id)object;
- (NSComparisonResult)compareByAddrV1:(UDF_BasicBlock *)another;
- (NSComparisonResult)compareByAddrV2:(UDF_BasicBlock *)another;
- (NSComparisonResult)compareByAddrAndDeltaV1V2:(UDF_BasicBlock *)another;

- (NSArray<UDF_Instruction *> *)getInstruction_All;
- (NSArray<UDF_Instruction *> *)getInstruction_Changed;
- (NSArray<UDF_Instruction *> *)getInstruction_Changed_Deleted;
- (NSArray<UDF_Instruction *> *)getInstruction_WithoutIdentical;
- (NSArray<UDF_Instruction *> *)getInstruction_WithoutAdded;

- (NSArray<UDF_Instruction *> *)getInstruction_Changed_Deleted_Sorted;
- (NSArray<UDF_Instruction *> *)getInstruction_All_Sorted;

@end
