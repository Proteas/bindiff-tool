//
//  BDLM_Module.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import "BDLM_Module.h"
#import "BinDiff_DB.h"
#import "BDLM_Function.h"

@interface BDLM_Module ()
{
    NSMutableArray<BDLM_Function *> *_funcArray;
    NSMutableDictionary<NSNumber *, BDLM_Function *> *_addrToFuncMapV1;
    NSMutableDictionary<NSNumber *, BDLM_Function *> *_addrToFuncMapV2;
}

@property(nonatomic, retain) NSMutableDictionary *addrToFuncMapV1;
@property(nonatomic, retain) NSMutableDictionary *addrToFuncMapV2;

- (BOOL)isAddrInMap:(NSMutableDictionary *)addrToFuncMap addr:(uint64_t)addr;
- (BDLM_Function *)getFuncInMap:(NSMutableDictionary *)addrToFuncMap addr:(uint64_t)addr;
- (void)addFunctionsFromDB:(BinDiff_DB *)db;
- (void)buildAddrMapV1;
- (void)buildAddrMapV2;

@end

@implementation BDLM_Module

@synthesize funcArray = _funcArray;
@synthesize fileInfo = _fileInfo;
@synthesize metaInfo = _metaInfo;

- (instancetype)initWithDB:(BinDiff_DB *)db
{
    if ((self = [super init])) {
        _funcArray = [[NSMutableArray alloc] init];
        _addrToFuncMapV1 = [[NSMutableDictionary alloc] init];
        _addrToFuncMapV2 = [[NSMutableDictionary alloc] init];
        
        [self addFunctionsFromDB:db];
        [self buildAddrMapV1];
        [self buildAddrMapV2];
    }
    
    return self;
}

- (void)dealloc
{
    self.funcArray = nil;
    self.addrToFuncMapV1 = nil;
    self.addrToFuncMapV2 = nil;
    
    if (_fileInfo) {
        [_fileInfo release];
        _fileInfo = nil;
    }
    
    if (_metaInfo) {
        [_metaInfo release];
        _metaInfo = nil;
    }
    
    [super dealloc];
}

- (void)addFunctionsFromDB:(BinDiff_DB *)db
{
    int idx = 0;
    for (BinDiff_DB_Function *dbFuncObj in db.funcArray) {
        ++idx;
        BDLM_Function *localFuncObj = [[BDLM_Function alloc] initWithDB:db function:dbFuncObj];
        
        if (localFuncObj) {
            [self.funcArray addObject:localFuncObj];
        }
        else {
            printf("[-] %s: fail to create local function object\n", __FUNCTION__);
        }
        
        [localFuncObj release];
        localFuncObj = nil;
    }
}

- (void)buildAddrMapV1
{
    for (BDLM_Function *funcObj in _funcArray) {
        uint64_t addr = funcObj.refFunc.address1;
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
        [_addrToFuncMapV1 setObject:funcObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (void)buildAddrMapV2
{
    for (BDLM_Function *funcObj in _funcArray) {
        uint64_t addr = funcObj.refFunc.address2;
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
        [_addrToFuncMapV2 setObject:funcObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (BOOL)isAddrInMap:(NSMutableDictionary *)addrToFuncMap addr:(uint64_t)addr
{
    BDLM_Function *obj = [self getFuncInMap:addrToFuncMap addr:addr];
    
    return (obj != nil);
}

- (BDLM_Function *)getFuncInMap:(NSMutableDictionary *)addrToFuncMap addr:(uint64_t)addr
{
    NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
    
    BDLM_Function *obj = [addrToFuncMap objectForKey:addrObj];
    
    [addrObj release];
    addrObj = nil;
    
    return obj;
}

- (BDLM_Function *)getFuncWithAddrV1:(uint64_t)addr
{
    return [self getFuncInMap:_addrToFuncMapV1 addr:addr];
}

- (BDLM_Function *)getFuncWithAddrV2:(uint64_t)addr
{
    return [self getFuncInMap:_addrToFuncMapV2 addr:addr];
}

- (BOOL)isFuncAddrInV1:(uint64_t)addr
{
    return [self isAddrInMap:_addrToFuncMapV1 addr:addr];
}

- (BOOL)isFuncAddrInV2:(uint64_t)addr
{
    return [self isAddrInMap:_addrToFuncMapV2 addr:addr];
}

@end
