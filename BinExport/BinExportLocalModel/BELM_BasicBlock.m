//
//  BELM_BasicBlock.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import "BELM_BasicBlock.h"
#import "GPBProtocolBuffers.h"
#import "Binexport2.pbobjc.h"
#import "BinExport_Helper.h"
#import "BELM_Instruction.h"
#import "BELM_Module.h"

@interface BELM_BasicBlock ()
{
    NSMutableDictionary<NSNumber *, BELM_Instruction *> *_addrToInstMap;
}

@property(nonatomic, retain) NSMutableDictionary *addrToInstMap;

- (BOOL)transformFrom:(BinExport2 *)binExp2 index:(int32_t)index;
- (void)buildMap;
- (void)collectCallTargetAddr;

@end

@implementation BELM_BasicBlock

@synthesize addr = _addr;
@synthesize instArray = _instArray;
@synthesize addrToInstMap = _addrToInstMap;
@synthesize callTargetAddrArray = _callTargetAddrArray;
@synthesize blockIndex = _blockIndex;
@synthesize deltaAddr = _deltaAddr;
@synthesize isEntry = _isEntry;
@synthesize callTargetNameArray = _callTargetNameArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 index:(int32_t)index
{
    if ((self = [super init])) {
        _instArray = [[NSMutableArray alloc] init];
        _addrToInstMap = [[NSMutableDictionary alloc] init];
        _callTargetAddrArray = [[NSMutableArray alloc] init];
        _blockIndex = index;
        _callTargetNameArray = [[NSMutableArray alloc] init];
        
        if ([self transformFrom:binExp2 index:index] == NO) {
            [self release];
            self = nil;
        }
        else {
            [self buildMap];
            [self collectCallTargetAddr];
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.instArray = nil;
    self.addrToInstMap = nil;
    self.callTargetAddrArray = nil;
    self.callTargetNameArray = nil;
    
    [super dealloc];
}

- (BOOL)transformFrom:(BinExport2 *)binExp2 index:(int32_t)index
{
    _addr = BEH_GetBBlockFirstInstAddr(binExp2, index);
    
    BinExport2_BasicBlock *bblock = [binExp2.basicBlockArray objectAtIndex:index];
    for (BinExport2_BasicBlock_IndexRange *instRange in bblock.instructionIndexArray) {
        if (instRange.hasBeginIndex == NO) {
            printf("[-] %s: instruction range has no begin index\n", __FUNCTION__);
            continue;
        }
        
        int32_t instRangeIdx = instRange.beginIndex;
        do {
            BELM_Instruction *instObj = [[BELM_Instruction alloc] initWithBinExport:binExp2 index:instRangeIdx];
            if (instObj) {
                instObj.deltaAddr = instObj.addr - self.addr;
#if (0)
                if (instObj.deltaAddr < 0) {
                    printf("[-] %s: inst addr delta less than 0: %lld, block: 0x%llX, inst: 0x%llX\n", __FUNCTION__, instObj.deltaAddr, _addr, instObj.addr);
                }
#endif
                [self.instArray addObject:instObj];
            }
            else {
                printf("[-] %s: fail to transform instruction\n", __FUNCTION__);
            }
            
            [instObj release];
            instObj = nil;
            
            ++instRangeIdx;
        } while (instRange.hasEndIndex && (instRangeIdx < instRange.endIndex));
    }
    
    return YES;
}

- (void)buildMap
{
    for (BELM_Instruction *instObj in self.instArray) {
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:instObj.addr];
        [_addrToInstMap setObject:instObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (void)collectCallTargetAddr
{
    for (BELM_Instruction *instObj in self.instArray) {
        [_callTargetAddrArray addObjectsFromArray:instObj.callTargetAddrArray];
    }
}

- (BELM_Instruction *)getInstructionWithAddr:(uint64_t)addr
{
    NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
    BELM_Instruction *instObj = [_addrToInstMap objectForKey:addrObj];
    [addrObj release];
    addrObj = nil;
    
    return instObj;
}

- (BOOL)hasInstructionWithAddr:(uint64_t)addr
{
    BELM_Instruction *instObj = [self getInstructionWithAddr:addr];
    
    return (instObj != nil);
}

- (void)dumpInstructions
{
    for (BELM_Instruction *inst in self.instArray) {
        printf("    0x%llX: %s\n", inst.addr, [inst getDisassembly].UTF8String);
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    BELM_BasicBlock *obj2 = (BELM_BasicBlock *)object;
    if ((self.instArray == nil) || (obj2.instArray == nil)) {
        return NO;
    }
    
    if (self.instArray.count != obj2.instArray.count) {
        return NO;
    }
    
    for (int idx = 0; idx < self.instArray.count; ++idx) {
        BELM_Instruction *instObj = [self.instArray objectAtIndex:idx];
        BELM_Instruction *instObj2 = [obj2.instArray objectAtIndex:idx];
        if ([instObj isEqual:instObj2] == NO) {
            return NO;
        }
    }
    
    return YES;
}

- (void)postProcess:(BELM_Module *)belmModule
{
    for (BELM_Instruction *instObj in self.instArray) {
        [instObj postProcess:belmModule];
    }
    
    for (BELM_Instruction *instObj in self.instArray) {
        [_callTargetNameArray addObjectsFromArray:instObj.callTargetNameArray];
    }
}

- (NSUInteger)getInstructionCount
{
    return self.instArray.count;
}

@end
