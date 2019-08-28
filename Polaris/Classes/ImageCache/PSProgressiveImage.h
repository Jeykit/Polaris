//
//  PSProgressiveImageCache.h
//  Expecta
//
//  Created by Jekity on 2019/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSProgressiveImage : NSObject

@property (nonatomic, strong, readonly) UIImage *currentBlurImage;

- (UIImage *)getBlurProgressiveImageWithDrawSize:(CGSize)drawSize
                                    cornerRadius:(CGFloat)cornerRadius
                                            data:(NSData *)data
                           expectedNumberOfBytes:(int64_t)expectedNumberOfBytes
                            countOfBytesReceived:(int64_t)countOfBytesReceived;
@end

NS_ASSUME_NONNULL_END
