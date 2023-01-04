//
//  BDT_OutputerJSON.h
//  bindiff-tool
//
//  Created by Proteas on 2022/5/17.
//

#import <Foundation/Foundation.h>

@class UDF_Module;

@interface BDT_OutputerJSON : NSObject
{
    //
}

- (instancetype)initWithModule:(UDF_Module *)udfModule;
- (void)outputToJSONFilePath:(NSString *)jsonFilePath;

@end
