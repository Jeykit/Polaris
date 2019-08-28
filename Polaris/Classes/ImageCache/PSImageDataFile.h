//
//  PSImageDataFile.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSImageDataFile : NSObject
@property (nonatomic, assign, readonly) void* address;
@property (nonatomic, assign, readonly) off_t fileLength; // total length of the file.
@property (nonatomic, copy ,readonly) NSString *filePath;
- (instancetype)initWithPath:(NSString*)path;

- (BOOL)open;

- (void)close;
@end

NS_ASSUME_NONNULL_END
