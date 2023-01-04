//
//  BinDiff_Helper.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "BinDiff_DB.h"

/*
 flags: https://www.zynamics.com/bindiff/manual/#N2070F
 G: 0b1 << 0, Graph: there have been structural changes in the function. Either the number of basic blocks or the number of edges differs or unmatched edges exist.
 I: 0b1 << 1, Instruction: either the number of instructions differs or at least one mnemonic has changed.
 O: 0b1 << 2, Operand: not yet implemented
 J: 0b1 << 3, Jump: indicates a branch inversion.
 E: 0b1 << 4, Entrypoint: the entry point basic blocks have not been matched or are different.
 L: 0b1 << 5, Loop: the number of loops has changed.
 C: 0b1 << 6, Call: at least one of the call targets hasn't been matched.
 */
typedef enum _FuncDiffFlags {
    FuncDiffFlags_G = 1 << 0, // Graph
    FuncDiffFlags_I = 1 << 1, // Instruction
    FuncDiffFlags_O = 1 << 2, // Operand
    FuncDiffFlags_J = 1 << 3, // Jump
    FuncDiffFlags_E = 1 << 4, // Entrypoint
    FuncDiffFlags_L = 1 << 5, // Loop
    FuncDiffFlags_C = 1 << 6, // Call
} FuncDiffFlags;

NSString * BDH_FuncDiffFlagsToStr(uint32_t flags);
NSString * BDH_FuncDiffFlagsNone(void);
