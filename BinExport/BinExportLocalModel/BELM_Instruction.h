//
//  BELM_Instruction.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import <Foundation/Foundation.h>

@class BinExport2;
@class BELM_Module;

@interface BELM_Instruction : NSObject
{
    uint64_t _addr;
    
    NSString *_mnem;
    NSMutableArray *_opArray;
    
    NSMutableArray *_callTargetAddrArray;
    NSMutableArray *_commentArray;
    int32_t _instIndex;
    int64_t _deltaAddr;
    NSMutableArray *_callTargetNameArray;
}

@property(nonatomic, assign) uint64_t addr;
@property(nonatomic, retain) NSString *mnem;
@property(nonatomic, retain) NSMutableArray *opArray;
@property(nonatomic, retain) NSData *rawBytes;
@property(nonatomic, retain) NSMutableArray *callTargetAddrArray;
@property(nonatomic, assign) int32_t instIndex;
@property(nonatomic, assign) int64_t deltaAddr; // inst addr - bb addr
@property(nonatomic, retain) NSMutableArray *callTargetNameArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 index:(int32_t)index;

- (NSString *)getDisassembly;
- (NSString *)getJoinedOperands;
- (NSArray *)getOperandsArray;

- (NSString *)getCallTargetStr;
- (NSString *)getComments;

- (BOOL)isEqual:(id)object;

- (void)postProcess:(BELM_Module *)belmModule;

@end
