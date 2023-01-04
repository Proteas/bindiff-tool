//
//  UDF_BasicBlock.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/26.
//

#import "UDF_BasicBlock.h"
#import "BDLM_BasicBlock.h"
#import "BELM_BasicBlock.h"
#import "UDF_Instruction.h"
#import "BDLM_Instruction.h"
#import "BELM_Instruction.h"
#import "BinDiff_DB.h"
#import "UDF_Function.h"

@interface UDF_BasicBlock ()
{
    NSMutableArray<UDF_Instruction *> *_instArray;
}

@property(nonatomic, retain) NSMutableArray<UDF_Instruction *> *instArray;

- (void)processWithDiff:(BDLM_BasicBlock *)diff
               exportV1:(BELM_BasicBlock *)exportV1
               exportV2:(BELM_BasicBlock *)exportV2;

- (void)processBasicBlockChangedWithDiff:(BDLM_BasicBlock *)diff
                                exportV1:(BELM_BasicBlock *)exportV1
                                exportV2:(BELM_BasicBlock *)exportV2;

- (NSArray<UDF_Instruction *> *)filterInstructions:(NSArray<UDF_Instruction *> *)instArray withActionType:(UDF_ActionType)actionType;

- (NSArray *)getObjectsFrom:(NSArray *)inputArray addrLessThan:(uint64_t)baseAddr;
- (NSArray<UDF_Instruction *> *)insertAddedArray:(NSArray *)addedArray toArray:(NSArray *)toArray;

@end

@implementation UDF_BasicBlock

@synthesize instArray = _instArray;
@synthesize backRef = _backRef;

- (instancetype)initWithType:(UDF_ActionType)actionType
                        Diff:(BDLM_BasicBlock *)diff
                    exportV1:(BELM_BasicBlock *)exportV1
                    exportV2:(BELM_BasicBlock *)exportV2
{
    if ((self = [super init])) {
        self.actionType = actionType;
        _instArray = [[NSMutableArray alloc] init];
        
        _diff = [diff retain];
        _exportV1 = [exportV1 retain];
        _exportV2 = [exportV2 retain];
        
        [self processWithDiff:diff exportV1:exportV1 exportV2:exportV2];
    }
    
    return self;
}

- (void)dealloc
{
    self.instArray = nil;
    self.backRef = nil;
    
    if (_diff) {
        [_diff release];
        _diff = nil;
    }
    
    if (_exportV1) {
        [_exportV1 release];
        _exportV1 = nil;
    }
    
    if (_exportV2) {
        [_exportV2 release];
        _exportV2 = nil;
    }
    
    [super dealloc];
}

- (void)processBasicBlockChangedWithDiff:(BDLM_BasicBlock *)diff
                                exportV1:(BELM_BasicBlock *)exportV1
                                exportV2:(BELM_BasicBlock *)exportV2
{
    for (BELM_Instruction *instObjV1 in exportV1.instArray) {
        BDLM_Instruction *instDiff = [diff getInstructionWithAddrV1:instObjV1.addr];
        if (instDiff == nil) {
            UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Deleted Diff:nil exportV1:instObjV1 exportV2:nil];
            udfInst.backRef = self;
            [self.instArray addObject:udfInst];
            [udfInst release];
            udfInst = nil;
        }
        else {
            BELM_Instruction *instObjV2 = [exportV2 getInstructionWithAddr:instDiff.refInst.address2];
            if (instObjV2 == nil) {
                printf("[-] %s: can't find inst in export 2, addr1: 0x%llX, addr2: 0x%llX\n", __FUNCTION__, self.diff.refBasicBlock.address1, self.diff.refBasicBlock.address2);
                continue;
            }
            
            if ([instObjV1 isEqual:instObjV2] == YES) {
                //printf("[-] %s: has instruction diff, but instructions are equal\n", __FUNCTION__);
                UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Identical Diff:instDiff exportV1:instObjV1 exportV2:instObjV2];
                udfInst.backRef = self;
                [self.instArray addObject:udfInst];
                [udfInst release];
                udfInst = nil;
            }
            else {
                UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Changed Diff:instDiff exportV1:instObjV1 exportV2:instObjV2];
                udfInst.backRef = self;
                [self.instArray addObject:udfInst];
                [udfInst release];
                udfInst = nil;
            }
        }
    }
    
    for (BELM_Instruction *instObjV2 in exportV2.instArray) {
        BDLM_Instruction *instDiff = [diff getInstructionWithAddrV2:instObjV2.addr];
        if (instDiff == nil) {
            UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Added Diff:nil exportV1:nil exportV2:instObjV2];
            udfInst.backRef = self;
            [self.instArray addObject:udfInst];
            [udfInst release];
            udfInst = nil;
        }
    }
}

