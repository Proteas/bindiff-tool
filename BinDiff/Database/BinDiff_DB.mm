//
//  BinDiff_DB.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_DB.h"
#import <WCDB/WCDB.h>

@interface BinDiff_DB ()
{
    WCTDatabase *_database;
    NSMutableDictionary<NSNumber *, NSMutableArray<BinDiff_DB_BasicBlock *> *> *_mapFuncIDToBBArray;
    NSMutableDictionary<NSNumber *, NSMutableArray<BinDiff_DB_Instruction *> *> *_mapBBIDToInstArray;
}

@property(nonatomic, retain) NSMutableDictionary *mapFuncIDToBBArray;
@property(nonatomic, retain) NSMutableDictionary *mapBBIDToInstArray;

- (void)groupBasicBlocksByFunctionID;
- (void)groupInstructionsByBasicBlockID;

@end

@implementation BinDiff_DB
@synthesize metaArray = _metaArray;
@synthesize fileArray = _fileArray;
@synthesize funcAlgoArray = _funcAlgoArray;
@synthesize funcArray = _funcArray;
@synthesize bbAlgoArray = _bbAlgoArray;
@synthesize bbArray = _bbArray;
@synthesize instArray = _instArray;
@synthesize mapFuncIDToBBArray = _mapFuncIDToBBArray;
@synthesize mapBBIDToInstArray = _mapBBIDToInstArray;

- (instancetype)initWithPath:(NSString *)dbPath
{
    if ([dbPath length] == 0) {
        NSLog(@"[-] db path invalid");
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath] == NO) {
        NSLog(@"[-] db not exists: %@", dbPath);
        return nil;
    }
    
    if ((self = [super init])) {
        _database = [[WCTDatabase alloc] initWithPath:dbPath];
        if (_database == nil) {
            NSLog(@"[-] can't open db: %@", dbPath);
            [self release];
            return nil;
        }
        
        self.metaArray = [_database getAllObjectsOfClass:BinDiff_DB_Meta.class
                                               fromTable:@"metadata"];
        
        self.fileArray = [_database getAllObjectsOfClass:BinDiff_DB_File.class
                                               fromTable:@"file"];
        
        self.funcAlgoArray = [_database getAllObjectsOfClass:BinDiff_DB_FunctionAlgo.class
                                                   fromTable:@"functionalgorithm"];
        
        self.funcArray = [_database getAllObjectsOfClass:BinDiff_DB_Function.class
                                               fromTable:@"function"];
        
        self.bbAlgoArray = [_database getAllObjectsOfClass:BinDiff_DB_BasicBlockAlgo.class
                                                 fromTable:@"basicblockalgorithm"];
        
        self.bbArray = [_database getAllObjectsOfClass:BinDiff_DB_BasicBlock.class
                                             fromTable:@"basicblock"];
        
        self.instArray = [_database getAllObjectsOfClass:BinDiff_DB_Instruction.class
                                               fromTable:@"instruction"];
        
        [self groupBasicBlocksByFunctionID];
        [self groupInstructionsByBasicBlockID];
    }
    
    return self;
}

- (void)dealloc
{
    self.metaArray = nil;
    self.fileArray = nil;
    self.funcAlgoArray = nil;
    self.funcArray = nil;
    self.bbAlgoArray = nil;
    self.bbArray = nil;
    self.instArray = nil;
    self.mapFuncIDToBBArray = nil;
    self.mapBBIDToInstArray = nil;
    if (_database) {
        [_database close];
        [_database release];
        _database = nil;
    }
    
    [super dealloc];
}

- (NSArray<BinDiff_DB_BasicBlock *> *)getBasicBlocksWithFunctionID:(int)funcID
{
    WCTProperty propName("functionid");
    NSArray<BinDiff_DB_BasicBlock *> *retArray = [_database getObjectsOfClass:BinDiff_DB_BasicBlock.class fromTable:@"basicblock" where:propName == funcID];
    
    return retArray;
}

