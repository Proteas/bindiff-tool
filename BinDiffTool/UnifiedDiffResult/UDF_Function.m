//
//  UDF_Function.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import "UDF_Function.h"
#import "BDLM_Function.h"
#import "BELM_Function.h"
#import "BDLM_BasicBlock.h"
#import "BELM_BasicBlock.h"
#import "UDF_BasicBlock.h"
#import "BinDiff_DB.h"
#import "BinDiff_Helper.h"
#import "UDF_Module.h"

@interface UDF_Function ()
{
    NSMutableArray<UDF_BasicBlock *> *_bbArray;
    double _scoreMagic;
}

@property(nonatomic, retain) NSMutableArray<UDF_BasicBlock *> *bbArray;

- (void)processWithDiff:(BDLM_Function *)diff
               exportV1:(BELM_Function *)exportV1
               exportV2:(BELM_Function *)exportV2;

- (void)processFuncChangedWithDiff:(BDLM_Function *)diff
                          exportV1:(BELM_Function *)exportV1
                          exportV2:(BELM_Function *)exportV2;

- (NSArray<UDF_BasicBlock *> *)filterBasicBlocks:(NSArray<UDF_BasicBlock *> *)bbArray withActionType:(UDF_ActionType)actionType;

@end

@implementation UDF_Function

@synthesize actionType = _actionType;
@synthesize diff = _diff;
@synthesize exportV1 = _exportV1;
@synthesize exportV2 = _exportV2;
@synthesize bbArray = _bbArray;
@synthesize backRef = _backRef;

- (instancetype)initWithType:(UDF_ActionType)actionType
                        Diff:(BDLM_Function *)diff
                    exportV1:(BELM_Function *)exportV1
                    exportV2:(BELM_Function *)exportV2
{
    if ((self = [super init])) {
        self.actionType = actionType;
        _bbArray = [[NSMutableArray alloc] init];
        
        _diff = [diff retain];
        _exportV1 = [exportV1 retain];
        _exportV2 = [exportV2 retain];
        
        _scoreMagic = 2.33f;
        
        [self processWithDiff:diff exportV1:exportV1 exportV2:exportV2];
    }
    
    return self;
}

- (void)dealloc
{
    self.bbArray = nil;
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

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    UDF_Function *obj2 = (UDF_Function *)object;
    if (self.diff && obj2.diff) {
        return (self.diff == obj2.diff);
    }
    else {
        return NO;
    }
}

- (NSComparisonResult)compareByAddrV1:(UDF_Function *)another
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

- (NSComparisonResult)compareByAddrV2:(UDF_Function *)another
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

