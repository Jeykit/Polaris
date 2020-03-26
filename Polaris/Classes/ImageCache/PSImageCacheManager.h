//
//  PSImageCacheManager.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface PSImageCacheManager : NSObject

+ (instancetype)sharedInstance;

- (void)asyncGetImageWithURLString:(NSString*)ImageURLString
              placeHolderImageName:(NSString *)imageName
                          drawSize:(CGSize)drawSize
                      cornerRadius:(CGFloat)cornerRadius
                   contentsGravity:(NSString* const)contentsGravity
                         completed:(void (^)(NSString* key, UIImage* image))completed;


- (void)asyncGetProgressImageWithURLString:(NSString*)ImageURLString
                      placeHolderImageName:(NSString *)imageName
                                  drawSize:(CGSize)drawSize
                              cornerRadius:(CGFloat)cornerRadius
                           contentsGravity:(NSString* const)contentsGravity
                                 completed:(void (^)(NSString* key, UIImage* image))completed;

- (void)cancelGetImageWithURLString:(NSString*)ImageURLString;

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger totalSize))block;

- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