- (NSArray<BinDiff_DB_Instruction *> *)getInstructionsWithBasicBlockID:(int)basicBlockID
{
    WCTProperty propName("basicblockid");
    NSArray<BinDiff_DB_Instruction *> *retArray = [_database getObjectsOfClass:BinDiff_DB_Instruction.class fromTable:@"instruction" where:propName == basicBlockID];
    
    return retArray;
}

- (void)groupBasicBlocksByFunctionID
{
    if (_mapFuncIDToBBArray) {
        return;
    }
    
    _mapFuncIDToBBArray = [[NSMutableDictionary alloc] init];
    
    for (BinDiff_DB_BasicBlock *bbObj in self.bbArray) {
        NSNumber *funcIDObj = [[NSNumber alloc] initWithInt:bbObj.functionid];
        
        NSMutableArray *bbArray = [_mapFuncIDToBBArray objectForKey:funcIDObj];
        if (bbArray == nil) {
            bbArray = [[NSMutableArray alloc] init];
            [_mapFuncIDToBBArray setObject:bbArray forKey:funcIDObj];
            [bbArray release];
            //bbArray = nil;
        }
        
        [bbArray addObject:bbObj];
        
        [funcIDObj release];
        funcIDObj = nil;
    }
}

- (void)groupInstructionsByBasicBlockID
{
    if (_mapBBIDToInstArray) {
        return;
    }
    
    _mapBBIDToInstArray = [[NSMutableDictionary alloc] init];
    
    for (BinDiff_DB_Instruction *instObj in self.instArray) {
        NSNumber *bbIDObj = [[NSNumber alloc] initWithInt:instObj.basicblockid];
        
        NSMutableArray *instArray = [_mapBBIDToInstArray objectForKey:bbIDObj];
        if (instArray == nil) {
            instArray = [[NSMutableArray alloc] init];
            [_mapBBIDToInstArray setObject:instArray forKey:bbIDObj];
            [instArray release];
            //instArray = nil;
        }
        
        [instArray addObject:instObj];
        
        [bbIDObj release];
        bbIDObj = nil;
    }
}

- (NSArray<BinDiff_DB_BasicBlock *> *)getBasicBlocksWithFunctionID2:(int)funcID
{
    NSNumber *funcIDObj = [[NSNumber alloc] initWithInt:funcID];
    
    NSArray<BinDiff_DB_BasicBlock *> *retArray = [_mapFuncIDToBBArray objectForKey:funcIDObj];
    
    [funcIDObj release];
    funcIDObj = nil;
    
    return retArray;
}

- (NSArray<BinDiff_DB_Instruction *> *)getInstructionsWithBasicBlockID2:(int)basicBlockID
{
    NSNumber *bbIDObj = [[NSNumber alloc] initWithInt:basicBlockID];
    
    NSArray<BinDiff_DB_Instruction *> *retArray = [_mapBBIDToInstArray objectForKey:bbIDObj];
    
    [bbIDObj release];
    bbIDObj = nil;
    
    return retArray;
}

- (void)dumpDiff
{
    printf("[+] Function: \n");
    for (BinDiff_DB_Function *obj in self.funcArray) {
        printf("    func1: 0x%llX, func2: 0x%llX\n", obj.address1, obj.address2);
    }
    printf("\n");
    
    printf("[+] Basic Block: \n");
    for (BinDiff_DB_BasicBlock *obj in self.bbArray) {
        printf("    bb1: 0x%llX, bb2: 0x%llX\n", obj.address1, obj.address2);
    }
    printf("\n");
    
#if (0)
    printf("[+] Instruction: \n");
    for (BinDiff_DB_Instruction *obj in self.instArray) {
        printf("    inst1: 0x%llX, inst2: 0x%llX\n", obj.address1, obj.address2);
    }
    printf("\n");
#endif
}

@end