- (NSComparisonResult)compareByBlockCountV1:(UDF_Function *)another
{
    if (self.exportV1.bbArray.count < another.exportV1.bbArray.count) {
        return NSOrderedAscending;
    }
    else if (self.exportV1.bbArray.count > another.exportV1.bbArray.count) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByBlockCountV2:(UDF_Function *)another
{
    if (self.exportV2.bbArray.count < another.exportV2.bbArray.count) {
        return NSOrderedAscending;
    }
    else if (self.exportV2.bbArray.count > another.exportV2.bbArray.count) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByEdgeCountV1:(UDF_Function *)another
{
    if (self.exportV1.edgeArray.count < another.exportV1.edgeArray.count) {
        return NSOrderedAscending;
    }
    else if (self.exportV1.edgeArray.count > another.exportV1.edgeArray.count) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByEdgeCountV2:(UDF_Function *)another
{
    if (self.exportV2.edgeArray.count < another.exportV2.edgeArray.count) {
        return NSOrderedAscending;
    }
    else if (self.exportV2.edgeArray.count > another.exportV2.edgeArray.count) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByInstCountV1:(UDF_Function *)another
{
    NSUInteger instCountSelf = [self.exportV1 getInstructionCount];
    NSUInteger instCountAnother = [another.exportV1 getInstructionCount];
    
    if (instCountSelf < instCountAnother) {
        return NSOrderedAscending;
    }
    else if (instCountSelf > instCountAnother) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByInstCountV2:(UDF_Function *)another
{
    NSUInteger instCountSelf = [self.exportV2 getInstructionCount];
    NSUInteger instCountAnother = [another.exportV2 getInstructionCount];
    
    if (instCountSelf < instCountAnother) {
        return NSOrderedAscending;
    }
    else if (instCountSelf > instCountAnother) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByBlockEdgeCountV1:(UDF_Function *)another
{
    NSComparisonResult cmpResult = [self compareByBlockCountV1:another];
    if (cmpResult == NSOrderedSame) {
        cmpResult = [self compareByEdgeCountV1:another];
    }
    
    return cmpResult;
}

- (NSComparisonResult)compareByBlockEdgeCountV2:(UDF_Function *)another
{
    NSComparisonResult cmpResult = [self compareByBlockCountV2:another];
    if (cmpResult == NSOrderedSame) {
        cmpResult = [self compareByEdgeCountV2:another];
    }
    
    return cmpResult;
}

- (NSComparisonResult)compareByInstructionBlockEdgeCountV1:(UDF_Function *)another
{
    NSComparisonResult cmpResult = [self compareByInstCountV1:another];
    if (cmpResult == NSOrderedSame) {
        cmpResult = [self compareByBlockEdgeCountV1:another];
    }
    
    return cmpResult;
}

- (NSComparisonResult)compareByInstructionBlockEdgeCountV2:(UDF_Function *)another
{
    NSComparisonResult cmpResult = [self compareByInstCountV2:another];
    if (cmpResult == NSOrderedSame) {
        cmpResult = [self compareByBlockEdgeCountV2:another];
    }
    
    return cmpResult;
}

- (double)getWeaknessScoreV1
{
    double wkScore = (double)[self.exportV1 getInstructionCount] / (self.exportV1.bbArray.count + self.exportV1.edgeArray.count);
    return wkScore * _scoreMagic;
}

- (double)getWeaknessScoreV2
{
    double wkScore = (double)[self.exportV2 getInstructionCount] / (self.exportV2.bbArray.count + self.exportV2.edgeArray.count);
    return wkScore * _scoreMagic;
}

- (NSComparisonResult)compareByWeaknessScoreV1:(UDF_Function *)another
{
    double wkScoreSelf = [self getWeaknessScoreV1];
    double wkScoreAnother = [another getWeaknessScoreV1];
    
    if (wkScoreSelf < wkScoreAnother) {
        return NSOrderedAscending;
    }
    else if (wkScoreSelf > wkScoreAnother) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByWeaknessScoreV2:(UDF_Function *)another
{
    double wkScoreSelf = [self getWeaknessScoreV2];
    double wkScoreAnother = [another getWeaknessScoreV2];
    
    if (wkScoreSelf < wkScoreAnother) {
        return NSOrderedAscending;
    }
    else if (wkScoreSelf > wkScoreAnother) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (void)processFuncChangedWithDiff:(BDLM_Function *)diff
                          exportV1:(BELM_Function *)exportV1
                          exportV2:(BELM_Function *)exportV2
{
    for (BELM_BasicBlock *bbObjV1 in exportV1.bbArray) {
        BDLM_BasicBlock *bbDiff = [diff getBasicBlockWithAddrV1:bbObjV1.addr];
        if (bbDiff == nil) {
            UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Deleted Diff:nil exportV1:bbObjV1 exportV2:nil];
            //printf("[+] function changed, basic block deleted: 0x%llx\n", bbObjV1.addr);
            udfBlock.backRef = self;
            [self.bbArray addObject:udfBlock];
            [udfBlock release];
            udfBlock = nil;
        }
        else {
            BELM_BasicBlock *bbObjV2 = [exportV2 getBasicBlockWithAddr:bbDiff.refBasicBlock.address2];
            if (bbObjV2 == nil) {
                printf("[-] %s: can't find bb in export 2, addr1: 0x%llX, addr2: 0x%llX, func addr1: 0x%llX, func addr2: 0x%llX\n", __FUNCTION__, bbDiff.refBasicBlock.address1, bbDiff.refBasicBlock.address2, self.diff.refFunc.address1, self.diff.refFunc.address2);
                continue;
            }
            
            if ([bbObjV1 isEqual:bbObjV2] == YES) {
                //printf("[-] %s: has basic block diff, but basic blocks are equal\n", __FUNCTION__);
                UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Identical Diff:bbDiff exportV1:bbObjV1 exportV2:bbObjV2];
                udfBlock.backRef = self;
                [self.bbArray addObject:udfBlock];
                [udfBlock release];
                udfBlock = nil;
            }
            else {
                UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Changed Diff:bbDiff exportV1:bbObjV1 exportV2:bbObjV2];
                udfBlock.backRef = self;
                [self.bbArray addObject:udfBlock];
                [udfBlock release];
                udfBlock = nil;
            }
        }
    }
    
    for (BELM_BasicBlock *bbObjV2 in exportV2.bbArray) {
        BDLM_BasicBlock *bbDiff = [diff getBasicBlockWithAddrV2:bbObjV2.addr];
        if (bbDiff == nil) {
            UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Added Diff:nil exportV1:nil exportV2:bbObjV2];
            udfBlock.backRef = self;
            [self.bbArray addObject:udfBlock];
            [udfBlock release];
            udfBlock = nil;
        }
    }
}

- (void)processWithDiff:(BDLM_Function *)diff
               exportV1:(BELM_Function *)exportV1
               exportV2:(BELM_Function *)exportV2
{
    // function: deleted
    if (self.actionType == UDF_ActionType_Deleted) {
        for (BELM_BasicBlock *bbObjV1 in exportV1.bbArray) {
            UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Deleted Diff:nil exportV1:bbObjV1 exportV2:nil];
            udfBlock.backRef = self;
            [self.bbArray addObject:udfBlock];
            [udfBlock release];
            udfBlock = nil;
        }
    }
    // function: added
    else if (self.actionType == UDF_ActionType_Added) {
        for (BELM_BasicBlock *bbObjV2 in exportV2.bbArray) {
            UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Added Diff:nil exportV1:nil exportV2:bbObjV2];
            udfBlock.backRef = self;
            [self.bbArray addObject:udfBlock];
            [udfBlock release];
            udfBlock = nil;
        }
    }
    // function: identical
    else if (self.actionType == UDF_ActionType_Identical) {
        if (exportV1.bbArray.count != exportV2.bbArray.count) {
            printf("[-] %s: basic block count not equal\n", __FUNCTION__);
            return;
        }
        
        for (int idx = 0; idx < exportV1.bbArray.count; ++idx) {
            BELM_BasicBlock *bbObjV1 = exportV1.bbArray[idx];
            BELM_BasicBlock *bbObjV2 = exportV2.bbArray[idx];
            if ([bbObjV1 isEqual:bbObjV2] == NO) {
                printf("[-] %s: basic block not equal, addr1: 0x%llX, addr2: 0x%llX\n", __FUNCTION__, bbObjV1.addr, bbObjV2.addr);
                continue;
            }
            
            UDF_BasicBlock *udfBlock = [[UDF_BasicBlock alloc] initWithType:UDF_ActionType_Identical Diff:nil exportV1:bbObjV1 exportV2:bbObjV2];
            udfBlock.backRef = self;
            [self.bbArray addObject:udfBlock];
            [udfBlock release];
            udfBlock = nil;
        }
    }
    // function: changed
    else if (self.actionType == UDF_ActionType_Changed) {
        [self processFuncChangedWithDiff:diff exportV1:exportV1 exportV2:exportV2];
    }
    else {
        printf("[-] %s: invalid action type: %d\n", __FUNCTION__, self.actionType);
    }
}

- (NSArray<UDF_BasicBlock *> *)filterBasicBlocks:(NSArray<UDF_BasicBlock *> *)bbArray withActionType:(UDF_ActionType)actionType
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_BasicBlock *udfBB in bbArray) {
        if (udfBB.actionType & actionType) {
            [retArray addObject:udfBB];
        }
    }
    
    return retArray;
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_All
{
    return self.bbArray;
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Deleted
{
    return [self filterBasicBlocks:self.bbArray withActionType:UDF_ActionType_Deleted];
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Added
{
    return [self filterBasicBlocks:self.bbArray withActionType:UDF_ActionType_Added];
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Changed
{
    return [self filterBasicBlocks:self.bbArray withActionType:UDF_ActionType_Changed];
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Identical
{
    return [self filterBasicBlocks:self.bbArray withActionType:UDF_ActionType_Identical];
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_Changed_Deleted
{
    return [self filterBasicBlocks:self.bbArray
                    withActionType:UDF_ActionType_Deleted | UDF_ActionType_Changed];
}

- (NSArray<UDF_BasicBlock *> *)getBasicBlock_WithoutIdentical
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (UDF_BasicBlock *udfBB in self.bbArray) {
        if ((udfBB.actionType & UDF_ActionType_Identical) == 0) {
            [retArray addObject:udfBB];
        }
    }
    
    return retArray;
}

- (uint32_t)getFuncDiffFlags
{
    if (self.actionType != UDF_ActionType_Changed) {
        return -1;
    }
    
    return _diff.refFunc.flags;
}

- (NSString *)getFuncDiffFlagsStr
{
    if (self.actionType != UDF_ActionType_Changed) {
        return BDH_FuncDiffFlagsNone();
    }
    
    return BDH_FuncDiffFlagsToStr(_diff.refFunc.flags);
}

- (UDF_ActionType)getActionType
{
    return self.actionType;
}

- (NSString *)getName:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return [self.exportV1 getName];
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return [self.exportV2 getName];
    }
    else {
        return nil;
    }
}

- (int32_t)getBELMFuncType:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.type;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.type;
    }
    else {
        return -1;
    }
}

- (int32_t)getBlockCount:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return (int32_t)self.exportV1.bbArray.count;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return (int32_t)self.exportV2.bbArray.count;
    }
    else {
        return 0;
    }
}

