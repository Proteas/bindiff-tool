
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

function CommonFunctionFilter_Deleted()
{
    for (const func of BDT_Model.getFunction_Deleted()) {
        if (func.getBELMFuncType(UDF_DataSelector_V1) != BELM_FunctionType_Normal) {
            BDT_Model.removeFunction(func);
        }

        if ((func.getBlockCount(UDF_DataSelector_V1) == 1) && (func.getEdgeCount(UDF_DataSelector_V1) == 0)) {
            BDT_Model.removeFunction(func);
        }

        if (func.getName(UDF_DataSelector_V1).includes("::~")) {
            BDT_Model.removeFunction(func);
        }
    }
}

function CommonFunctionFilter_Added()
{
    for (const func of BDT_Model.getFunction_Added()) {
        if (func.getBELMFuncType(UDF_DataSelector_V2) != BELM_FunctionType_Normal) {
            BDT_Model.removeFunction(func);
        }

        if ((func.getBlockCount(UDF_DataSelector_V2) == 1) && (func.getEdgeCount(UDF_DataSelector_V2) == 0)) {
            BDT_Model.removeFunction(func);
        }

        if (func.getName(UDF_DataSelector_V2).includes("::~")) {
            BDT_Model.removeFunction(func);
        }
    }
}

function CommonFunctionFilter_Identical()
{
    for (const func of BDT_Model.getFunction_Identical()) {
        if (func.getBELMFuncType(UDF_DataSelector_V1) != BELM_FunctionType_Normal) {
            BDT_Model.removeFunction(func);
        }

        if ((func.getBlockCount(UDF_DataSelector_V1) == 1) && (func.getEdgeCount(UDF_DataSelector_V1) == 0)) {
            BDT_Model.removeFunction(func);
        }

        if (func.getName(UDF_DataSelector_V1).includes("::~")) {
            BDT_Model.removeFunction(func);
        }
    }
}

function CommonFunctionFilter_Changed()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        if (func.getBELMFuncType(UDF_DataSelector_V1) != BELM_FunctionType_Normal) {
            BDT_Model.removeFunction(func);
        }

        if (func.getBELMFuncType(UDF_DataSelector_V2) != BELM_FunctionType_Normal) {
            BDT_Model.removeFunction(func);
        }

        if ((func.getBlockCount(UDF_DataSelector_V1) == 1) && (func.getEdgeCount(UDF_DataSelector_V1) == 0)) {
            BDT_Model.removeFunction(func);
        }

        if ((func.getBlockCount(UDF_DataSelector_V2) == 1) && (func.getEdgeCount(UDF_DataSelector_V2) == 0)) {
            BDT_Model.removeFunction(func);
        }

        if (func.getName(UDF_DataSelector_V1).includes("::~")) {
            BDT_Model.removeFunction(func);
        }

        if (func.getName(UDF_DataSelector_V2).includes("::~")) {
            BDT_Model.removeFunction(func);
        }
    }
}

function IsBlackKeyInFunctionName(blackList, funcName)
{
    for (const blackStr of blackList) {
        if (funcName.includes(blackStr)) {
            return true
        }
    }

    return false
}

function IsMnemInBlackList(blackList, mnem)
{
    for (const blackStr of blackList) {
        if (mnem === blackStr) {
            return true
        }
    }

    return false
}

function RemoveEqualBlock_DeletedAdded()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        for (const bbDel of func.getBasicBlock_Deleted()) {
            for (const bbAdd of func.getBasicBlock_Added()) {
                if (bbDel.isDeletedStrictEqualToAdded(bbAdd)) {
                    func.removeBlock(bbDel)
                    func.removeBlock(bbAdd)
                }
            }
        }
    }
}

function RemoveEqualInstruction_DeletedAdded()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        for (const bbChanged of func.getBasicBlock_Changed()) {
            for (const instDel of bbChanged.getInstruction_Deleted()) {
                for (const instAdd of bbChanged.getInstruction_Added()) {
                    if (instDel.isDeletedStrictEqualToAdded(instAdd)) {
                        bbChanged.removeInstruction(instDel)
                        bbChanged.removeInstruction(instAdd)
                    }
                }
            }
        }
    }
}

function CommonFunctionNameFilter_Changed()
{
    blackList = ["_systrace_return_setargdesc", "_systrace_entry_setargdesc"]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsBlackKeyInFunctionName(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
    }
}

function CommonFunctionCallFilter_Changed()
{
    blackList = ["_dtrace", "_PE_parse_boot_argn"]

    for (const func of BDT_Model.getFunction_Changed()) {
        for (const bbDel of func.getBasicBlock_Deleted()) {
            for (const instDel of bbDel.getInstruction_Deleted()) {
                callTargetsDel = instDel.getCallTargetNames(UDF_DataSelector_V1)
                if (callTargetsDel.length == 1) {
                    callName = callTargetsDel[0]
                    if (IsBlackKeyInFunctionName(blackList, callName)) {
                        bbDel.removeInstruction(instDel);
                    }
                }
            }
        }

        for (const bbAdd of func.getBasicBlock_Added()) {
            for (const instAdd of bbAdd.getInstruction_Added()) {
                callTargetsAdd = instAdd.getCallTargetNames(UDF_DataSelector_V2)
                if (callTargetsAdd.length == 1) {
                    callName = callTargetsAdd[0]
                    if (IsBlackKeyInFunctionName(blackList, callName)) {
                        bbAdd.removeInstruction(instAdd);
                    }
                }
            }
        }
    }
}

function DoFilter()
{
    CommonFunctionFilter_Deleted()
    CommonFunctionFilter_Added()
    CommonFunctionFilter_Identical()
    CommonFunctionFilter_Changed()

    RemoveEqualBlock_DeletedAdded()
    RemoveEqualInstruction_DeletedAdded()

    CommonFunctionNameFilter_Changed()
    CommonFunctionCallFilter_Changed()
}

function DoOutput()
{
    BDT_Outputer.printFunctions_Deleted(FunctionSortType_Address);
    BDT_Outputer.printFunctions_Added(FunctionSortType_WeaknessScore);

    BDT_Outputer.setBlockInstructionsPrintType(BlockInstructionPrintType_All)
    BDT_Outputer.printFunctions_Changed(FunctionSortType_WeaknessScore);
}

// called by native
function BDT_JSEntry()
{
    DoFilter();
    DoOutput();
}