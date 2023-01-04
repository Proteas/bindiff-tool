//
//  main.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "BDT_CmdParse.h"

#import "BinDiff_Helper.h"
#import "BinExport_Helper.h"
#import "BinDiff_DB.h"

#import "UDF_Module.h"
#import "BDLM_Module.h"
#import "BELM_Module.h"

#import "BDT_ChangesCmdPrinter.h"
#import "BDT_JSInterface.h"
#import "BDT_OutputerJSON.h"

// caller release
UDF_Module * BuildUDFModel(BDT_CmdParse *cmdParser);

int main(int argc, char * const argv[])
{
    int retCode = 0;
    
    @autoreleasepool
    {
        BDT_CmdParse *cmdParser = [[BDT_CmdParse alloc] initWithArgc:argc argv:argv];
        if (cmdParser == nil) {
            return 1;
        }
        
        printf("[+] bindiff: %s\n", cmdParser.diffFilePath.UTF8String);
        printf("[+] binexport v1: %s\n", cmdParser.expFilePathV1.UTF8String);
        printf("[+] binexport v2: %s\n", cmdParser.expFilePathV2.UTF8String);
        if (cmdParser.jsFilePath) {
            printf("[+] js: %s\n", cmdParser.jsFilePath.UTF8String);
        }
        if (cmdParser.jsonFilePath) {
            printf("[+] json: %s\n", cmdParser.jsonFilePath.UTF8String);
        }
        printf("\n");
        
        printf("[+] build unified model\n\n");
        UDF_Module *udfModel = BuildUDFModel(cmdParser);
        if (udfModel == nil) {
            printf("[-] build unified model\n");
            retCode = 1;
            goto CLEAN_RET;
        }
        //[udfModel removeFunction_Identical];
        printf("\n");
        
        if (cmdParser.cmdPrint) {
            BDT_ChangesCmdPrinter *cmdPrinter = [[BDT_ChangesCmdPrinter alloc] initWithModule:udfModel];
            if (cmdPrinter == nil) {
                printf("[-] fail to create cmd printer\n");
                retCode = 1;
                goto CLEAN_RET;
            }
            
            if (cmdParser.jsonFilePath) {
                [cmdPrinter disablePrint];
            }
            
            if (cmdParser.jsFilePath) {
                BDT_JSInterface *jsInf = [[BDT_JSInterface alloc] init];
                
                [jsInf exportObjectToJS:udfModel forKey:@"BDT_Model"];
                [jsInf exportObjectToJS:cmdPrinter forKey:@"BDT_Outputer"];
                printf("[+] start to exec js\n");
                printf("\n");
                [jsInf execJS:cmdParser.jsFilePath];
                
                [jsInf release];
                jsInf = nil;
            }
            else {
                [cmdPrinter printModule];
            }
            
            if (cmdParser.jsonFilePath) {
                BDT_OutputerJSON *jsonOutputer = [[BDT_OutputerJSON alloc] initWithModule:udfModel];
                
                [jsonOutputer outputToJSONFilePath:cmdParser.jsonFilePath];
                
                [jsonOutputer release];
                jsonOutputer = nil;
            }
            
            [cmdPrinter release];
            cmdPrinter = nil;
        }
        
CLEAN_RET:
        if (udfModel) {
            printf("[+] release unified model\n");
            [udfModel release];
            udfModel = nil;
        }
        
        if (cmdParser) {
            [cmdParser release];
            cmdParser = nil;
        }
    }
    
    return retCode;
}

UDF_Module * BuildUDFModel(BDT_CmdParse *cmdParser)
{
    BinDiff_DB *binDiff = nil;
    BinExport2 *binExpV1 = nil;
    BinExport2 *binExpV2 = nil;
    
    BELM_Module *moduleV1 = nil;
    BELM_Module *moduleV2 = nil;
    BDLM_Module *modelDiff = nil;
    
    UDF_Module *udfModel = nil;
    
    printf("[+] load bindiff\n");
    binDiff = [[BinDiff_DB alloc] initWithPath:cmdParser.diffFilePath];
    if (binDiff == nil) {
        printf("[-] fail to load diff: %s\n", cmdParser.diffFilePath.UTF8String);
        goto CLEAN_RET;
    }
#if (0)
    [binDiff dumpDiff];
#endif
    
    printf("[+] load binexport v1\n");
    binExpV1 = BEH_LoadBinExport(cmdParser.expFilePathV1);
    if (binExpV1 == nil) {
        printf("[-] fail to load exp: %s\n", cmdParser.expFilePathV1.UTF8String);
        goto CLEAN_RET;
    }
    
    printf("[+] load binexport v2\n");
    binExpV2 = BEH_LoadBinExport(cmdParser.expFilePathV2);
    if (binExpV2 == nil) {
        printf("[-] fail to load exp: %s\n", cmdParser.expFilePathV2.UTF8String);
        goto CLEAN_RET;
    }
    
    printf("[+] build binexport model v1\n");
    moduleV1 = [[BELM_Module alloc] initWithBinExport:binExpV1];
    if (moduleV1 == nil) {
        printf("[-] build binexport model v1\n");
        goto CLEAN_RET;
    }
#if (0)
    [moduleV1 dumpFunctions];
#endif
    
    printf("[+] build binexport model v2\n");
    moduleV2 = [[BELM_Module alloc] initWithBinExport:binExpV2];
    if (moduleV2 == nil) {
        printf("[-] build binexport model v2\n");
        goto CLEAN_RET;
    }
#if (0)
    [moduleV2 dumpFunctions];
#endif
    
    printf("[+] build bindiff model\n");
    modelDiff = [[BDLM_Module alloc] initWithDB:binDiff];
    if (modelDiff == nil) {
        printf("[-] build bindiff model\n");
        goto CLEAN_RET;
    }
    
    //printf("[+] build unified model\n");
    udfModel = [[UDF_Module alloc] initWithDiff:modelDiff exportV1:moduleV1 exportV2:moduleV2];
    if (udfModel == nil) {
        printf("[-] build unified model\n");
        goto CLEAN_RET;
    }
    
    printf("\n");
    
CLEAN_RET:
    if (modelDiff) {
        printf("[+] release bindiff model\n");
        [modelDiff release];
        modelDiff = nil;
    }
    
    if (moduleV2) {
        printf("[+] release binexport model v2\n");
        [moduleV2 release];
        moduleV2 = nil;
    }
    
    if (moduleV1) {
        printf("[+] release binexport model v1\n");
        [moduleV1 release];
        moduleV1 = nil;
    }
    
    if (binExpV2) {
        printf("[+] release binexport v2\n");
        [binExpV2 release];
        binExpV2 = nil;
    }
    
    if (binExpV1) {
        printf("[+] release binexport v1\n");
        [binExpV1 release];
        binExpV1 = nil;
    }
    
    if (binDiff) {
        printf("[+] release bindiff\n");
        [binDiff release];
        binDiff = nil;
    }
    
    return udfModel;
}
