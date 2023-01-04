//
//  BELM_Function.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import "BELM_Function.h"
#import "GPBProtocolBuffers.h"
#import "Binexport2.pbobjc.h"
#import "BinExport_Helper.h"
#import "BELM_BasicBlock.h"
#import "BELM_Module.h"

@interface BELM_Function ()
{
    NSMutableDictionary<NSNumber *, BELM_BasicBlock*> *_addrToBBMap;
    NSMutableArray *_bbArray;
}

@property(nonatomic, retain) NSString *mangledName;
@property(nonatomic, retain) NSString *demangledName;
@property(nonatomic, retain) NSMutableDictionary *addrToBBMap;

- (BOOL)transformFrom:(BinExport2 *)binExp2 flowGraph:(BinExport2_FlowGraph *)flowGraph vertex:(BinExport2_CallGraph_Vertex *)vertex;
- (void)parseEdgeArray:(BinExport2 *)binExp2 flowGraph:(BinExport2_FlowGraph *)flowGraph;
- (void)buildMap;
- (void)collectCallTargetAddr;

@end

@implementation BELM_Function

@synthesize bbArray = _bbArray;
@synthesize type = _type;
@synthesize addrToBBMap = _addrToBBMap;
@synthesize callTargetAddrArray = _callTargetAddrArray;
@synthesize callTargetNameArray = _callTargetNameArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 flowGraph:(BinExport2_FlowGraph *)flowGraph vertex:(BinExport2_CallGraph_Vertex *)vertex
{
    if ((self = [super init])) {
        _bbArray = [[NSMutableArray alloc] init];
        _edgeArray = [[NSMutableArray alloc] init];
        _addrToBBMap = [[NSMutableDictionary alloc] init];
        _callTargetAddrArray = [[NSMutableArray alloc] init];
        _callTargetNameArray = [[NSMutableArray alloc] init];
        
        if ([self transformFrom:binExp2 flowGraph:flowGraph vertex:vertex] == NO) {
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
    self.addr = -1;
    self.mangledName = nil;
    self.demangledName = nil;
    
    self.bbArray = nil;
    self.edgeArray = nil;
    self.addrToBBMap = nil;
    
    self.callTargetAddrArray = nil;
    self.callTargetNameArray = nil;
    
    [super dealloc];
}

- (void)parseEdgeArray:(BinExport2 *)binExp2 flowGraph:(BinExport2_FlowGraph *)flowGraph
{
    if (flowGraph.edgeArray_Count == 0) {
        return;
    }
    
    for (BinExport2_FlowGraph_Edge *origEdge in flowGraph.edgeArray) {
        BELM_Edge *edge = [[BELM_Edge alloc] init];
        
        edge.type = origEdge.type;
        if (origEdge.hasIsBackEdge) {
            edge.isBackEdge = origEdge.isBackEdge;
        }
        
        if (origEdge.hasSourceBasicBlockIndex) {
            edge.sourceBasicBlockIndex = origEdge.sourceBasicBlockIndex;
            edge.sourceBasicBlockAddr = BEH_GetBBlockFirstInstAddr(binExp2, origEdge.sourceBasicBlockIndex);
        }
        
        if (origEdge.hasTargetBasicBlockIndex) {
            edge.targetBasicBlockIndex = origEdge.targetBasicBlockIndex;
            edge.targetBasicBlockAddr = BEH_GetBBlockFirstInstAddr(binExp2, origEdge.targetBasicBlockIndex);
        }
        
        [self.edgeArray addObject:edge];
        
        [edge release];
        edge = nil;
    }
}

- (BOOL)transformFrom:(BinExport2 *)binExp2 flowGraph:(BinExport2_FlowGraph *)flowGraph vertex:(BinExport2_CallGraph_Vertex *)vertex
{
    self.addr = vertex.address;
    self.mangledName = vertex.mangledName;
    self.demangledName = vertex.demangledName;
    self.type = vertex.type;
    
    for (int idx = 0; idx < flowGraph.basicBlockIndexArray_Count; ++idx) {
        int32_t bbIdx = [flowGraph.basicBlockIndexArray valueAtIndex:idx];
        
        BELM_BasicBlock *bbObj = [[BELM_BasicBlock alloc] initWithBinExport:binExp2 index:bbIdx];
        if (bbObj) {
            if (bbObj.blockIndex == flowGraph.entryBasicBlockIndex) {
                bbObj.isEntry = YES;
            }
            
            bbObj.deltaAddr = bbObj.addr - self.addr;
#if (0)
            if (bbObj.deltaAddr < 0) {
                printf("[-] %s: block addr delta less than 0: %lld, function: 0x%llX, block: 0x%llX, %s\n", __FUNCTION__, bbObj.deltaAddr, _addr, bbObj.addr, [self getName].UTF8String);
            }
#endif
            [self.bbArray addObject:bbObj];
        }
        else {
            printf("[-] %s: fail to transform basic block\n", __FUNCTION__);
        }
        
        [bbObj release];
        bbObj = nil;
    }
    
    [self parseEdgeArray:binExp2 flowGraph:flowGraph];
    
    return YES;
}

- (void)buildMap
{
    for (BELM_BasicBlock *bbObj in self.bbArray) {
        NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:bbObj.addr];
        [_addrToBBMap setObject:bbObj forKey:addrObj];
        [addrObj release];
        addrObj = nil;
    }
}

- (void)collectCallTargetAddr
{
    for (BELM_BasicBlock *bbObj in self.bbArray) {
        [_callTargetAddrArray addObjectsFromArray:bbObj.callTargetAddrArray];
    }
}

- (NSString *)getName
{
    if ([self.demangledName length]) {
        return self.demangledName;
    }
    else if ([self.mangledName length]) {
        return self.mangledName;
    }
    else {
        return [NSString stringWithFormat:@"sub_%llX", _addr];
    }
}

- (BELM_BasicBlock *)getBasicBlockWithAddr:(uint64_t)addr
{
    NSNumber *addrObj = [[NSNumber alloc] initWithUnsignedLongLong:addr];
    BELM_BasicBlock *bbObj = [_addrToBBMap objectForKey:addrObj];
    [addrObj release];
    addrObj = nil;
    
    return bbObj;
}

- (BOOL)hasBasicBlockWithAddr:(uint64_t)addr
{
    BELM_BasicBlock *bbObj = [self getBasicBlockWithAddr:addr];
    
    return (bbObj != nil);
}

- (void)dumpBasicBlocks
{
    for (BELM_BasicBlock *bb in self.bbArray) {
        [bb dumpInstructions];
        printf("    --------------------------------\n");
    }
}

- (void)postProcess:(BELM_Module *)belmModule
{
    for (BELM_BasicBlock *bbObj in self.bbArray) {
        [bbObj postProcess:belmModule];
    }
    
    for (BELM_BasicBlock *bbObj in self.bbArray) {
        [_callTargetNameArray addObjectsFromArray:bbObj.callTargetNameArray];
    }
}

- (NSUInteger)getInstructionCount
{
    NSUInteger instCount = 0;
    
    for (BELM_BasicBlock *bbObj in self.bbArray) {
        instCount += [bbObj getInstructionCount];
    }
    
    return instCount;
}

@end