- (void)processWithDiff:(BDLM_BasicBlock *)diff
               exportV1:(BELM_BasicBlock *)exportV1
               exportV2:(BELM_BasicBlock *)exportV2
{
    // basic block: deleted
    if (self.actionType == UDF_ActionType_Deleted) {
        for (BELM_Instruction *instObjV1 in exportV1.instArray) {
            UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Deleted Diff:nil exportV1:instObjV1 exportV2:nil];
            udfInst.backRef = self;
            [self.instArray addObject:udfInst];
            [udfInst release];
            udfInst = nil;
        }
    }
    // basic block: added
    else if (self.actionType == UDF_ActionType_Added) {
        for (BELM_Instruction *instObjV2 in exportV2.instArray) {
            UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Added Diff:nil exportV1:nil exportV2:instObjV2];
            udfInst.backRef = self;
            [self.instArray addObject:udfInst];
            [udfInst release];
            udfInst = nil;
        }
    }
    // basic block: identical
    else if (self.actionType == UDF_ActionType_Identical) {
        if (exportV1.instArray.count != exportV2.instArray.count) {
            printf("[-] %s: instruction count not equal\n", __FUNCTION__);
            return;
        }
        
        for (int idx = 0; idx < exportV1.instArray.count; ++idx) {
            BELM_Instruction *instObjV1 = exportV1.instArray[idx];
            BELM_Instruction *instObjV2 = exportV2.instArray[idx];
            if ([instObjV1 isEqual:instObjV2] == NO) {
                printf("[-] %s: instruction not equal, addr1: 0x%llx, addr2: 0x%llx\n", __FUNCTION__, instObjV1.addr, instObjV2.addr);
                continue;
            }
            
            UDF_Instruction *udfInst = [[UDF_Instruction alloc] initWithType:UDF_ActionType_Identical Diff:nil exportV1:instObjV1 exportV2:instObjV2];
            udfInst.backRef = self;
            [self.instArray addObject:udfInst];
            [udfInst release];
            udfInst = nil;
        }
    }
    // basic block: changed
    else if (self.actionType == UDF_ActionType_Changed) {
        [self processBasicBlockChangedWithDiff:diff exportV1:exportV1 exportV2:exportV2];
    }
    else {
        printf("[-] %s: invalid action type: %d\n", __FUNCTION__, self.actionType);
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    UDF_BasicBlock *obj2 = (UDF_BasicBlock *)object;
    if (self.diff && obj2.diff) {
        return (self.diff == obj2.diff);
    }
    else {
        return NO;
    }
}

/*
 If:
    a < b   then return NSOrderedAscending. The left operand is smaller than the right operand.
    a > b   then return NSOrderedDescending. The left operand is greater than the right operand.
    a == b  then return NSOrderedSame. The operands are equal.
*/

