
// UDF_ActionType
UDF_ActionType_Deleted = 1;
UDF_ActionType_Added = 1 << 1;
UDF_ActionType_Changed = 1 << 2;
UDF_ActionType_Identical = 1 << 3;

// UDF_DataSelector
UDF_DataSelector_Diff = 1;
UDF_DataSelector_V1 = 2;
UDF_DataSelector_V2 = 3;

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


function InstructionFilter_BTI()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        bbChangedArray = func.getBasicBlock_Changed()
        for (const bbObj of bbChangedArray) {
            instArray_V1 = bbObj.getInstructionWithActionTypeSorted(UDF_ActionType_Deleted)
            instArray_V2 = bbObj.getInstructionWithActionTypeSorted(UDF_ActionType_Added)
            if (instArray_V1.length == 0 && instArray_V2.length == 1) {
                instObj = instArray_V2[0]
                if (instObj.getMnem(UDF_DataSelector_V2) == "BTI") {
                    func.removeBlock(bbObj)
                }
            }
        }
    }
}

function DoFilter()
{
    InstructionFilter_BTI()
}

function DoOutput()
{
    BDT_Outputer.enablePrint()
    
    // BDT_Outputer.printFunctions_Deleted(FunctionSortType_Address);
    // BDT_Outputer.printFunctions_Added(FunctionSortType_BlockEdgeCount);

    BDT_Outputer.setBlockInstructionsPrintType(BlockInstructionPrintType_All)
    BDT_Outputer.setFunctionNameOutputFlag(FunctionNameOutputFlag_Tiny)
    BDT_Outputer.printFunctions_Changed(FunctionSortType_Address);
}

// called by native
function BDT_JSEntry()
{
    DoFilter();
    DoOutput();
}