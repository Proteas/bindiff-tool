//
//  BDT_JSInterface.m
//  bindiff-tool
//
//  Created by Proteas on 2022/5/10.
//

#import "BDT_JSInterface.h"
#import "UDF_Common.h"

//https://steamclock.com/blog/2013/05/apple-objective-c-javascript-bridge/
//https://github.com/steamclock/javascriptcore-api-test/blob/master/JSCTest/AppDelegate.m
//https://cloud.tencent.com/developer/article/1004875
//https://cloud.tencent.com/developer/article/1004876
//https://github.com/WebKit/webkit/blob/main/Source/JavaScriptCore/API/tests/testapi.mm

@interface BDT_JSInterface ()
{
    JSContext *_jsCtx;
    NSMutableArray *_exportedKeyArray;
}

@property(nonatomic, retain) JSContext *jsCtx;
@property(nonatomic, copy) void(^exceptionHandler)(JSContext *context, JSValue *exception);
@property(nonatomic, retain) NSMutableArray *exportedKeyArray;

- (void)print:(NSString *)msg color:(const char *)colorStr;
- (void)printLine:(NSString *)msg color:(const char *)colorStr;

@end

@implementation BDT_JSInterface

@synthesize jsCtx = _jsCtx;
@synthesize exportedKeyArray = _exportedKeyArray;

- (instancetype)init
{
    if ((self = [super init])) {
        _exportedKeyArray = [[NSMutableArray alloc] init];
        
        _jsCtx = [[JSContext alloc] init];
        _jsCtx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            JSValue * stackTrace = [exception objectForKeyedSubscript:@"stack"];
            JSValue *lineNumber = [exception objectForKeyedSubscript:@"line"];
            JSValue *column = [exception objectForKeyedSubscript:@"column"];
            printf(COLOR_HRED "%s: js exception, line: %d, column: %d, stack:\n%s\nexception: %s\n\n" COLOR_RESET, __FUNCTION__, [lineNumber toInt32], [column toInt32], [stackTrace toString].UTF8String, exception.description.UTF8String);
            context.exception = exception;
        };
    }
    
    return self;
}

- (void)dealloc
{
    if (self.exportedKeyArray) {
        for (NSString *aKey in self.exportedKeyArray) {
            self.jsCtx[aKey] = nil;
        }
        self.exportedKeyArray = nil;
    }
    
    self.exceptionHandler = nil;
    self.jsCtx = nil;
    
    [super dealloc];
}

- (void)exportObjectToJS:(NSObject *)object forKey:(NSString *)aKey
{
    [self.exportedKeyArray addObject:aKey];
    self.jsCtx[aKey] = object;
}

- (void)execJS:(NSString *)jsFilePath
{
    NSString *keyJSEntryFunc = @"BDT_JSEntry";
    
    [self exportObjectToJS:self forKey:@"BDT_Logger"];
    
    NSError *error = nil;
    NSString *jsStr = [NSString stringWithContentsOfFile:jsFilePath
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if (!jsStr || error) {
        printf("[-] %s: fail to load js: %s, %s\n", __FUNCTION__, jsFilePath.UTF8String, error.description.UTF8String);
        return;
    }
    
    //NSLog(@"js: \n%@\n", jsStr);
    
    [self.jsCtx evaluateScript:jsStr];
    
    JSValue *jsEntryFunc = [self.jsCtx.globalObject objectForKeyedSubscript:keyJSEntryFunc];
    if (jsEntryFunc == nil) {
        printf("[-] %s: can't get js function: %s()\n", __FUNCTION__, keyJSEntryFunc.UTF8String);
    }
    else {
        [jsEntryFunc callWithArguments:nil];
    }
}

- (void)print:(NSString *)msg
{
    if (msg == nil) {
        printf("[-] %s: message is nil\n", __FUNCTION__);
        return;
    }
    
    printf("%s", msg.UTF8String);
}

- (void)printLine:(NSString *)msg
{
    if (msg == nil) {
        printf("[-] %s: message is nil\n", __FUNCTION__);
        return;
    }
    
    printf("%s\n", msg.UTF8String);
}

- (void)print:(NSString *)msg color:(const char *)colorStr
{
    if (msg == nil) {
        printf("[-] %s: message is nil\n", __FUNCTION__);
        return;
    }
    
    NSString *msg2 = [NSString stringWithFormat:@"%s%@%s", colorStr, msg, COLOR_RESET];
    [self print:msg2];
}

- (void)printRed:(NSString *)msg
{
    [self print:msg color:COLOR_HRED];
}

- (void)printGreen:(NSString *)msg
{
    [self print:msg color:COLOR_HGRN];
}

- (void)printBlue:(NSString *)msg
{
    [self print:msg color:COLOR_LBLU];
}

- (void)printLine:(NSString *)msg color:(const char *)colorStr
{
    if (msg == nil) {
        printf("[-] %s: message is nil\n", __FUNCTION__);
        return;
    }
    
    NSString *msg2 = [NSString stringWithFormat:@"%s%@%s", colorStr, msg, COLOR_RESET];
    [self printLine:msg2];
}

- (void)printLineRed:(NSString *)msg
{
    [self printLine:msg color:COLOR_HRED];
}

- (void)printLineGreen:(NSString *)msg
{
    [self printLine:msg color:COLOR_HGRN];
}

- (void)printLineBlue:(NSString *)msg
{
    [self printLine:msg color:COLOR_LBLU];
}

@end
