//
//  UDF_Module.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import "UDF_Module.h"
#import "BELM_Module.h"
#import "BDLM_Module.h"
#import "BELM_Function.h"
#import "BDLM_Function.h"
#import "UDF_Function.h"
#import "BinDiff_DB.h"

@interface UDF_Module ()
{
    NSMutableArray<UDF_Function *> *_funcArray;
    
    BELM_Module *_exportV1;
    BELM_Module *_exportV2;
}

@property(nonatomic, retain) NSMutableArray<UDF_Function *> *funcArray;
@property(nonatomic, retain) BELM_Module *exportV1;
@property(nonatomic, retain) BELM_Module *exportV2;

- (void)processWithDiff:(BDLM_Module *)diff
               exportV1:(BELM_Module *)exportV1
               exportV2:(BELM_Module *)exportV2;

- (NSArray<UDF_Function *> *)filterFunctions:(NSArray<UDF_Function *> *)funcArray withActionType:(UDF_ActionType)actionType;

- (NSArray<UDF_Function *> *)filterFunctions:(NSArray<UDF_Function *> *)funcArray withFuncType:(BELM_FunctionType)funcType;

@end

@implementation UDF_Module

@synthesize funcArray = _funcArray;
@synthesize exportV1 = _exportV1;
@synthesize exportV2 = _exportV2;

- (instancetype)initWithDiff:(BDLM_Module *)diff
                    exportV1:(BELM_Module *)exportV1
                    exportV2:(BELM_Module *)exportV2
{
    if ((self = [super init])) {
        _funcArray = [[NSMutableArray alloc] init];
        self.exportV1 = exportV1;
        self.exportV2 = exportV2;
        
        [self processWithDiff:diff exportV1:exportV1 exportV2:exportV2];
    }
    
    return self;
}

- (void)dealloc
{
    self.funcArray = nil;
    self.exportV1 = nil;
    self.exportV2 = nil;
    
    [super dealloc];
}

- (void)processWithDiff:(BDLM_Module *)diff
               exportV1:(BELM_Module *)exportV1
               exportV2:(BELM_Module *)exportV2
{
    for (BELM_Function *funcObjV1 in exportV1.funcArray) {
        BDLM_Function *funcDiff = [diff getFuncWithAddrV1:funcObjV1.addr];
        if (funcDiff == nil) {
            UDF_Function *udfFunc = [[UDF_Function alloc] initWithType:UDF_ActionType_Deleted Diff:nil exportV1:funcObjV1 exportV2:nil];
            udfFunc.backRef = self;
            [_funcArray addObject:udfFunc];
            [udfFunc release];
            udfFunc = nil;
        }
        else {
            BELM_Function *funcObjV2 = [exportV2 getFuncWithAddr:funcDiff.refFunc.address2];
            if (funcObjV2 == nil) {
                printf("[-] %s: can't find corresponded function object: 0x%llx\n", __FUNCTION__, funcDiff.refFunc.address2);
                continue;
            }
            
            if (funcDiff.refFunc.similarity != 1.0f) {
                UDF_Function *udfFunc = [[UDF_Function alloc] initWithType:UDF_ActionType_Changed Diff:funcDiff exportV1:funcObjV1 exportV2:funcObjV2];
                udfFunc.backRef = self;
                [_funcArray addObject:udfFunc];
                [udfFunc release];
                udfFunc = nil;
            }
            else {
                UDF_Function *udfFunc = [[UDF_Function alloc] initWithType:UDF_ActionType_Identical Diff:funcDiff exportV1:funcObjV1 exportV2:funcObjV2];
                [_funcArray addObject:udfFunc];
                udfFunc.backRef = self;
                [udfFunc release];
                udfFunc = nil;
            }
        }
    }
    
    for (BELM_Function *funcObjV2 in exportV2.funcArray) {
        BDLM_Function *funcDiff = [diff getFuncWithAddrV2:funcObjV2.addr];
        if (funcDiff == nil) {
            UDF_Function *udfFunc = [[UDF_Function alloc] initWithType:UDF_ActionType_Added Diff:nil exportV1:nil exportV2:funcObjV2];
            udfFunc.backRef = self;
            [_funcArray addObject:udfFunc];
            [udfFunc release];
            udfFunc = nil;
        }
    }
}

