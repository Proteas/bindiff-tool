//
//  UDF_Instruction.m
//  bindiff-tool
//
//  Created by Proteas on 2022/4/26.
//

#import "UDF_Instruction.h"
#import "BDLM_Instruction.h"
#import "BELM_Instruction.h"

@interface UDF_Instruction ()
{
    //
}

//

@end

@implementation UDF_Instruction

@synthesize diff = _diff;
@synthesize exportV1 = _exportV1;
@synthesize exportV2 = _exportV2;
@synthesize backRef = _backRef;

- (instancetype)initWithType:(UDF_ActionType)actionType
                        Diff:(BDLM_Instruction *)diff
                    exportV1:(BELM_Instruction *)exportV1
                    exportV2:(BELM_Instruction *)exportV2
{
    if ((self = [super init])) {
        self.actionType = actionType;
        _diff = [diff retain];
        _exportV1 = [exportV1 retain];
        _exportV2 = [exportV2 retain];
    }
    
    return self;
}

- (void)dealloc
{
    self.backRef = nil;
    
    if (_diff) {
        [_diff release];
        _diff = nil;
    }
    
    if (_exportV1) {
        [_exportV1 release];
        _exportV1 = nil;
    }
    
    if (_exportV2) {
        [_exportV2 release];
        _exportV2 = nil;
    }
    
    [super dealloc];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    UDF_Instruction *obj2 = (UDF_Instruction *)object;
    if (self.diff && obj2.diff) {
        return (self.diff == obj2.diff);
    }
    else {
        return NO;
    }
}

- (NSComparisonResult)compareByAddrV1:(UDF_Instruction *)another
{
    if (self.exportV1.addr < another.exportV1.addr) {
        return NSOrderedAscending;
    }
    else if (self.exportV1.addr > another.exportV1.addr) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByAddrV2:(UDF_Instruction *)another
{
    if (self.exportV2.addr < another.exportV2.addr) {
        return NSOrderedAscending;
    }
    else if (self.exportV2.addr > another.exportV2.addr) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareByAddrAndDeltaV1V2:(UDF_Instruction *)another
{
    if (self.exportV1 && another.exportV1) {
        return [self compareByAddrV1:another];
    }
    else if (self.exportV2 && another.exportV2) {
        return [self compareByAddrV2:another];
    }
    else if ((self.exportV1 && (self.exportV2 == nil)) && ((another.exportV1 == nil) && another.exportV2)) {
        if (self.exportV1.deltaAddr < another.exportV2.deltaAddr) {
            return NSOrderedAscending;
        }
        else if (self.exportV1.deltaAddr > another.exportV2.deltaAddr) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }
    else {
        printf("[-] %s: situation out of control\n", __FUNCTION__);
        return NSOrderedSame;
    }
}

- (UDF_ActionType)getActionType
{
    return self.actionType;
}

- (uint64_t)getAddr:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.addr;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.addr;
    }
    else {
        return -1;
    }
}

- (NSArray *)getCallTargetAddrs:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.callTargetAddrArray;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.callTargetAddrArray;
    }
    else {
        return nil;
    }
}

- (NSArray *)getCallTargetNames:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.callTargetNameArray;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.callTargetNameArray;
    }
    else {
        return nil;
    }
}

- (NSString *)getDisassembly:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return [self.exportV1 getDisassembly];
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return [self.exportV2 getDisassembly];
    }
    else {
        return nil;
    }
}

- (NSString *)getMnem:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return self.exportV1.mnem;
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return self.exportV2.mnem;
    }
    else {
        return nil;
    }
}

- (NSString *)getJoinedOperands:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return [self.exportV1 getJoinedOperands];
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return [self.exportV2 getJoinedOperands];
    }
    else {
        return nil;
    }
}

- (NSArray *)getOperandsArray:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_V1) {
        return [self.exportV1 getOperandsArray];
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return [self.exportV2 getOperandsArray];
    }
    else {
        return nil;
    }
}

- (BOOL)isDeletedStrictEqualToAdded:(UDF_Instruction *)instAdded
{
    NSString *disSelf = [self getDisassembly:UDF_DataSelector_V1];
    NSString *disAdded = [instAdded getDisassembly:UDF_DataSelector_V2];
    
    return [disSelf isEqualToString:disAdded];
}

- (BOOL)hasData:(UDF_DataSelector)dataSel
{
    if (dataSel == UDF_DataSelector_Diff) {
        return (self.diff != nil);
    }
    else if (dataSel == UDF_DataSelector_V1) {
        return (self.exportV1 != nil);
    }
    else if (dataSel == UDF_DataSelector_V2) {
        return (self.exportV2 != nil);
    }
    else {
        return NO;
    }
}

- (void)manualSetActionType:(UDF_ActionType)actionType
{
    self.actionType = actionType | UDF_ActionType_ManualSet;
}

@end
