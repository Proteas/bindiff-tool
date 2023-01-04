//
//  BDLM_Function.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>

@class BinDiff_DB;
@class BinDiff_DB_Function;
@class BDLM_BasicBlock;

@interface BDLM_Function : NSObject
{
    BinDiff_DB_Function *_refFunc;
    NSString *_algorithm;
}

@property(nonatomic, retain, readonly) BinDiff_DB_Function *refFunc;
@property(nonatomic, retain, readonly) NSString *algorithm;
@property(nonatomic, retain) NSMutableArray<BDLM_BasicBlock *> *basicBlockArray;

- (instancetype)initWithDB:(BinDiff_DB *)db function:(BinDiff_DB_Function *)function;

- (BOOL)isBasicBlockAddrInV1:(uint64_t)addr;
- (BOOL)isBasicBlockAddrInV2:(uint64_t)addr;

- (BDLM_BasicBlock *)getBasicBlockWithAddrV1:(uint64_t)addr;
- (BDLM_BasicBlock *)getBasicBlockWithAddrV2:(uint64_t)addr;

@end