- (NSArray<UDF_Function *> *)filterFunctions:(NSArray<UDF_Function *> *)funcArray withActionType:(UDF_ActionType)actionType
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_Function *udfFunc in funcArray) {
        if (udfFunc.actionType & actionType) {
            [retArray addObject:udfFunc];
        }
    }
    
    return retArray;
}

- (NSArray<UDF_Function *> *)filterFunctions:(NSArray<UDF_Function *> *)funcArray withFuncType:(BELM_FunctionType)funcType
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_Function *udfFunc in funcArray) {
        if (udfFunc.exportV1.type == funcType) {
            [retArray addObject:udfFunc];
        }
    }
    
    return retArray;
}

- (NSArray<UDF_Function *> *)getFunction_All
{
    return self.funcArray;
}

- (NSArray<UDF_Function *> *)getFunction_Deleted
{
    return [self filterFunctions:self.funcArray withActionType:UDF_ActionType_Deleted];
}

- (NSArray<UDF_Function *> *)getFunction_Deleted_Normal
{
    return [self filterFunctions:[self getFunction_Deleted] withFuncType:BELM_FunctionType_Normal];
}

- (NSArray<UDF_Function *> *)getFunction_Added
{
    return [self filterFunctions:self.funcArray withActionType:UDF_ActionType_Added];
}

- (NSArray<UDF_Function *> *)getFunction_Added_Normal
{
    return [self filterFunctions:[self getFunction_Added] withFuncType:BELM_FunctionType_Normal];
}

- (NSArray<UDF_Function *> *)getFunction_Changed
{
    return [self filterFunctions:self.funcArray withActionType:UDF_ActionType_Changed];
}

- (NSArray<UDF_Function *> *)getFunction_Changed_Normal
{
    return [self filterFunctions:[self getFunction_Changed] withFuncType:BELM_FunctionType_Normal];
}

- (NSArray<UDF_Function *> *)getFunction_Identical
{
    return [self filterFunctions:self.funcArray withActionType:UDF_ActionType_Identical];
}

- (NSArray<UDF_Function *> *)getFunction_Identical_Normal
{
    return [self filterFunctions:[self getFunction_Identical] withFuncType:BELM_FunctionType_Normal];
}

- (NSArray<UDF_Function *> *)getFunction_WithActionMask:(UDF_ActionType)actionMask
{
    return [self filterFunctions:self.funcArray withActionType:actionMask];
}

- (void)removeFunction_Identical
{
    NSArray *funcArray_Identical = [self getFunction_Identical];
    for (UDF_Function *funcObj in funcArray_Identical) {
        [self removeFunction:funcObj];
    }
}

- (void)removeFunction:(UDF_Function *)funcObj
{
    [self.funcArray removeObject:funcObj];
}

- (void)removeFunctions:(NSArray *)funcArray
{
    for (UDF_Function *funcObj in funcArray) {
        [self.funcArray removeObject:funcObj];
    }
}

- (UDF_Function *)getFunctionWithAddr:(uint64_t)addr dataSel:(UDF_DataSelector)dataSel
{
    addr += JS_UINT64_DELTA;
    
    for (UDF_Function *funcObj in self.funcArray) {
        if ([funcObj getAddr:dataSel] == addr) {
            return funcObj;
        }
    }
    
    return nil;
}

- (UDF_Function *)getFunctionWithName:(NSString *)funcName dataSel:(UDF_DataSelector)dataSel
{
    for (UDF_Function *funcObj in self.funcArray) {
        if ([[funcObj getName:dataSel] isEqualToString:funcName]) {
            return funcObj;
        }
    }
    
    return nil;
}

@end
