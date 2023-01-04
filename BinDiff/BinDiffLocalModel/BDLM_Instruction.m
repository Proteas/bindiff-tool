//
//  BDLM_Instruction.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import "BDLM_Instruction.h"
#import "BinDiff_DB.h"

@interface BDLM_Instruction ()
{
    //
}

//

@end

@implementation BDLM_Instruction

@synthesize refInst = _refInst;

- (instancetype)initWithDB:(BinDiff_DB *)db instruction:(BinDiff_DB_Instruction *)instruction
{
    if ((self = [super init])) {
        _refInst = [instruction retain];
    }
    
    return self;
}

- (void)dealloc
{
    if (_refInst) {
        [_refInst release];
        _refInst = nil;
    }
    
    [super dealloc];
}

@end
