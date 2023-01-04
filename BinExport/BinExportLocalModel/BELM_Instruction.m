//
//  BELM_Instruction.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import "BELM_Instruction.h"
#import "GPBProtocolBuffers.h"
#import "Binexport2.pbobjc.h"
#import "BinExport_Helper.h"
#import "BELM_Operand.h"
#import "BELM_Module.h"

@interface BELM_Instruction ()
{
    NSData *_rawBytes;
}

@property(nonatomic, retain) NSMutableArray *commentArray;

- (BOOL)transformFrom:(BinExport2 *)binExp2 index:(int32_t)index;

- (void)parseCallTargets:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst;
- (void)parseComments:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst;
- (void)parseMnemonic:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst;
- (void)parseOperand:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst;

@end

@implementation BELM_Instruction

@synthesize mnem = _mnem;
@synthesize opArray = _opArray;
@synthesize callTargetAddrArray = _callTargetAddrArray;
@synthesize commentArray = _commentArray;
@synthesize rawBytes = _rawBytes;
@synthesize addr = _addr;
@synthesize instIndex = _instIndex;
@synthesize deltaAddr = _deltaAddr;
@synthesize callTargetNameArray = _callTargetNameArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 index:(int32_t)index
{
    if ((self = [super init])) {
        _addr = BEH_GetInstAddr(binExp2, index);
        if (_addr == 0) {
            printf("[-] inst addr zero, index: %d\n", index);
        }
        
        _instIndex = index;
        _opArray = [[NSMutableArray alloc] init];
        _callTargetAddrArray = [[NSMutableArray alloc] init];
        _commentArray = [[NSMutableArray alloc] init];
        _callTargetNameArray = [[NSMutableArray alloc] init];
        
        if ([self transformFrom:binExp2 index:index] == NO) {
            [self release];
            self = nil;
        }
        else {
            //
        }
    }
    
    return self;
}

- (void)dealloc
{
    _addr = -1;
    self.mnem = nil;
    self.opArray = nil;
    self.callTargetAddrArray = nil;
    self.commentArray = nil;
    self.rawBytes = nil;
    self.callTargetNameArray = nil;
    
    [super dealloc];
}

- (void)parseCallTargets:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst
{
    if (inst.callTargetArray_Count == 0) {
        return;
    }
    
    for (int32_t idx = 0; idx < inst.callTargetArray.count; ++idx) {
        uint64_t targetAddr = [inst.callTargetArray valueAtIndex:idx];
        [self.callTargetAddrArray addObject:[NSNumber numberWithUnsignedLongLong:targetAddr]];
    }
}

- (void)parseComments:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst
{
    if (inst.commentIndexArray_Count == 0) {
        return;
    }
    
    for (int32_t loopIdx = 0; loopIdx < inst.commentIndexArray_Count; ++loopIdx) {
        int32_t commentIdx = [inst.commentIndexArray valueAtIndex:loopIdx];
        BinExport2_Comment *comm = [binExp2.commentArray objectAtIndex:commentIdx];
        NSString *tmpStr = [binExp2.stringTableArray objectAtIndex:comm.stringTableIndex];
        [self.commentArray addObject:tmpStr];
    }
}

- (void)parseMnemonic:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst
{
    BinExport2_Mnemonic *mnem = [binExp2.mnemonicArray objectAtIndex:inst.mnemonicIndex];
    self.mnem = mnem.name;
}

- (void)parseOperand:(BinExport2 *)binExp2 instruction:(BinExport2_Instruction *)inst
{
    for (int32_t opLoopIdx = 0; opLoopIdx < inst.operandIndexArray.count; ++opLoopIdx) {
        int32_t opIdx = [inst.operandIndexArray valueAtIndex:opLoopIdx];
        BELM_Operand *opObj = [[BELM_Operand alloc] initWithBinExport:binExp2 index:opIdx];
        if (opObj) {
            [self.opArray addObject:opObj];
        }
        else {
            printf("[-] %s: fail to transform operand\n", __FUNCTION__);
        }
        
        [opObj release];
        opObj = nil;
    }
}

- (BOOL)transformFrom:(BinExport2 *)binExp2 index:(int32_t)index
{
    _addr = BEH_GetInstAddr(binExp2, index);
    
    BinExport2_Instruction *inst = [binExp2.instructionArray objectAtIndex:index];
    self.rawBytes = inst.rawBytes;
    
    [self parseCallTargets:binExp2 instruction:inst];
    [self parseComments:binExp2 instruction:inst];
    [self parseMnemonic:binExp2 instruction:inst];
    [self parseOperand:binExp2 instruction:inst];
    
    return YES;
}

- (NSString *)getDisassembly
{
    if (self.opArray.count == 0) {
        return self.mnem;
    }
    
    NSString *retStr = [NSString stringWithFormat:@"%@ %@", self.mnem, [self getJoinedOperands]];
    
    return retStr;
}

- (NSString *)getJoinedOperands
{
    NSMutableString *retStr = [NSMutableString string];
    
    for (int idx = 0; idx < self.opArray.count; ++idx) {
        BELM_Operand *opObj = [self.opArray objectAtIndex:idx];
        [retStr appendString:[opObj getExpression]];
        if (idx != (self.opArray.count - 1)) {
            [retStr appendString:@", "];
        }
    }
    
    return retStr;
}

- (NSArray *)getOperandsArray
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (BELM_Operand *opObj in self.opArray) {
        [retArray addObject:[opObj getExpression]];
    }
    
    return retArray;
}

- (NSString *)getCallTargetStr
{
    NSMutableString *retStr = [NSMutableString string];
    
    // call target
    for (int idx = 0; idx < self.callTargetAddrArray.count; ++idx) {
        [retStr appendFormat:@"0x%llX", [[self.callTargetAddrArray objectAtIndex:idx] unsignedLongLongValue]];
        if (idx != self.callTargetAddrArray.count - 1) {
            [retStr appendString:@", "];
        }
    }
    
    return retStr;
}

- (NSString *)getComments
{
    NSMutableString *retStr = [NSMutableString string];
    
    // comments
    for (int idx = 0; idx < self.commentArray.count; ++idx) {
        [retStr appendString:[self.commentArray objectAtIndex:idx]];
        if (idx != self.commentArray.count - 1) {
            [retStr appendString:@", "];
        }
    }
    
    return retStr;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    BELM_Instruction *obj2 = (BELM_Instruction *)object;
    if (self.mnem && obj2.mnem) {
        return [self.mnem isEqualToString:obj2.mnem];
    }
    else {
        return NO;
    }
}

- (void)postProcess:(BELM_Module *)belmModule
{
    for (NSNumber *addrObj in self.callTargetAddrArray) {
        NSString *funcName = [belmModule getFuncNameWithAddrObj:addrObj];
        if ([funcName length] == 0) {
            printf("[-] %s: fail to call function name: 0x%llX\n", __FUNCTION__, [addrObj unsignedLongLongValue]);
            continue;
        }
        
        [self.callTargetNameArray addObject:funcName];
    }
}

@end
