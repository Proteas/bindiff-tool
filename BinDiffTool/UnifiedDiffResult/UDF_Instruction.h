//
//  UDF_Instruction.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/26.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UDF_Common.h"

@class BDLM_Instruction;
@class BELM_Instruction;
@class UDF_BasicBlock;
@class UDF_Instruction;

@protocol JS_UDF_Instruction <JSExport>

- (UDF_ActionType)getActionType;
- (uint64_t)getAddr:(UDF_DataSelector)dataSel;
- (NSArray *)getCallTargetAddrs:(UDF_DataSelector)dataSel;
- (NSArray *)getCallTargetNames:(UDF_DataSelector)dataSel;

- (NSString *)getDisassembly:(UDF_DataSelector)dataSel;
- (NSString *)getMnem:(UDF_DataSelector)dataSel;
- (NSString *)getJoinedOperands:(UDF_DataSelector)dataSel;
- (NSArray *)getOperandsArray:(UDF_DataSelector)dataSel;

- (BOOL)isDeletedStrictEqualToAdded:(UDF_Instruction *)instAdded;
- (BOOL)hasData:(UDF_DataSelector)dataSel;

- (void)manualSetActionType:(UDF_ActionType)actionType;

@end

@interface UDF_Instruction : NSObject <JS_UDF_Instruction>
{
    UDF_ActionType _actionType;
    BDLM_Instruction *_diff;
    BELM_Instruction *_exportV1;
    BELM_Instruction *_exportV2;
    UDF_BasicBlock *_backRef;
}

@property(nonatomic, assign) UDF_ActionType actionType;
@property(nonatomic, retain, readonly) BDLM_Instruction *diff;
@property(nonatomic, retain, readonly) BELM_Instruction *exportV1;
@property(nonatomic, retain, readonly) BELM_Instruction *exportV2;
@property(nonatomic, assign) UDF_BasicBlock *backRef;

- (instancetype)initWithType:(UDF_ActionType)actionType
                        Diff:(BDLM_Instruction *)diff
                    exportV1:(BELM_Instruction *)exportV1
                    exportV2:(BELM_Instruction *)exportV2;

- (BOOL)isEqual:(id)object;
- (NSComparisonResult)compareByAddrV1:(UDF_Instruction *)another;
- (NSComparisonResult)compareByAddrV2:(UDF_Instruction *)another;
- (NSComparisonResult)compareByAddrAndDeltaV1V2:(UDF_Instruction *)another;

@end
