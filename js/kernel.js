
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

function IsFunctionNameStartsWithBlackKey(blackList, funcName)
{
    for (const blackStr of blackList) {
        if (funcName.startsWith(blackStr)) {
            return true
        }
    }

    return false
}

function FunctionNameFilter_kernel_Changed()
{
    blackList = ["_do_kern_dump", "_panic", "_kdp_lightweight_fault"]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsBlackKeyInFunctionName(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
    }
}

function GetCallTargetsFromBlockArray_V1(bbArray_V1)
{
    retArray = []

    for (const bbObj of bbArray_V1) {
        callTargets = bbObj.getCallTargetNames(UDF_DataSelector_V1)
        retArray.push(...callTargets)
    }

    return retArray
}

function GetCallTargetsFromBlockArray_V2(bbArray_V2)
{
    retArray = []

    for (const bbObj of bbArray_V2) {
        callTargets = bbObj.getCallTargetNames(UDF_DataSelector_V2)
        retArray.push(...callTargets)
    }

    return retArray
}

function GetCallTargetsFromInstArray_V1(instArray_V1)
{
    retArray = []

    for (const instObj of instArray_V1) {
        callTargets = instObj.getCallTargetNames(UDF_DataSelector_V1)
        retArray.push(...callTargets)
    }

    return retArray
}

function GetCallTargetsFromInstArray_V2(instArray_V2)
{
    retArray = []

    for (const instObj of instArray_V2) {
        callTargets = instObj.getCallTargetNames(UDF_DataSelector_V2)
        retArray.push(...callTargets)
    }

    return retArray
}

function InstructionFilter_kernel_Changed_kalloc_ext()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        removeFunc = false
        for (const bb of func.getBasicBlock_Changed()) {
            instArray_V2 = bb.getInstructionWithActionTypeSorted(UDF_ActionType_Identical | UDF_ActionType_Added)
            for (var idx = 0; idx < instArray_V2.length; ++idx) {
                if ((idx + 1) == instArray_V2.length) {
                    continue
                }

                instObj = instArray_V2[idx]
                disStr = instObj.getDisassembly(UDF_DataSelector_V2)

                instObjNext = instArray_V2[idx + 1]
                opStrNext = instObjNext.getJoinedOperands(UDF_DataSelector_V2)

                if ((disStr === "MOV X3, 0") && (opStrNext === "_kalloc_ext")) {
                    // BDT_Logger.printLineBlue(opStrNext)
                    removeFunc = true
                    break;
                }
                else if ((disStr === "MOV X4, 0") && (opStrNext === "_kalloc_large")) {
                    // BDT_Logger.printLineBlue(opStrNext)
                    removeFunc = true
                    break;
                }
                else if ((disStr === "MOV X5, 0") && (opStrNext === "_krealloc_ext")) {
                    // BDT_Logger.printLineBlue(opStrNext)
                    removeFunc = true
                    break;
                }
            }
        }

        if (removeFunc) {
            BDT_Model.removeFunction(func)
            continue
        }

        instArray_Del = []
        instArray_Add = []

        for (const bb of func.getBasicBlock_Changed()) {
            instArray_V1 = bb.getInstruction_Deleted()
            instArray_V2 = bb.getInstruction_Added()

            instArray_Del.push(...instArray_V1)
            instArray_Add.push(...instArray_V2)
        }

        for (const bb of func.getBasicBlock_Deleted()) {
            instArray_V1 = bb.getInstruction_Deleted()
            instArray_Del.push(...instArray_V1)
        }

        for (const bb of func.getBasicBlock_Added()) {
            instArray_V2 = bb.getInstruction_Added()
            instArray_Add.push(...instArray_V2)
        }

        callTargets_Del = GetCallTargetsFromInstArray_V1(instArray_Del)
        callTargets_Add = GetCallTargetsFromInstArray_V2(instArray_Add)
        if ((callTargets_Del.length == 0) || (callTargets_Add.length == 0)) {
            continue
        }

        // BDT_Logger.printLine(func.getName(UDF_DataSelector_V1))
        // BDT_Logger.printLineRed(callTargets_Del.toString())
        // BDT_Logger.printLineBlue(callTargets_Add.toString())
        // BDT_Logger.printLine("")

        if (callTargets_Del.includes("_kalloc_ext") && callTargets_Add.includes("_kalloc_ext")) {
            removeFunc = true
        }
        else if (callTargets_Del.includes("_kalloc_ext") && callTargets_Add.includes("_krealloc_ext")) {
            removeFunc = true
        }
        else if (callTargets_Del.includes("_krealloc_ext") && callTargets_Add.includes("_krealloc_ext")) {
            removeFunc = true
        }

        if (removeFunc) {
            BDT_Model.removeFunction(func)
            continue
        }
    }
}

