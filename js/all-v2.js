
// UDF_ActionType
UDF_ActionType_Deleted = 1;
UDF_ActionType_Added = 1 << 1;
UDF_ActionType_Changed = 1 << 2;
UDF_ActionType_Identical = 1 << 3;

// UDF_DataSelector
UDF_DataSelector_Diff = 1;
UDF_DataSelector_V1 = 2;
UDF_DataSelector_V2 = 3;

// BELM_FunctionType
BELM_FunctionType_Normal = 0;
BELM_FunctionType_Library = 1;
BELM_FunctionType_Imported = 2;
BELM_FunctionType_Thunk = 3;
BELM_FunctionType_Invalid = 4;

// BELM_EdgeType
BELM_EdgeType_ConditionTrue = 1;
BELM_EdgeType_ConditionFalse = 2;
BELM_EdgeType_Unconditional = 3;
BELM_EdgeType_Switch = 4;

// FunctionSortType
FunctionSortType_Address = 1;
FunctionSortType_BlockEdgeCount = 2;
FunctionSortType_InstructionBlockEdgeCount = 3;
FunctionSortType_WeaknessScore = 4;

// BlockInstructionPrintType
BlockInstructionPrintType_All = 1;
BlockInstructionPrintType_Changed = 2;

// FunctionNameOutputFlag
FunctionNameOutputFlag_Full = 1;
FunctionNameOutputFlag_Tiny = 2;

function CommonFunctionFilter_V2(funcArray)
{
    retArray = []
    for (const func of funcArray) {
        if (func.getBELMFuncType(UDF_DataSelector_V2) != BELM_FunctionType_Normal) {
            continue
        }

        if ((func.getBlockCount(UDF_DataSelector_V2) == 1) && (func.getEdgeCount(UDF_DataSelector_V2) == 0)) {
            continue
        }

        if (func.getName(UDF_DataSelector_V2).includes("::~")) {
            continue
        }

        retArray.push(func)
    }

    return retArray
}

function OutputAll_V2()
{
    funcArray = BDT_Model.getFunction_WithActionMask(UDF_ActionType_Added | UDF_ActionType_Changed | UDF_ActionType_Identical)
    funcArray = CommonFunctionFilter_V2(funcArray)

    // BDT_Outputer.setFunctionNameOutputFlag(FunctionNameOutputFlag_Tiny)
    BDT_Outputer.printFunctionsSummaryV2SortType(funcArray, FunctionSortType_WeaknessScore)
}

// called by native
function BDT_JSEntry()
{
    OutputAll_V2();
}
