//
//  UIImageView+cacheM.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <UIKit/UIKit.h>


@interface UIImageView (CacheM)

- (void)setImageURLString:(NSString*)imageURLString;

- (void)setImageURLString:(NSString*)imageURLString
         placeHolderImage:(NSString*)imageName;

- (void)setImageURLString:(NSString*)imageURLString
         placeHolderImage:(NSString*)imageName
             cornerRadius:(CGFloat)cornerRadius;

- (void)setProgressImageURLString:(NSString*)imageURLString
                 placeHolderImage:(NSString*)imageName
                     cornerRadius:(CGFloat)cornerRadius
                         progress:(void(^)(UIImageView *imageView ,UIImage *image))progress;

@end

