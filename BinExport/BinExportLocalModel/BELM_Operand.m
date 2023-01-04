//
//  BELM_Operand.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import "BELM_Operand.h"
#import "GPBProtocolBuffers.h"
#import "Binexport2.pbobjc.h"
#import "BinExport_Helper.h"

@interface BELM_Operand ()
{
    NSMutableString *_expStr;
}

@property(nonatomic, retain) NSMutableString *expStr;

- (BOOL)transformFrom:(BinExport2 *)binExp2 index:(int32_t)index;

@end

@implementation BELM_Operand

@synthesize expStr = _expStr;
@synthesize opIndex = _opIndex;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 index:(int32_t)index
{
    if ((self = [super init])) {
        _opIndex = index;
        
        if ([self transformFrom:binExp2 index:index] == NO) {
            [self release];
            self = nil;
        }
        else {
            //
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.expStr = nil;
    
    [super dealloc];
}

- (BOOL)transformFrom:(BinExport2 *)binExp2 index:(int32_t)index
{
    BinExport2_Operand *opObj = [binExp2.operandArray objectAtIndex:index];
    
    self.expStr = nil;
    _expStr = [[NSMutableString alloc] init];
    
    for (int32_t expLoopIdx = 0; expLoopIdx < opObj.expressionIndexArray.count; ++expLoopIdx) {
        int32_t expIdx = [opObj.expressionIndexArray valueAtIndex:expLoopIdx];
        BinExport2_Expression *expObj = [binExp2.expressionArray objectAtIndex:expIdx];
        if (expObj.hasParentIndex == NO) {
            BEH_RenderExpression(binExp2, opObj, expLoopIdx, _expStr);
        }
    }
    
    return YES;
}

- (NSString *)getExpression
{
    return self.expStr;
}

@end
