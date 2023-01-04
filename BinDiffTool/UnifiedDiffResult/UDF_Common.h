//
//  UDF_Common.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/25.
//

#import <Foundation/Foundation.h>

/*
 BDLM: BinDiff Local Model
 BELM: BinExport Local Model
  UDF: Unified Diff Result
 */

// https://gist.github.com/RabaDabaDoba/145049536f815903c79944599c6f952a
// https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#define COLOR_RESET "\e[0m"

#define COLOR_RED   "\e[0;31m"
#define COLOR_GRN   "\e[0;32m"
#define COLOR_BLU   "\e[0;34m"

#define COLOR_HRED  "\e[0;91m"
#define COLOR_HGRN  "\e[0;92m"
#define COLOR_HBLU  "\e[0;94m"
#define COLOR_HMAG  "\e[0;95m"

#define COLOR_LRED  "\e[1;31m"
#define COLOR_LGRN  "\e[1;32m"
#define COLOR_LBLU  "\e[1;34m"

typedef enum _UDF_ActionType {
    UDF_ActionType_Deleted = 1 << 0,
    UDF_ActionType_Added = 1 << 1,
    UDF_ActionType_Changed = 1 << 2,
    UDF_ActionType_Identical = 1 << 3,
    
    UDF_ActionType_ManualSet = 1 << 24,
    UDF_ActionType_ActionMask = ~UDF_ActionType_ManualSet,
} UDF_ActionType;

typedef enum _UDF_DataSelector {
    UDF_DataSelector_Diff = 1,
    UDF_DataSelector_V1 = 2,
    UDF_DataSelector_V2 = 3,
} UDF_DataSelector;

#define JS_UINT64_DELTA (0x3A8)
