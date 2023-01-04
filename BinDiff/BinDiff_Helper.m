//
//  BinDiff_Helper.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import "BinDiff_Helper.h"

NSString * BDH_FuncDiffFlagsToStr(uint32_t flags)
{
    char buf[8] = {'G', 'I', 'O', 'J', 'E', 'L', 'C', 0x00};
    for (int idx = 0; idx < 7; ++idx) {
        uint32_t flag = flags >> idx;
        if ((flag & 1) == 0) {
            buf[idx] = '-';
        }
    }
    
    return [NSString stringWithUTF8String:buf];
}

NSString * BDH_FuncDiffFlagsNone(void)
{
    return @"-------";
}
