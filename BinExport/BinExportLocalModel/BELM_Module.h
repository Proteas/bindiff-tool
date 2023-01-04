//
//  BELM_Module.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import <Foundation/Foundation.h>

@class BinExport2;
@class BELM_Function;

@interface BELM_Module : NSObject
{
    NSMutableArray<BELM_Function *> *_funcArray;
}

@property(nonatomic, retain) NSMutableArray<BELM_Function *> *funcArray;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2;
- (BELM_Function *)getFuncWithAddr:(uint64_t)addr;
- (NSString *)getFuncNameWithAddrObj:(NSNumber *)addrObj;
- (BOOL)hasFuncWithAddr:(uint64_t)addr;
- (BOOL)isNormalFunc:(uint64_t)addr;
- (void)dumpFunctions;

@end
