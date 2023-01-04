//
//  BinDiff_DB_Instruction.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>

@interface BinDiff_DB_Instruction : NSObject

@property(assign) int basicblockid;
@property(assign) uint64_t address1;
@property(assign) uint64_t address2;

@end
