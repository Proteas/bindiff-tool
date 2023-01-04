## Issue
When do `BinDiff`ing, most of the time, the results are noisy.

## Solution
`bindiff-tool` is an assistant for `BinDiff`, <br/>
with this tool, you can use `js` to program `BinDiff` results partially:
1. Filter `BinDiff` results.
2. Identity N-Day fixes.
3. By imagination.

## Usage
1.
```bash
bindiff-tool --v1 V1.BinExport --v2 V2.BinExport --diff V1_vs_V2.BinDiff
```

2.
```bash
bindiff-tool --v1 V1.BinExport --v2 V2.BinExport --diff V1_vs_V2.BinDiff --json Result.json
```

3.
```bash
bindiff-tool --v1 V1.BinExport --v2 V2.BinExport --diff V1_vs_V2.BinDiff --js Filter.js
```

4.
```bash
bindiff-tool --v1 V1.BinExport --v2 V2.BinExport --diff V1_vs_V2.BinDiff --js Filter.js --json Result.json
```

## JS Interface
* [UDF_Module](./BinDiffTool/UnifiedDiffResult/UDF_Module.h)
* [UDF_Function](./BinDiffTool/UnifiedDiffResult/UDF_Function.h)
* [UDF_BasicBlock](./BinDiffTool/UnifiedDiffResult/UDF_BasicBlock.h)
* [UDF_Instruction](./BinDiffTool/UnifiedDiffResult/UDF_Instruction.h)
* [BDT_Logger](./BinDiffTool/BDT_JSInterface.h)
* [BDT_ChangesCmdPrinter](./BinDiffTool/BDT_ChangesCmdPrinter.h)
* [BELM_Edge](./BinExport/BinExportLocalModel/BELM_Edge.h)

## Examples
1. [all-v1.js](./js/all-v1.js)
2. [all-v2.js](./js/all-v2.js)
3. [AppleAVD.js](./js/AppleAVD.js)
4. [common.js](./js/common.js)
5. [kernel.js](./js/kernel.js)

## Limitation
* `macOS` only. :(
