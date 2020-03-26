//
//  PSProgressiveImageCache.m
//  Expecta
//
//  Created by Jekity on 2019/8/28.
//

#import "PSProgressiveImageCache.h"
#import "PSProgressiveImage.h"

@implementation PSProgressiveImageCache
{
    NSMutableDictionary *_progressiveImages;
    NSLock* _lock;
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static PSProgressiveImageCache* __instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [[[self class] alloc] init];
    });
    
    return __instance;
}
- (instancetype)init{
    if (self = [super init]) {
        _progressiveImages = [NSMutableDictionary dictionaryWithCapacity:100];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (UIImage *)asyncGetBlurProgressiveImageWithKey:(NSString *)key
                                        drawSize:(CGSize)drawSize
                                    cornerRadius:(CGFloat)cornerRadius
                                    receivedData:(NSData *)receivedData
                           expectedNumberOfBytes:(int64_t)expectedNumberOfBytes
                            countOfBytesReceived:(int64_t)countOfBytesReceived{
    
    if ([self isImageExistWithKey:key]) {
        UIImage *blurImage = [self getProgressiveImageWithKey:key
                                                     drawSize:drawSize
                                                 cornerRadius:cornerRadius
                                                 receivedData:receivedData
                                        expectedNumberOfBytes:expectedNumberOfBytes
                                         countOfBytesReceived:countOfBytesReceived];
        return blurImage;
    }
    UIImage *blurImage = [self addProgressiveImageWithKey:key
                                                 drawSize:drawSize
                                             cornerRadius:cornerRadius
                                                     data:receivedData
                                    expectedNumberOfBytes:expectedNumberOfBytes
                                     countOfBytesReceived:countOfBytesReceived];
    return blurImage;
    
}
- (UIImage *)getProgressiveImageWithKey:(NSString *)key
                               drawSize:(CGSize)drawSize
                           cornerRadius:(CGFloat)cornerRadius
                           receivedData:(NSData *)receivedData
                  expectedNumberOfBytes:(int64_t)expectedNumberOfBytes
                   countOfBytesReceived:(int64_t)countOfBytesReceived
{
    NSArray *progressiveArray = nil;
    @synchronized(_progressiveImages)
    {
        progressiveArray = [_progressiveImages objectForKey:key];
    }
    if (progressiveArray.count == 0) {
        return nil;
    }
    PSProgressiveImage *progressive = [progressiveArray firstObject];
    UIImage *blurImage = [progressive getBlurProgressiveImageWithDrawSize:drawSize
                                                             cornerRadius:cornerRadius
                                                                     data:receivedData
                                                    expectedNumberOfBytes:expectedNumberOfBytes
                                                     countOfBytesReceived:countOfBytesReceived];
    return blurImage;
}
- (UIImage *)addProgressiveImageWithKey:(NSString *)key
                          drawSize:(CGSize)drawSize
                      cornerRadius:(CGFloat)cornerRadius
                              data:(NSData *)data
             expectedNumberOfBytes:(int64_t)expectedNumberOfBytes
              countOfBytesReceived:(int64_t)countOfBytesReceived;
{
    [_lock lock];
    PSProgressiveImage *progressive = [[PSProgressiveImage alloc] init];
    UIImage *blurImage = [progressive getBlurProgressiveImageWithDrawSize:drawSize
                                                             cornerRadius:cornerRadius
                                                                     data:data
                                                    expectedNumberOfBytes:expectedNumberOfBytes
                                                     countOfBytesReceived:countOfBytesReceived];
    if (blurImage) {
        _progressiveImages[key] = @[progressive];
    }else{
        _progressiveImages[key] = @[];
    }
    [_lock unlock];
    return blurImage;
}
- (BOOL)isImageExistWithKey:(NSString*)key;
{
    NSParameterAssert(key != nil);
    @synchronized(_progressiveImages)
    {
        NSArray *progressiveArray = [_progressiveImages objectForKey:key];
        return (progressiveArray.count > 0);
    }
}
- (void)removeProgressImageWithKey:(NSString *)key{
     NSParameterAssert(key != nil);
    @synchronized(_progressiveImages)
    {
       [_progressiveImages removeObjectForKey:key];
    }
}
- (UIImage *)getCachedBlurProgressiveImageWithKey:(NSString *)key{
    if ([self isImageExistWithKey:key]) {
        NSArray *progressiveArray = nil;
        @synchronized(_progressiveImages)
        {
            progressiveArray = [_progressiveImages objectForKey:key];
        }
        if (progressiveArray.count == 0) {
            return nil;
        }
        PSProgressiveImage *progressive = [progressiveArray firstObject];
        return progressive.currentBlurImage;
    }
    return nil;
}
@end
