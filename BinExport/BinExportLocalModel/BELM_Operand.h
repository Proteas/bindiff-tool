//
//  BELM_Operand.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import <Foundation/Foundation.h>

@class BinExport2;

@interface BELM_Operand : NSObject
{
    int32_t _opIndex;
}

@property(nonatomic, assign) int32_t opIndex;

- (instancetype)initWithBinExport:(BinExport2 *)binExp2 index:(int32_t)index;

- (NSString *)getExpression;

@end
