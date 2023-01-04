//
//  BDLM_BasicBlock.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import "BDLM_BasicBlock.h"
#import "BinDiff_DB.h"
#import "BDLM_Instruction.h"

@interface BDLM_BasicBlock ()
{
    NSMutableArray<BDLM_Instruction *> *_instArray;
    NSMutableDictionary<NSNumber *, BDLM_Instruction *> *_addrToInstMapV1;
    NSMutableDictionary<NSNumber *, BDLM_Instruction *> *_addrToInstMapV2;
}

@property(nonatomic, retain) NSMutableDictionary *addrToInstMapV1;
@property(nonatomic, retain) NSMutableDictionary *addrToInstMapV2;

- (void)addInstructionsFromDB:(BinDiff_DB *)db;
- (BOOL)isAddrInMap:(NSMutableDictionary *)addrToInstMap addr:(uint64_t)addr;
- (void)buildAddrMapV1;
- (void)buildAddrMapV2;
- (void)addAlgo:(BinDiff_DB *)db basicBlock:(BinDiff_DB_BasicBlock *)basicBlock;

- (BDLM_Instruction *)getInstructionInMap:(NSMutableDictionary *)addrToInstMap addr:(uint64_t)addr;

@end

@implementation BDLM_BasicBlock

@synthesize refBasicBlock = _refBasicBlock;
@synthesize instArray = _instArray;
@synthesize addrToInstMapV1 = _addrToInstMapV1;
@synthesize addrToInstMapV2 = _addrToInstMapV2;

- (instancetype)initWithDB:(BinDiff_DB *)db basicBlock:(BinDiff_DB_BasicBlock *)basicBlock
{
    if ((self = [super init])) {
        _refBasicBlock = [basicBlock retain];
        
        _instArray = [[NSMutableArray alloc] init];
        _addrToInstMapV1 = [[NSMutableDictionary alloc] init];
        _addrToInstMapV2 = [[NSMutableDictionary alloc] init];
        
        [self addInstructionsFromDB:db];
        [self buildAddrMapV1];
        [self buildAddrMapV2];
        [self addAlgo:db basicBlock:basicBlock];
    }
    
    return self;
}

- (void)dealloc
{
    self.instArray = nil;
    self.addrToInstMapV1 = nil;
    self.addrToInstMapV2 = nil;
    
    if (_refBasicBlock) {
        [_refBasicBlock release];
        _refBasicBlock = nil;
    }
    
    if (_algorithm) {
        [_algorithm release];
        _algorithm = nil;
    }
    
    [super dealloc];
}

- (void)addInstructionsFromDB:(BinDiff_DB *)db
{
    @autoreleasepool {
        NSArray<BinDiff_DB_Instruction *> *dbInstArray = [db getInstructionsWithBasicBlockID2:_refBasicBlock.ID];
        
        for (BinDiff_DB_Instruction *dbInstObj in dbInstArray) {
            BDLM_Instruction *localInstObj = [[BDLM_Instruction alloc] initWithDB:db instruction:dbInstObj];
            
            if (localInstObj) {
                [self.instArray addObject:localInstObj];
            }
            else {
                printf("[-] %s: fail to convert instruction object\n", __FUNCTION__);
            }
            
            [localInstObj release];
            localInstObj = nil;
        }
    }
}

- (void)buildAddrMapV1
{
    for (BDLM_Instruction *instObj in _instArray) {
        uint64_t addr = instObj.refInst.address1;
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
        [_addrToInstMapV1 setObject:instObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (void)buildAddrMapV2
{
    for (BDLM_Instruction *instObj in _instArray) {
        uint64_t addr = instObj.refInst.address2;
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
        [_addrToInstMapV2 setObject:instObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (void)addAlgo:(BinDiff_DB *)db basicBlock:(BinDiff_DB_BasicBlock *)basicBlock
{
    for (BinDiff_DB_BasicBlockAlgo *algo in db.bbAlgoArray) {
        if (algo.ID == basicBlock.algorithm) {
            _algorithm = [algo.name retain];
        }
    }
}

- (BDLM_Instruction *)getInstructionInMap:(NSMutableDictionary *)addrToInstMap addr:(uint64_t)addr
{
    NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
    
    BDLM_Instruction *obj = [addrToInstMap objectForKey:addrObj];
    
    [addrObj release];
    addrObj = nil;
    
    return obj;
}

- (BOOL)isAddrInMap:(NSMutableDictionary *)addrToInstMap addr:(uint64_t)addr
{
    BDLM_Instruction *obj = [self getInstructionInMap:addrToInstMap addr:addr];
    
    return (obj != nil);
}

- (BDLM_Instruction *)getInstructionWithAddrV1:(uint64_t)addr
{
    return [self getInstructionInMap:_addrToInstMapV1 addr:addr];
}

- (BDLM_Instruction *)getInstructionWithAddrV2:(uint64_t)addr
{
    return [self getInstructionInMap:_addrToInstMapV2 addr:addr];
}

- (BOOL)isInstAddrInV1:(uint64_t)addr
{
    return [self isAddrInMap:_addrToInstMapV1 addr:addr];
}

- (BOOL)isInstAddrInV2:(uint64_t)addr
{
    return [self isAddrInMap:_addrToInstMapV2 addr:addr];
}

@end
