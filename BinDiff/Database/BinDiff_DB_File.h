//
//  BinDiff_DB_File.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>

@interface BinDiff_DB_File : NSObject

@property(assign) int ID;
@property(retain) NSString *filename;
@property(retain) NSString *exefilename;
@property(retain) NSString *hashStr;
@property(assign) uint64_t functions;
@property(assign) uint64_t libfunctions;
@property(assign) uint64_t calls;
@property(assign) uint64_t basicblocks;
@property(assign) uint64_t edges;
@property(assign) uint64_t libedges;
@property(assign) uint64_t instructions;
@property(assign) uint64_t libinstructions;

@end