- (NSComparisonResult)compareByAddrV1:(UDF_BasicBlock *)another
{
    if (self.exportV1.addr < another.exportV1.addr) {
        return NSOrderedAscending;
    }
    else if (self.exportV1.addr > another.exportV1.addr) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByAddrV2:(UDF_BasicBlock *)another
{
    if (self.exportV2.addr < another.exportV2.addr) {
        return NSOrderedAscending;
    }
    else if (self.exportV2.addr > another.exportV2.addr) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByAddrAndDeltaV1V2:(UDF_BasicBlock *)another
{
    if (self.exportV1 && another.exportV1) {
        return [self compareByAddrV1:another];
    }
    else if (self.exportV2 && another.exportV2) {
        return [self compareByAddrV2:another];
    }
    else if ((self.exportV1 && (self.exportV2 == nil)) && ((another.exportV1 == nil) && another.exportV2)) {
        if (self.exportV1.deltaAddr < another.exportV2.deltaAddr) {
            return NSOrderedAscending;
        }
        else if (self.exportV1.deltaAddr > another.exportV2.deltaAddr) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }
    else {
        printf("[-] %s: situation out of control\n", __FUNCTION__);
        return NSOrderedSame;
    }
}

- (NSArray<UDF_Instruction *> *)filterInstructions:(NSArray<UDF_Instruction *> *)instArray withActionType:(UDF_ActionType)actionType
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_Instruction *udfInst in instArray) {
        if (udfInst.actionType & actionType) {
            [retArray addObject:udfInst];
        }
    }
    
    return retArray;
}

- (NSArray<UDF_Instruction *> *)getInstruction_All
{
    return self.instArray;
}

- (NSArray<UDF_Instruction *> *)getInstruction_Deleted
{
    return [self filterInstructions:self.instArray withActionType:UDF_ActionType_Deleted];
}

- (NSArray<UDF_Instruction *> *)getInstruction_Added
{
    return [self filterInstructions:self.instArray withActionType:UDF_ActionType_Added];
}

- (NSArray<UDF_Instruction *> *)getInstruction_Changed
{
    return [self filterInstructions:self.instArray withActionType:UDF_ActionType_Changed];
}

- (NSArray<UDF_Instruction *> *)getInstruction_Identical
{
    return [self filterInstructions:self.instArray withActionType:UDF_ActionType_Identical];
}

- (NSArray<UDF_Instruction *> *)getInstruction_Changed_Deleted
{
    return [self filterInstructions:self.instArray
                     withActionType:UDF_ActionType_Changed | UDF_ActionType_Deleted];
}

- (NSArray<UDF_Instruction *> *)getInstruction_WithoutIdentical
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_Instruction *udfInst in self.instArray) {
        if ((udfInst.actionType & UDF_ActionType_Identical) == 0) {
            [retArray addObject:udfInst];
        }
    }
    
    return retArray;
}

- (NSArray<UDF_Instruction *> *)getInstruction_WithoutAdded
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_Instruction *udfInst in self.instArray) {
        if ((udfInst.actionType & UDF_ActionType_Added) == 0) {
            [retArray addObject:udfInst];
        }
    }
    
    return retArray;
}

- (NSArray *)getObjectsFrom:(NSArray *)inputArray addrLessThan:(uint64_t)baseAddr
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_Instruction *instObj in inputArray) {
        if (instObj.exportV2.addr < baseAddr) {
            [retArray addObject:instObj];
        }
    }
    
    return retArray;
}

- (NSArray<UDF_Instruction *> *)insertAddedArray:(NSArray *)addedArray toArray:(NSArray *)toArray
{
    NSMutableArray<UDF_Instruction *> *retArray = [NSMutableArray array];
    
    //added = [added sortedArrayUsingSelector:@selector(compareByAddrV2:)];
    NSMutableArray *mutableAdded = [addedArray mutableCopy];
    
    for (UDF_Instruction *objAllButAdded in toArray) {
        if (objAllButAdded.actionType & (UDF_ActionType_Changed | UDF_ActionType_Identical)) {
            NSArray *toInsert = [self getObjectsFrom:mutableAdded
                                        addrLessThan:objAllButAdded.exportV2.addr];
            
            for (UDF_Instruction *objToInsert in toInsert) {
                [retArray addObject:objToInsert];
                [mutableAdded removeObject:objToInsert];
            }
        }
        [retArray addObject:objAllButAdded];
    }
    
    for (UDF_Instruction *objToInsert in mutableAdded) {
        [retArray addObject:objToInsert];
    }
    
    [mutableAdded release];
    mutableAdded = nil;
    
    return retArray;
}

