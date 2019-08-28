//
//  PSImageCache.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>


@interface PSImageCache : NSObject

@property (nonatomic, assign) CGFloat maxCachedBytes;

+ (instancetype)sharedInstance;

- (BOOL)isImageExistWithURLString:(NSString*)imageURLString;

- (void)asyncGetImageWithURLString:(NSString*)ImageURLString
              placeHolderImageName:(NSString *)imageName
                          drawSize:(CGSize)drawSize
                   contentsGravity:(NSString* const)contentsGravity
                      cornerRadius:(CGFloat)cornerRadius
                         completed:(void (^)(NSString* key, UIImage* image))completed;

- (void)addImageWithKey:(NSString*)key
               filename:(NSString*)filename
               drawSize:(CGSize)drawSize
           cornerRadius:(CGFloat)cornerRadius
        contentsGravity:(NSString* const)contentsGravity
              completed:(void (^)(NSString* key, UIImage* image))completed;

- (void)cancelGetImageWithURLString:(NSString*)imageURLString;

- (void)cleanCacheImage;

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger totalSize))block;

@end

