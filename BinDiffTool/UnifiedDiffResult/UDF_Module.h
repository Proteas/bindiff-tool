//
//  UDF_Module.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UDF_Common.h"

@class BDLM_Module;
@class BELM_Module;
@class UDF_Function;

@protocol JS_UDF_Module <JSExport>

- (NSArray<UDF_Function *> *)getFunction_Added;
- (NSArray<UDF_Function *> *)getFunction_Deleted;
- (NSArray<UDF_Function *> *)getFunction_Changed;
- (NSArray<UDF_Function *> *)getFunction_Identical;
- (NSArray<UDF_Function *> *)getFunction_WithActionMask:(UDF_ActionType)actionMask;

- (void)removeFunction:(UDF_Function *)funcObj;
- (void)removeFunctions:(NSArray *)funcArray;

- (UDF_Function *)getFunctionWithAddr:(uint64_t)addr dataSel:(UDF_DataSelector)dataSel;
- (UDF_Function *)getFunctionWithName:(NSString *)funcName dataSel:(UDF_DataSelector)dataSel;

@end

@interface UDF_Module : NSObject <JS_UDF_Module>
{
    //
}

- (instancetype)initWithDiff:(BDLM_Module *)diff
                    exportV1:(BELM_Module *)exportV1
                    exportV2:(BELM_Module *)exportV2;

- (NSArray<UDF_Function *> *)getFunction_All;
- (NSArray<UDF_Function *> *)getFunction_Deleted_Normal;
- (NSArray<UDF_Function *> *)getFunction_Added_Normal;
- (NSArray<UDF_Function *> *)getFunction_Changed_Normal;
- (NSArray<UDF_Function *> *)getFunction_Identical_Normal;

- (void)removeFunction_Identical;

@end
