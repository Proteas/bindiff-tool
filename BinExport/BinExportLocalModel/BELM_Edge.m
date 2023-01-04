//
//  BELM_Edge.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import "BELM_Edge.h"

@interface BELM_Edge ()
{
    //
}

//

@end

@implementation BELM_Edge

@synthesize sourceBasicBlockIndex = _sourceBasicBlockIndex;
@synthesize targetBasicBlockIndex = _targetBasicBlockIndex;
@synthesize sourceBasicBlockAddr = _sourceBasicBlockAddr;
@synthesize targetBasicBlockAddr = _targetBasicBlockAddr;
@synthesize type = _type;
@synthesize isBackEdge = _isBackEdge;

- (instancetype)init
{
    if ((self = [super init])) {
        _isBackEdge = NO;
        _type = 0;
        _sourceBasicBlockIndex = -1;
        _targetBasicBlockIndex = -1;
        _sourceBasicBlockAddr = -1;
        _targetBasicBlockAddr = -1;
    }
    
    return self;
}

- (void)dealloc
{
    //
    [super dealloc];
}

@end
