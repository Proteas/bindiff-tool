//
//  BELM_Edge.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/24.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef enum _BELM_EdgeType {
    BELM_EdgeType_ConditionTrue = 1,
    BELM_EdgeType_ConditionFalse = 2,
    BELM_EdgeType_Unconditional = 3,
    BELM_EdgeType_Switch = 4,
} BELM_EdgeType;

@protocol JS_BELM_Edge <JSExport>

@property(nonatomic, assign) uint64_t sourceBasicBlockAddr;
@property(nonatomic, assign) uint64_t targetBasicBlockAddr;
@property(nonatomic, assign) BELM_EdgeType type;
@property(nonatomic, assign) BOOL isBackEdge;

@end

@interface BELM_Edge : NSObject <JS_BELM_Edge>
{
    int32_t _sourceBasicBlockIndex;
    int32_t _targetBasicBlockIndex;
    
    uint64_t _sourceBasicBlockAddr;
    uint64_t _targetBasicBlockAddr;
    BELM_EdgeType _type;
    BOOL _isBackEdge;
}

@property(nonatomic, assign) int32_t sourceBasicBlockIndex;
@property(nonatomic, assign) int32_t targetBasicBlockIndex;

@end