function InstructionFilter_kernel_Changed_kernel_memory_allocate()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        removeFunc = false
        for (const bb of func.getBasicBlock_Changed()) {
            callTargets_V1 = bb.getCallTargetNames(UDF_DataSelector_V1)
            callTargets_V2 = bb.getCallTargetNames(UDF_DataSelector_V2)
            if (callTargets_V1.includes("_kernel_memory_allocate") && callTargets_V2.includes("_kmem_alloc_guard")) {
                removeFunc = true
            }
            else if (callTargets_V1.includes("_kmem_free") && callTargets_V2.includes("_kmem_free_guard")) {
                removeFunc = true
            }
            else if (callTargets_V1.includes("_cpu_stack_alloc") && callTargets_V2.includes("_kmem_alloc_guard")) {
                removeFunc = true
            }
        }

        if (removeFunc) {
            BDT_Model.removeFunction(func)
        }

        instArray_Del = []
        instArray_Add = []

        for (const bb of func.getBasicBlock_Changed()) {
            instArray_V1 = bb.getInstruction_Deleted()
            instArray_V2 = bb.getInstruction_Added()

            instArray_Del.push(...instArray_V1)
            instArray_Add.push(...instArray_V2)
        }

        for (const bb of func.getBasicBlock_Deleted()) {
            instArray_V1 = bb.getInstruction_Deleted()
            instArray_Del.push(...instArray_V1)
        }

        for (const bb of func.getBasicBlock_Added()) {
            instArray_V2 = bb.getInstruction_Added()
            instArray_Add.push(...instArray_V2)
        }

        callTargets_Del = GetCallTargetsFromInstArray_V1(instArray_Del)
        callTargets_Add = GetCallTargetsFromInstArray_V2(instArray_Add)
        if ((callTargets_Del.length == 0) || (callTargets_Add.length == 0)) {
            continue
        }

        // BDT_Logger.printLine(func.getName(UDF_DataSelector_V1))
        // BDT_Logger.printLineRed(callTargets_Del.toString())
        // BDT_Logger.printLineBlue(callTargets_Add.toString())
        // BDT_Logger.printLine("")

        if (callTargets_Del.includes("_kernel_memory_allocate") && callTargets_Add.includes("_kmem_alloc_guard")) {
            removeFunc = true
        }
        else if (callTargets_Del.includes("_kmem_free") && callTargets_Add.includes("_kmem_free_guard")) {
            removeFunc = true
        }
        else if (callTargets_Del.includes("_kmem_realloc") && callTargets_Add.includes("_kmem_realloc_guard")) {
            removeFunc = true
        }
        else if (callTargets_Del.includes("_kmem_free") && callTargets_Add.includes("_vm_map_remove_and_unlock")) {
            removeFunc = true
        }

        if (removeFunc) {
            BDT_Model.removeFunction(func)
            continue
        }
    }
}

function InstructionFilter_kernel_Changed_vm_map_remove_and_unlock()
{
    for (const func of BDT_Model.getFunction_Changed()) {
        removeFunc = false
        for (const bb of func.getBasicBlock_Changed()) {
            instArray_V2 = bb.getInstructionWithActionTypeSorted(UDF_ActionType_Identical | UDF_ActionType_Added)
            for (var idx = 0; idx < instArray_V2.length; ++idx) {
                if ((idx + 1) == instArray_V2.length) {
                    continue
                }

                instObj = instArray_V2[idx]
                disStr = instObj.getDisassembly(UDF_DataSelector_V2)

                instObjNext = instArray_V2[idx + 1]
                opStrNext = instObjNext.getJoinedOperands(UDF_DataSelector_V2)

                if ((disStr === "MOV X4, 0") && (opStrNext === "_vm_map_remove_and_unlock")) {
                    removeFunc = true
                    break;
                }
            }
        }

        if (removeFunc) {
            BDT_Model.removeFunction(func)
            continue
        }

        instArray_Del = []
        instArray_Add = []

        for (const bb of func.getBasicBlock_Changed()) {
            instArray_V1 = bb.getInstruction_Deleted()
            instArray_V2 = bb.getInstruction_Added()

            instArray_Del.push(...instArray_V1)
            instArray_Add.push(...instArray_V2)
        }

        for (const bb of func.getBasicBlock_Deleted()) {
            instArray_V1 = bb.getInstruction_Deleted()
            instArray_Del.push(...instArray_V1)
        }

        for (const bb of func.getBasicBlock_Added()) {
            instArray_V2 = bb.getInstruction_Added()
            instArray_Add.push(...instArray_V2)
        }

        callTargets_Del = GetCallTargetsFromInstArray_V1(instArray_Del)
        callTargets_Add = GetCallTargetsFromInstArray_V2(instArray_Add)
        if ((callTargets_Del.length == 0) || (callTargets_Add.length == 0)) {
            continue
        }

        if (callTargets_Del.includes("_vm_map_remove_and_unlock") && callTargets_Add.includes("_vm_map_remove_and_unlock")) {
            removeFunc = true
        }

        if (removeFunc) {
            BDT_Model.removeFunction(func)
            continue
        }
    }
}

