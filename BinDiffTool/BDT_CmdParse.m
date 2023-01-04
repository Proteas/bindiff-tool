//
//  BDT_CmdParse.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/27.
//

#import "BDT_CmdParse.h"
#import <unistd.h>
#import <getopt.h>

static const char *gOptStr = "d:1:2:js";
static struct option gOptions[] = {
    {"diff",    required_argument, NULL, 'd'},
    {"v1",      required_argument, NULL, '1'},
    {"v2",      required_argument, NULL, '2'},
    {"js",      optional_argument, NULL, 'j'},
    {"json",    optional_argument, NULL, 's'},
    {0, 0, 0, 0}
};

@interface BDT_CmdParse ()
{
    //
}

- (void)printUsage;
- (BOOL)parseArgc:(int)argc argv:(char * const [])argv;

@end

@implementation BDT_CmdParse

@synthesize diffFilePath = _diffFilePath;
@synthesize expFilePathV1 = _expFilePathV1;
@synthesize expFilePathV2 = _expFilePathV2;
@synthesize cmdPrint = _cmdPrint;
@synthesize jsFilePath = _jsFilePath;
@synthesize jsonFilePath = _jsonFilePath;

- (instancetype)initWithArgc:(int)argc argv:(char * const [])argv
{
    if ((self = [super init])) {
        if ([self parseArgc:argc argv:argv] == NO) {
            [self release];
            self = nil;
        }
        else {
            _cmdPrint = YES;
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.diffFilePath = nil;
    self.expFilePathV1 = nil;
    self.expFilePathV2 = nil;
    self.jsFilePath = nil;
    self.jsonFilePath = nil;
    
    [super dealloc];
}

- (void)printUsage
{
    printf("Usage: bindiff-tool\n"
           "\t--diff V1_vs_V2.BinDiff\n"
           "\t--v1 V1.BinExport\n"
           "\t--v2 V2.BinExport\n"
           "\t--js Filter.js, optional\n"
           "\t--json Result.json, optional\n");
}

- (BOOL)parseArgc:(int)argc argv:(char * const [])argv
{
    if (argc == 1) {
        [self printUsage];
        return NO;
    }
    
    int opt = -1;
    while ( (opt = getopt_long(argc, argv, gOptStr, gOptions, NULL)) != -1) {
        switch (opt) {
            case 'd': {
                self.diffFilePath = [NSString stringWithUTF8String:optarg];
                break;
            }
            case '1': {
                self.expFilePathV1 = [NSString stringWithUTF8String:optarg];
                break;
            }
            case '2': {
                self.expFilePathV2 = [NSString stringWithUTF8String:optarg];
                break;
            }
            case 'j': {
                if (optind < argc) {
                    self.jsFilePath = [NSString stringWithUTF8String:argv[optind++]];
                }
                else {
                    [self printUsage];
                    return NO;
                }
                break;
            }
            case 's': {
                if (optind < argc) {
                    self.jsonFilePath = [NSString stringWithUTF8String:argv[optind++]];
                }
                else {
                    [self printUsage];
                    return NO;
                }
                break;
            }
            default: {
                [self printUsage];
                return NO;
                break;
            }
        }
    }
    
    if (optind != argc) {
        [self printUsage];
        return NO;
    }
    
    return YES;
}

@end
