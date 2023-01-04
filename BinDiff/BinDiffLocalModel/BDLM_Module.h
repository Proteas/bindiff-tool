//
//  BDLM_Module.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>
#import "BinDiff_DB_File.h"
#import "BinDiff_DB_Meta.h"

@class BinDiff_DB;
@class BDLM_Function;

@interface BDLM_Module : NSObject
{
    BinDiff_DB_File *_fileInfo;
    BinDiff_DB_Meta *_metaInfo;
}

@property(nonatomic, retain, readonly) BinDiff_DB_File *fileInfo;
@property(nonatomic, retain, readonly) BinDiff_DB_Meta *metaInfo;
@property(nonatomic, retain) NSMutableArray<BDLM_Function *> *funcArray;

- (instancetype)initWithDB:(BinDiff_DB *)db;

- (BOOL)isFuncAddrInV1:(uint64_t)addr;
- (BOOL)isFuncAddrInV2:(uint64_t)addr;

- (BDLM_Function *)getFuncWithAddrV1:(uint64_t)addr;
- (BDLM_Function *)getFuncWithAddrV2:(uint64_t)addr;

@end