function FunctionNameFilter_kernel_Changed_csfg()
{
    blackList = ["_csfg_get_"]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsFunctionNameStartsWithBlackKey(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
        else {
            // BDT_Model.removeFunction(func);
        }
    }
}

function FunctionNameFilter_kernel_Changed_zone()
{
    blackList = ["_zone", "_zalloc", "_zfree", "_get_zone_", "__zalloc_permanent", "_compute_zone_working_set_size"]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsFunctionNameStartsWithBlackKey(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
        else {
            // BDT_Model.removeFunction(func);
        }
    }
}

function FunctionNameFilter_kernel_Changed_vm()
{
    blackList = ["_vm_", "__vm", "_get_vmmap_entries", "_get_vmsubmap_entries"]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsFunctionNameStartsWithBlackKey(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
        else {
            // BDT_Model.removeFunction(func);
        }
    }
}

function FunctionNameFilter_kernel_Changed_kalloc()
{
    blackList = [
        "_kalloc", "_kfree", "_kernel_memory_allocate", 
        "_kernel_memory_populate_object_and_unlock", "_kmem_alloc_pages", "_kmem_suballoc", 
        "_krealloc_ext", "_kern_os_free_external", 
        ]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsFunctionNameStartsWithBlackKey(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
        else {
            // BDT_Model.removeFunction(func);
        }
    }
}

function FunctionNameFilter_kernel_Changed_cpp()
{
    blackList = ["::"]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsBlackKeyInFunctionName(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
        else {
            // BDT_Model.removeFunction(func);
        }
    }
}

function FunctionNameFilter_kernel_Changed_others()
{
    blackList = [
        "_hw_lock_try_nopreempt", "_lck_ticket_lock", "_memory_object_control_uiomove", 
        "_fill_procregioninfo", "_fill_vnodeinfoforaddr", "_fill_procregioninfo_onlymappedvnodes", 
        "_find_region_details", "_find_vnode_object", "_upl_commit_range", 
        "_cpm_allocate", "_hibernate_flush_queue", "_hibernate_consider_discard", 
        "_hibernate_discard_page", "_hibernate_rebuild_vm_structs", "_find_mapping_to_slide", 
        "_shared_region_pager_data_request", "_mach_make_memory_entry_internal", "_apple_protect_pager_data_request", 
        "_fourk_pager_data_request", "_nfs_buf_release", "_round_page.10963", 
        "_cluster_write_direct", "_utun_ctl_send", "_necp_application_find_policy_match_internal", 
        "_map_segment", "_pshm_mmap", "_IOLibInit", 
        "_IOFreePageable", "_kmem_range_init", 
        "_kheap_startup_init", 
        ]

    for (const func of BDT_Model.getFunction_Changed()) {
        funcName = func.getName(UDF_DataSelector_V1)
        if (IsFunctionNameStartsWithBlackKey(blackList, funcName)) {
            BDT_Model.removeFunction(func);
        }
        else {
            // BDT_Model.removeFunction(func);
        }
    }
}

function DoFilter()
{
    // CommonFunctionFilter_Deleted()
    // CommonFunctionFilter_Added()
    // CommonFunctionFilter_Identical()
    // CommonFunctionFilter_Changed()

    FunctionNameFilter_kernel_Changed()

    InstructionFilter_kernel_Changed_kalloc_ext()
    InstructionFilter_kernel_Changed_kernel_memory_allocate()
    InstructionFilter_kernel_Changed_vm_map_remove_and_unlock()

    FunctionNameFilter_kernel_Changed_csfg()
    FunctionNameFilter_kernel_Changed_zone()
    FunctionNameFilter_kernel_Changed_vm()
    FunctionNameFilter_kernel_Changed_kalloc()
    FunctionNameFilter_kernel_Changed_cpp()
    FunctionNameFilter_kernel_Changed_others()
}

function DoOutput()
{
    BDT_Outputer.enablePrint()
    
    BDT_Outputer.printFunctions_Deleted(FunctionSortType_Address);
    BDT_Outputer.printFunctions_Added(FunctionSortType_BlockEdgeCount);

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