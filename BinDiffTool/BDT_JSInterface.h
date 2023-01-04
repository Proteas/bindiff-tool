//
//  BDT_JSInterface.h
//  bindiff-tool
//
//  Created by Proteas on 2022/5/10.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JS_BDT_Logger <JSExport>

- (void)print:(NSString *)msg;
- (void)printLine:(NSString *)msg;

- (void)printRed:(NSString *)msg;
- (void)printGreen:(NSString *)msg;
- (void)printBlue:(NSString *)msg;

- (void)printLineRed:(NSString *)msg;
- (void)printLineGreen:(NSString *)msg;
- (void)printLineBlue:(NSString *)msg;

@end

@interface BDT_JSInterface : NSObject <JS_BDT_Logger>
{
    //
}

- (void)exportObjectToJS:(NSObject *)object forKey:(NSString *)aKey;
- (void)execJS:(NSString *)jsFilePath;

@end
