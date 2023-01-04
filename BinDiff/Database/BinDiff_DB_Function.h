//
//  BinDiff_DB_Function.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>

@interface BinDiff_DB_Function : NSObject

@property(assign) int ID;
@property(assign) uint64_t address1;
@property(retain) NSString *name1;
@property(assign) uint64_t address2;
@property(retain) NSString *name2;
@property(assign) double similarity;
@property(assign) double confidence;
@property(assign) uint32_t flags;
@property(assign) int algorithm;
@property(assign) int evaluate;
@property(assign) int commentsported;
@property(assign) uint64_t basicblocks;
@property(assign) uint64_t edges;
@property(assign) uint64_t instructions;

@end
