//
//  BELM_Module.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import "BELM_Module.h"
#import "GPBProtocolBuffers.h"
#import "Binexport2.pbobjc.h"
#import "BinExport_Helper.h"
#import "BELM_Function.h"

@interface BELM_Module ()
{
    NSMutableDictionary<NSNumber *, BELM_Function*> *_addrToFuncMap;
}

@property(nonatomic, retain) NSMutableDictionary *addrToFuncMap;

- (BOOL)transformFrom:(BinExport2 *)binExp2;
- (void)buildMap;
- (void)postProcess:(BELM_Module *)belmModule;

@end

@implementation BELM_Module

@synthesize funcArray = _funcArray;
@synthesize addrToFuncMap = _addrToFuncMap;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2
{
    if ((self = [super init])) {
        _funcArray = [[NSMutableArray alloc] init];
        _addrToFuncMap = [[NSMutableDictionary alloc] init];
        if ([self transformFrom:binExp2] == NO) {
            [self release];
            self = nil;
        }
        else {
            [self buildMap];
            [self postProcess:self];
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.funcArray = nil;
    self.addrToFuncMap = nil;
    
    [super dealloc];
}

- (BOOL)transformFrom:(BinExport2 *)binExp2
{
    NSDictionary<NSNumber *, BinExport2_CallGraph_Vertex *> *vertexMap = BEH_BuildFunctionMap(binExp2);
    
    for (BinExport2_FlowGraph *flowGraph in binExp2.flowGraphArray) {
        uint64_t addr = BEH_GetFlowGraphEntryBasicBlockAddr(binExp2, flowGraph);
        BinExport2_CallGraph_Vertex *vertex = [vertexMap objectForKey:[NSNumber numberWithUnsignedLongLong:addr]];
        if (vertex == nil) {
            printf("[-] %s: can't find vertex\n", __FUNCTION__);
            continue;;
        }
        
        BELM_Function *funcObj = [[BELM_Function alloc] initWithBinExport:binExp2 flowGraph:flowGraph vertex:vertex];
        if (funcObj) {
            [self.funcArray addObject:funcObj];
        }
        else {
            printf("[-] %s: fail to transform function\n", __FUNCTION__);
        }
        
        [funcObj release];
        funcObj = nil;
    }
    
    return YES;
}

- (void)buildMap
{
    for (BELM_Function *funcObj in self.funcArray) {
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:funcObj.addr];
        [_addrToFuncMap setObject:funcObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (BELM_Function *)getFuncWithAddr:(uint64_t)addr
{
    NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
    BELM_Function *funcObj = [_addrToFuncMap objectForKey:addrObj];
    [addrObj release];
    addrObj = nil;
    
    return funcObj;
}

- (NSString *)getFuncNameWithAddrObj:(NSNumber *)addrObj
{
    BELM_Function *funcObj = [_addrToFuncMap objectForKey:addrObj];
    return [funcObj getName];
}

- (BOOL)hasFuncWithAddr:(uint64_t)addr
{
    BELM_Function *funcObj = [self getFuncWithAddr:addr];
    
    return (funcObj != nil);
}

- (BOOL)isNormalFunc:(uint64_t)addr
{
    BELM_Function *funcObj = [self getFuncWithAddr:addr];
    if (funcObj == nil) {
        return NO;
    }
    
    return (funcObj.type = BELM_FunctionType_Normal);
}

- (void)dumpFunctions
{
    for (BELM_Function *func in self.funcArray) {
        printf("Function: 0x%llX, %s\n", func.addr, [func getName].UTF8String);
        [func dumpBasicBlocks];
        printf("==================== End Function =================\n\n");
    }
}

- (void)postProcess:(BELM_Module *)belmModule
{
    for (BELM_Function *funcObj in self.funcArray) {
        [funcObj postProcess:belmModule];
    }
}

@end
