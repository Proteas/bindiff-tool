//
//  BDLM_Instruction.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>

@class BinDiff_DB;
@class BinDiff_DB_Instruction;

@interface BDLM_Instruction : NSObject
{
    BinDiff_DB_Instruction *_refInst;
}

@property(nonatomic, retain, readonly) BinDiff_DB_Instruction *refInst;

- (instancetype)initWithDB:(BinDiff_DB *)db instruction:(BinDiff_DB_Instruction *)instruction;

@end