- (NSArray<UDF_Instruction *> *)getInstruction_All_Sorted
{
    NSArray *toArray = [self getInstruction_WithoutAdded];
    NSArray *added = [self getInstruction_Added];
    
    return [self insertAddedArray:added toArray:toArray];
}

- (NSArray<UDF_Instruction *> *)getInstruction_Changed_Deleted_Sorted
{
    NSArray *toArray = [self getInstruction_Changed_Deleted];
    NSArray *added = [self getInstruction_Added];
    
    return [self insertAddedArray:added toArray:toArray];
}

- (NSArray<UDF_Instruction *> *)getInstructionWithActionTypeSorted:(UDF_ActionType)actionType
{
    UDF_ActionType atWithoutAdded = actionType & (~UDF_ActionType_Added);
    NSArray *toArray = [self filterInstructions:self.instArray withActionType:atWithoutAdded];
    
    if (actionType & UDF_ActionType_Added) {
        NSArray *added = [self getInstruction_Added];
        return [self insertAddedArray:added toArray:toArray];
    }
    else {
        return toArray;
    }
}

- (UDF_ActionType)getActionType
{
    return self.actionType;
}

- (uint64_t)getAddr:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.addr;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.addr;
    }
    else {
        return -1;
    }
}

- (NSArray *)getCallTargetAddrs:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.callTargetAddrArray;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.callTargetAddrArray;
    }
    else {
        return nil;
    }
}

- (NSArray *)getCallTargetNames:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.callTargetNameArray;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.callTargetNameArray;
    }
    else {
        return nil;
    }
}

- (void)removeInstruction:(UDF_Instruction *)instObj
{
    [self.instArray removeObject:instObj];
    
    if (([self getInstruction_Deleted].count == 0) &&
        ([self getInstruction_Added].count == 0)) {
        //printf("%s: remove block\n", __FUNCTION__);
        [self.backRef removeBlock:self];
    }
}

- (void)removeInstructions:(NSArray *)instArray
{
    for (UDF_Instruction *instObj in instArray) {
        [self.instArray removeObject:instObj];
    }
    
    if (([self getInstruction_Deleted].count == 0) &&
        ([self getInstruction_Added].count == 0)) {
        //printf("%s: remove block\n", __FUNCTION__);
        [self.backRef removeBlock:self];
    }
}

- (BOOL)isAllActionType:(UDF_ActionType)actionType
{
    for (UDF_Instruction *instObj in self.instArray) {
        if ((instObj.actionType & actionType) == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)manualSetActionType:(UDF_ActionType)actionType;
{
    self.actionType = actionType | UDF_ActionType_ManualSet;
}

- (BOOL)isDeletedStrictEqualToAdded:(UDF_BasicBlock *)bbAdded;
{
    if (self.instArray.count != bbAdded.instArray.count) {
        return NO;
    }
    
    for (int idx = 0; idx < self.instArray.count; ++idx) {
        UDF_Instruction *instSelf = self.instArray[idx];
        UDF_Instruction *instAdded = bbAdded.instArray[idx];
        
        if (![instSelf isDeletedStrictEqualToAdded:instAdded]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)hasData:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_Diff) {
        return (self.diff != nil);
    }
    else if (dataSel == UDF_DataSelector_V1) {
        return (self.exportV1 != nil);
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return (self.exportV2 != nil);
    }
    else {
        return NO;
    }
}

@end
