//
//  UDF_Function.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UDF_Common.h"

@class BDLM_Function;
@class BELM_Function;
@class UDF_BasicBlock;
@class UDF_Module;
@class BELM_Edge;

@protocol JS_UDF_Function <JSExport>

- (UDF_ActionType)getActionType;
- (uint64_t)getAddr:(UDF_DataSelector)dataSel;

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Deleted;
- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Added;
- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Changed;
- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Identical;

- (uint32_t)getFuncDiffFlags;
- (NSString *)getFuncDiffFlagsStr;

- (NSString *)getName:(UDF_DataSelector)dataSel;
- (int32_t)getBELMFuncType:(UDF_DataSelector)dataSel;

- (int32_t)getBlockCount:(UDF_DataSelector)dataSel;
- (int32_t)getEdgeCount:(UDF_DataSelector)dataSel;
- (NSArray<BELM_Edge *> *)getEdges:(UDF_DataSelector)dataSel;

- (NSArray *)getCallTargetAddrs:(UDF_DataSelector)dataSel;
- (NSArray *)getCallTargetNames:(UDF_DataSelector)dataSel;

- (void)removeBlock:(UDF_BasicBlock *)bbObj;
- (void)removeBlocks:(NSArray *)bbArray;
- (BOOL)hasData:(UDF_DataSelector)dataSel;

- (void)manualSetActionType:(UDF_ActionType)actionType;

- (NSNumber *)getSimilarity;
- (NSNumber *)getConfidence;

@end

@interface UDF_Function : NSObject <JS_UDF_Function>
{
    UDF_ActionType _actionType;
    BDLM_Function *_diff;
    BELM_Function *_exportV1;
    BELM_Function *_exportV2;
    UDF_Module *_backRef;
}

@property(nonatomic, assign) UDF_ActionType actionType;
@property(nonatomic, retain, readonly) BDLM_Function *diff;
@property(nonatomic, retain, readonly) BELM_Function *exportV1;
@property(nonatomic, retain, readonly) BELM_Function *exportV2;
@property(nonatomic, assign) UDF_Module *backRef;

- (instancetype)initWithType:(UDF_ActionType)actionType
                        Diff:(BDLM_Function *)diff
                    exportV1:(BELM_Function *)exportV1
                    exportV2:(BELM_Function *)exportV2;

- (BOOL)isEqual:(id)object;

- (NSComparisonResult)compareByAddrV1:(UDF_Function *)another;
- (NSComparisonResult)compareByAddrV2:(UDF_Function *)another;

- (NSComparisonResult)compareByBlockCountV1:(UDF_Function *)another;
- (NSComparisonResult)compareByBlockCountV2:(UDF_Function *)another;

- (NSComparisonResult)compareByEdgeCountV1:(UDF_Function *)another;
- (NSComparisonResult)compareByEdgeCountV2:(UDF_Function *)another;

- (NSComparisonResult)compareByInstCountV1:(UDF_Function *)another;
- (NSComparisonResult)compareByInstCountV2:(UDF_Function *)another;

- (NSComparisonResult)compareByBlockEdgeCountV1:(UDF_Function *)another;
- (NSComparisonResult)compareByBlockEdgeCountV2:(UDF_Function *)another;

- (NSComparisonResult)compareByInstructionBlockEdgeCountV1:(UDF_Function *)another;
- (NSComparisonResult)compareByInstructionBlockEdgeCountV2:(UDF_Function *)another;

- (double)getWeaknessScoreV1;
- (double)getWeaknessScoreV2;

- (NSComparisonResult)compareByWeaknessScoreV1:(UDF_Function *)another;
- (NSComparisonResult)compareByWeaknessScoreV2:(UDF_Function *)another;

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_All;
- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Changed_Deleted;
- (NSArray<UDF_BasicBlock *> *)getBasicBlock_WithoutIdentical;

@end
