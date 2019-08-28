//
//  UIImageView+cacheM.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "UIImageView+CacheM.h"
#import "PSImageCacheManager.h"
#import <objc/message.h>

@implementation UIImageView (CacheM)
- (void)setImageURLString:(NSString *)imageURLString{
    [self setImageURLString:imageURLString placeHolderImage:nil];
}
- (void)setImageURLString:(NSString *)imageURLString
         placeHolderImage:(NSString *)imageName{
    [self setImageURLString:imageURLString placeHolderImage:imageName cornerRadius:0];
}
- (void)setImageURLString:(NSString *)imageURLString
         placeHolderImage:(NSString *)imageName
             cornerRadius:(CGFloat)cornerRadius{
     NSParameterAssert(imageURLString != nil);
    objc_setAssociatedObject(self, @selector(setImageURLString:), imageURLString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    __weak typeof(self)weakSelf = self;
    [[PSImageCacheManager sharedInstance] asyncGetImageWithURLString:imageURLString
                                                placeHolderImageName:imageName
                                                            drawSize:self.bounds.size
                                                        cornerRadius:cornerRadius
                                                     contentsGravity:self.layer.contentsGravity
                                                           completed:^(NSString * _Nonnull key, UIImage * _Nonnull image) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString* renderer = objc_getAssociatedObject(self, @selector(setImageURLString:));
        if (renderer && [renderer isEqualToString:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                [self setNeedsDisplay];
            });
            
        }
    }];
}
- (void)setProgressImageURLString:(NSString *)imageURLString
                 placeHolderImage:(NSString *)imageName
                     cornerRadius:(CGFloat)cornerRadius
                         progress:(void (^)(UIImageView *, UIImage *))progress{
    objc_setAssociatedObject(self, @selector(setProgressImageURLString:placeHolderImage:cornerRadius:progress:), imageURLString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    __weak typeof(self)weakSelf = self;
    [[PSImageCacheManager sharedInstance] asyncGetProgressImageWithURLString:imageURLString
                                                        placeHolderImageName:imageName
                                                                    drawSize:self.bounds.size
                                                                cornerRadius:cornerRadius
                                                             contentsGravity:self.layer.contentsGravity
                                                                   completed:^(NSString * _Nonnull key, UIImage * _Nonnull image) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString* renderer = objc_getAssociatedObject(self, @selector(setProgressImageURLString:placeHolderImage:cornerRadius:progress:));
        if (renderer && [renderer isEqualToString:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                [self setNeedsDisplay];
                if (progress) {
                    progress(self, image);
                }
            });
            
        }
    }];
}
@end
