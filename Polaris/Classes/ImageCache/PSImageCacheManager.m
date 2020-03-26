//
//  PSImageCacheManager.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSImageCacheManager.h"
#import "PSImageCache.h"
#import "PSImageDownloader.h"
#import "PSProgressiveImageCache.h"

@implementation PSImageCacheManager
{
    NSLock *_lock;
}
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PSImageCacheManager* __instance;
    dispatch_once(&onceToken, ^{
        __instance = [[[self class] alloc] init];
    });
    return __instance;
}
- (instancetype)init{
    if (self = [super init]) {
        _lock = [[NSLock alloc] init];
    }
    return self;
}
- (void)asyncGetProgressImageWithURLString:(NSString *)ImageURLString
                      placeHolderImageName:(NSString *)imageName
                                  drawSize:(CGSize)drawSize
                              cornerRadius:(CGFloat)cornerRadius
                           contentsGravity:(NSString *const)contentsGravity
                                 completed:(void (^)(NSString * _Nonnull, UIImage * _Nonnull))completed{
    
    PSImageCache *imageCache = [PSImageCache sharedInstance];
    if ([imageCache isImageExistWithURLString:ImageURLString]) {
        [imageCache asyncGetImageWithURLString:ImageURLString
                          placeHolderImageName:imageName
                                      drawSize:drawSize
                               contentsGravity:contentsGravity
                                  cornerRadius:cornerRadius
                                     completed:completed];
    }else{
        [self downloadProgressURLString:ImageURLString
                   placeHolderImageName:imageName
                               drawSize:drawSize cornerRadius:cornerRadius
                        contentsGravity:contentsGravity completed:completed];
    }
    
}
- (void)asyncGetImageWithURLString:(NSString *)ImageURLString
              placeHolderImageName:(NSString *)imageName
                          drawSize:(CGSize)drawSize
                      cornerRadius:(CGFloat)cornerRadius
                   contentsGravity:(NSString *const)contentsGravity
                         completed:(void (^)(NSString * _Nonnull, UIImage * _Nonnull))completed{
     PSImageCache *imageCache = [PSImageCache sharedInstance];
    if ([imageCache isImageExistWithURLString:ImageURLString]) {
        [imageCache asyncGetImageWithURLString:ImageURLString
                          placeHolderImageName:imageName
                                      drawSize:drawSize
                               contentsGravity:contentsGravity
                                  cornerRadius:cornerRadius
                                     completed:completed];
    }else{
        [self downloadOriginalURLString:ImageURLString
                   placeHolderImageName:imageName
                               drawSize:drawSize
                           cornerRadius:cornerRadius
                        contentsGravity:contentsGravity
                              completed:completed];
    }
}
- (void)downloadOriginalURLString:(NSString *)imageURLString
             placeHolderImageName:(NSString *)imageName
                         drawSize:(CGSize)drawSize
                     cornerRadius:(CGFloat)cornerRadius
                  contentsGravity:(NSString *const)contentsGravity
                        completed:(void (^)(NSString * , UIImage * ))completed
{
    if (imageURLString.length == 0) {
        return;
    }
    if (imageName.length > 0) {//clear previous image
        UIImage *placeHolderImage = [UIImage imageNamed:imageName];
        completed(imageURLString ,placeHolderImage);
    }else{
        completed(imageURLString ,nil );
    }
    PSImageDownloader *downloader = [PSImageDownloader sharedInstance];
    PSImageCache *imageCache = [PSImageCache sharedInstance];
    [downloader downloadImageForURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]] success:^(NSURLRequest * _Nonnull request, NSURL * _Nonnull filePath) {
       
        [imageCache addImageWithKey:request.URL.absoluteString
                           filename:filePath.lastPathComponent
                           drawSize:drawSize
                       cornerRadius:cornerRadius
                    contentsGravity:contentsGravity
                          completed:completed];
        
    } failed:^(NSURLRequest * _Nonnull request, NSError * _Nonnull error) {
        
    }];
}
- (void)downloadProgressURLString:(NSString *)imageURLString
             placeHolderImageName:(NSString *)imageName
                         drawSize:(CGSize)drawSize
                     cornerRadius:(CGFloat)cornerRadius
                  contentsGravity:(NSString *const)contentsGravity
                        completed:(void (^)(NSString * , UIImage * ))completed
{
    if (imageURLString.length == 0) {
        return;
    }
    [_lock lock];
    PSProgressiveImageCache *progressive = [PSProgressiveImageCache sharedInstance];
    UIImage *cacheBlurImage = [progressive getCachedBlurProgressiveImageWithKey:imageURLString];
    if (cacheBlurImage) {
        completed(imageURLString ,cacheBlurImage);
    }else{
        if (imageName.length > 0) {//clear previous image
            UIImage *placeHolderImage = [UIImage imageNamed:imageName];
            completed(imageURLString ,placeHolderImage);
        }else{
            completed(imageURLString ,nil);
        }
    }
    [_lock unlock];
    PSImageDownloader *downloader = [PSImageDownloader sharedInstance];
    PSImageCache *imageCache = [PSImageCache sharedInstance];
    [downloader downloadImageForURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]] progress:^(NSData *data, int64_t countOfBytesExpectedToReceive, int64_t countOfBytesReceived) {
        PSProgressiveImageCache *progressive = [PSProgressiveImageCache sharedInstance];
        UIImage *blurImage = [progressive asyncGetBlurProgressiveImageWithKey:imageURLString
                                                                     drawSize:drawSize
                                                                 cornerRadius:cornerRadius
                                                                 receivedData:data
                                                        expectedNumberOfBytes:countOfBytesExpectedToReceive
                                                         countOfBytesReceived:countOfBytesReceived];
        if (completed && blurImage) {
            completed(imageURLString, blurImage);
        }
    } success:^(NSURLRequest * _Nonnull request, NSURL * _Nonnull filePath) {
        PSProgressiveImageCache *progressive = [PSProgressiveImageCache sharedInstance];
        [progressive removeProgressImageWithKey:request.URL.absoluteString];
        [imageCache addImageWithKey:request.URL.absoluteString
                           filename:filePath.lastPathComponent
                           drawSize:drawSize
                       cornerRadius:cornerRadius
                    contentsGravity:contentsGravity
                          completed:completed];
    } failed:^(NSURLRequest * _Nonnull request, NSError * _Nonnull error) {
        
    }];
}
- (void)cancelGetImageWithURLString:(NSString *)ImageURLString{
    [[PSImageCache sharedInstance] cancelGetImageWithURLString:ImageURLString];
}
- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger))block{
    [[PSImageCache sharedInstance] calculateSizeWithCompletionBlock:block];;
}
- (void)clearCache{
    [[PSImageCache sharedInstance] cleanCacheImage];
}
@end
