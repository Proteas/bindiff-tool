//
//  BDT_OutputerJSON.m
//  bindiff-tool
//
//  Created by Proteas on 2022/5/17.
//

#import "BDT_OutputerJSON.h"

#import "BinDiff_Helper.h"
#import "BinExport_Helper.h"
#import "BinDiff_DB.h"

#import "UDF_Module.h"
#import "BDLM_Module.h"
#import "BELM_Module.h"

#import "UDF_Function.h"
#import "BDLM_Function.h"
#import "BELM_Function.h"

#import "UDF_BasicBlock.h"
#import "BDLM_BasicBlock.h"
#import "BELM_BasicBlock.h"

#import "UDF_Instruction.h"
#import "BDLM_Instruction.h"
#import "BELM_Instruction.h"

@interface BDT_OutputerJSON()
{
    UDF_Module *_udfModule;
}

@property(nonatomic, retain) UDF_Module *udfModule;

@end

@implementation BDT_OutputerJSON

@synthesize udfModule = _udfModule;

- (instancetype)initWithModule:(UDF_Module *)udfModule;
{
    if ((self = [super init])) {
        self.udfModule = udfModule;
    }
    
    return self;
}

- (void)dealloc
{
    self.udfModule = nil;
    
    [super dealloc];
}

- (void)outputToJSONFilePath:(NSString *)jsonFilePath
{
    @autoreleasepool {
        NSMutableDictionary *rootObj = [NSMutableDictionary dictionary];
        
        //[rootObj setObject:[NSMutableArray array] forKey:@"unmatch_1st"];
        //[rootObj setObject:[NSMutableArray array] forKey:@"unmatch_2nd"];
        
        NSMutableArray *funcArrayChanged = [NSMutableArray array];
        [rootObj setObject:funcArrayChanged forKey:@"func_changed"];
        
        NSArray *udfFuncArray = [_udfModule getFunction_Changed_Normal];
        for (int idx = 0; idx < udfFuncArray.count; ++idx) {
            UDF_Function *udfFunc = udfFuncArray[idx];
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            
            NSString *addrStr1 = [NSString stringWithFormat:@"0x%llX", udfFunc.diff.refFunc.address1];
            [item setObject:addrStr1 forKey:@"addr1"];
            NSString *addrStr2 = [NSString stringWithFormat:@"0x%llX", udfFunc.diff.refFunc.address2];
            [item setObject:addrStr2 forKey:@"addr2"];
            
            NSNumber *addrObj1 = [NSNumber numberWithUnsignedLongLong:udfFunc.diff.refFunc.address1];
            [item setObject:addrObj1 forKey:@"address1"];
            NSNumber *addrObj2 = [NSNumber numberWithUnsignedLongLong:udfFunc.diff.refFunc.address2];
            [item setObject:addrObj2 forKey:@"address2"];
            
            [item setObject:udfFunc.diff.refFunc.name1 forKey:@"name1"];
            [item setObject:udfFunc.diff.refFunc.name2 forKey:@"name2"];
            
            [item setObject:[NSNumber numberWithInt:[udfFunc getFuncDiffFlags]] forKey:@"flags"];
            [item setObject:[udfFunc getFuncDiffFlagsStr] forKey:@"flags2"];
            
            [funcArrayChanged addObject:item];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rootObj
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (error != nil) {
            printf("[-] %s: %s\n", __FUNCTION__, error.description.UTF8String);
            return;
        }
        
        [jsonData writeToFile:jsonFilePath atomically:NO];
        printf("[+] json: %s\n", jsonFilePath.UTF8String);
        printf("\n");
    }
}

@end
