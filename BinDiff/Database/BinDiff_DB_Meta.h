//
//  BinDiff_DB_Meta.h
//  bindiff-tool
//
//  Created by Proteas on 2022/4/21.
//

#import <Foundation/Foundation.h>

@interface BinDiff_DB_Meta : NSObject

@property(retain) NSString *ver;
@property(retain) NSString *file1;
@property(retain) NSString *file2;
@property(retain) NSString *desp;
@property(retain) NSString *created;
@property(retain) NSString *modified;
@property(assign) double similarity;
@property(assign) double confidence;

@end
