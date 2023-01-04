//
//  BinDiff_DB_BasicBlock.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>

@interface BinDiff_DB_BasicBlock : NSObject

@property(assign) int ID;
@property(assign) int functionid;
@property(assign) uint64_t address1;
@property(assign) uint64_t address2;
@property(assign) int algorithm;
@property(assign) int evaluate;

@end
