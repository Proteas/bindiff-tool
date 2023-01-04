//
//  BDLM_Function.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import "BDLM_Function.h"
#import "BinDiff_DB.h"
#import "BDLM_BasicBlock.h"

@interface BDLM_Function ()
{
    NSMutableArray<BDLM_BasicBlock *> *_basicBlockArray;
    NSMutableDictionary<NSNumber *, BDLM_BasicBlock *> *_addrToBasicBlockMapV1;
    NSMutableDictionary<NSNumber *, BDLM_BasicBlock *> *_addrToBasicBlockMapV2;
}

@property(nonatomic, retain) NSMutableDictionary *addrToBasicBlockMapV1;
@property(nonatomic, retain) NSMutableDictionary *addrToBasicBlockMapV2;

- (BDLM_BasicBlock *)getBasicBlockInMap:(NSMutableDictionary *)addrToBBMap addr:(uint64_t)addr;
- (BOOL)isAddrInMap:(NSMutableDictionary *)addrToBBMap addr:(uint64_t)addr;

- (void)addBasicBlocksFromDB:(BinDiff_DB *)db;
- (void)buildAddrMapV1;
- (void)buildAddrMapV2;
- (void)addAlgo:(BinDiff_DB *)db function:(BinDiff_DB_Function *)function;

@end

@implementation BDLM_Function

@synthesize refFunc = _refFunc;
@synthesize basicBlockArray = _basicBlockArray;
@synthesize addrToBasicBlockMapV1 = _addrToBasicBlockMapV1;
@synthesize addrToBasicBlockMapV2 = _addrToBasicBlockMapV2;
@synthesize algorithm = _algorithm;

- (instancetype)initWithDB:(BinDiff_DB *)db function:(BinDiff_DB_Function *)function
{
    if ((self = [super init])) {
        _refFunc = [function retain];
        
        _basicBlockArray = [[NSMutableArray alloc] init];
        _addrToBasicBlockMapV1 = [[NSMutableDictionary alloc] init];
        _addrToBasicBlockMapV2 = [[NSMutableDictionary alloc] init];
        
        [self addBasicBlocksFromDB:db];
        [self buildAddrMapV1];
        [self buildAddrMapV2];
        [self addAlgo:db function:function];
    }
    
    return self;
}

- (void)dealloc
{
    self.basicBlockArray = nil;
    self.addrToBasicBlockMapV1 = nil;
    self.addrToBasicBlockMapV2 = nil;
    
    if (_refFunc) {
        [_refFunc release];
        _refFunc = nil;
    }
    
    if (_algorithm) {
        [_algorithm release];
        _algorithm = nil;
    }
    
    [super dealloc];
}

- (void)addAlgo:(BinDiff_DB *)db function:(BinDiff_DB_Function *)function
{
    for (BinDiff_DB_FunctionAlgo *algo in db.funcAlgoArray) {
        if (algo.ID == function.algorithm) {
            _algorithm = [algo.name retain];
        }
    }
}

- (void)addBasicBlocksFromDB:(BinDiff_DB *)db
{
    @autoreleasepool {
        NSArray<BinDiff_DB_BasicBlock *> *dbBBArray = [db getBasicBlocksWithFunctionID2:_refFunc.ID];
        
        for (BinDiff_DB_BasicBlock *dbBBObj in dbBBArray) {
            BDLM_BasicBlock *localBBObj = [[BDLM_BasicBlock alloc] initWithDB:db basicBlock:dbBBObj];
            
            if (localBBObj) {
                [self.basicBlockArray addObject:localBBObj];
            }
            else {
                printf("[-] %s: fail to convert basic block object\n", __FUNCTION__);
            }
            
            [localBBObj release];
            localBBObj = nil;
        }
    }
}

- (void)buildAddrMapV1
{
    for (BDLM_BasicBlock *bbObj in _basicBlockArray) {
        uint64_t addr = bbObj.refBasicBlock.address1;
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
        [_addrToBasicBlockMapV1 setObject:bbObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (void)buildAddrMapV2
{
    for (BDLM_BasicBlock *bbObj in _basicBlockArray) {
        uint64_t addr = bbObj.refBasicBlock.address2;
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
        [_addrToBasicBlockMapV2 setObject:bbObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (BDLM_BasicBlock *)getBasicBlockInMap:(NSMutableDictionary *)addrToBBMap addr:(uint64_t)addr
{
    NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
    
    BDLM_BasicBlock *obj = [addrToBBMap objectForKey:addrObj];
    
    [addrObj release];
    addrObj = nil;
    
    return obj;
}

- (BOOL)isAddrInMap:(NSMutableDictionary *)addrToBBMap addr:(uint64_t)addr
{
    BDLM_BasicBlock *obj = [self getBasicBlockInMap:addrToBBMap addr:addr];
    
    return (obj != nil);
}

- (BOOL)isBasicBlockAddrInV1:(uint64_t)addr
{
    return [self isAddrInMap:_addrToBasicBlockMapV1 addr:addr];
}

- (BOOL)isBasicBlockAddrInV2:(uint64_t)addr
{
    return [self isAddrInMap:_addrToBasicBlockMapV2 addr:addr];
}

- (BDLM_BasicBlock *)getBasicBlockWithAddrV1:(uint64_t)addr
{
    return [self getBasicBlockInMap:_addrToBasicBlockMapV1 addr:addr];
}

- (BDLM_BasicBlock *)getBasicBlockWithAddrV2:(uint64_t)addr
{
    return [self getBasicBlockInMap:_addrToBasicBlockMapV2 addr:addr];
}

@end
