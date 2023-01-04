//
//  BDT_CmdParse.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/27.
//

#import <Foundation/Foundation.h>

@interface BDT_CmdParse : NSObject
{
    NSString *_diffFilePath;
    NSString *_expFilePathV1;
    NSString *_expFilePathV2;
    BOOL _cmdPrint;
    
    NSString *_jsFilePath;
    NSString *_jsonFilePath;
}

@property(nonatomic, retain) NSString *diffFilePath;
@property(nonatomic, retain) NSString *expFilePathV1;
@property(nonatomic, retain) NSString *expFilePathV2;
@property(nonatomic, assign) BOOL cmdPrint;
@property(nonatomic, retain) NSString *jsFilePath;
@property(nonatomic, retain) NSString *jsonFilePath;

- (instancetype)initWithArgc:(int)argc argv:(char * const [])argv;

@end