- (int32_t)getEdgeCount:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return (int32_t)self.exportV1.edgeArray.count;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return (int32_t)self.exportV2.edgeArray.count;
    }
    else {
        return 0;
    }
}

- (NSArray<BELM_Edge *> *)getEdges:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.edgeArray;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.edgeArray;
    }
    else {
        return nil;
    }
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

- (void)removeBlock:(UDF_BasicBlock *)bbObj
{
    [self.bbArray removeObject:bbObj];
    
    if (([self getBasicBlock_Deleted].count == 0) &&
        ([self getBasicBlock_Added].count == 0) &&
        ([self getBasicBlock_Changed].count == 0)) {
        //printf("%s: remove function\n", __FUNCTION__);
        [self.backRef removeFunction: self];
    }
}

- (void)removeBlocks:(NSArray *)bbArray
{
    for (UDF_BasicBlock *bbObj in bbArray) {
        [self.bbArray removeObject:bbObj];
    }
    
    if (([self getBasicBlock_Deleted].count == 0) &&
        ([self getBasicBlock_Added].count == 0) &&
        ([self getBasicBlock_Changed].count == 0)) {
        //printf("%s: remove function\n", __FUNCTION__);
        [self.backRef removeFunction: self];
    }
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

- (void)manualSetActionType:(UDF_ActionType)actionType
{
    self.actionType = actionType | UDF_ActionType_ManualSet;
}

- (NSNumber *)getSimilarity
{
    if (self.actionType == UDF_ActionType_Changed) {
        return [NSNumber numberWithDouble:self.diff.refFunc.similarity];
    }
    
    return nil;
}

- (NSNumber *)getConfidence
{
    if (self.actionType == UDF_ActionType_Changed) {
        return [NSNumber numberWithDouble:self.diff.refFunc.confidence];
    }
    
    return nil;
}

@end
