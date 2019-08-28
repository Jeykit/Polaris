//
//  PSImageDataFileManager.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>
#import "PSImageDataFile.h"


@interface PSImageDataFileManager : NSObject
@property (nonatomic, strong, readonly) NSString* folderPath; // folder saved data files.

- (instancetype)initWithFolderPath:(NSString*)folderPath;

- (PSImageDataFile*)createFileWithName:(NSString*)name;

- (BOOL)isFileExistWithName:(NSString*)name;

- (PSImageDataFile*)retrieveFileWithName:(NSString*)name;

- (void)removeFileWithName:(NSString*)name;

- (void)addExistFileName:(NSString*)name;

- (void)asyncCreateFileWithName:(NSString*)name
                      completed:(void (^)(PSImageDataFile* dataFile))completed;

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))block;

- (void)purgeWithExceptions:(NSArray*)names
                     toSize:(NSUInteger)toSize
                  completed:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completed;
@end

