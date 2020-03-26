//
//  PSProgressiveImageCache.h
//  Expecta
//
//  Created by Jekity on 2019/8/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSProgressiveImageCache : NSObject

+ (instancetype)sharedInstance;

- (UIImage *)asyncGetBlurProgressiveImageWithKey:(NSString *)key
                                        drawSize:(CGSize)drawSize
                                    cornerRadius:(CGFloat)cornerRadius
                                    receivedData:(NSData *)receivedData
                           expectedNumberOfBytes:(int64_t)expectedNumberOfBytes
                            countOfBytesReceived:(int64_t)countOfBytesReceived;

- (void)removeProgressImageWithKey:(NSString*)key;


- (UIImage *)getCachedBlurProgressiveImageWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
