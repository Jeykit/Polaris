//
//  PSImageDecoder.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSImageDecoder.h"

static void __ReleaseAsset(void* info, const void* data, size_t size)
{
    if (info != NULL) {
        CFRelease(info); // will cause dealloc of ImageDataFile
    }
}
@implementation PSImageDecoder

- (UIImage *)imageWithFile:(void *)file
               contentType:(PSImageContentType)contentType
                     bytes:(void *)bytes//文件内存地址
                    length:(size_t)length
                  drawSize:(CGSize)drawSize
           contentsGravity:(NSString *const)contentsGravity
              cornerRadius:(CGFloat)cornerRadius{
    if (contentType == PSImageContentTypeGif) {
         NSData *data = [NSData dataWithBytes:bytes length:length];
         return [self animatedGIFWithData:data];
    }
    CGImageRef imageRef = [self imageRefWithFile:file contentType:contentType bytes:bytes length:length];
    if (imageRef == nil) {
        return nil;
    }
    @autoreleasepool{
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        CGFloat contentsScale = 1;
        if (drawSize.width < imageSize.width && drawSize.height < imageSize.height) {
            contentsScale = [PSImageCacheUtils contentsScale];
        }
        UIImage* decompressedImage = [UIImage imageWithCGImage:imageRef
                                                         scale:contentsScale
                                      
                                                   orientation:UIImageOrientationUp];
        //1.开启图片图形上下文:注意设置透明度为非透明
        UIGraphicsBeginImageContextWithOptions( drawSize, NO, contentsScale);
        
        //2.开启图形上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        // Clip to a rounded rect
        if (cornerRadius > 0) {
            CGPathRef path = _PSCDCreateRoundedRectPath(CGRectMake(0, 0, drawSize.width, drawSize.height), cornerRadius);
            CGContextAddPath(context, path);
            CFRelease(path);
            CGContextEOClip(context);
            
        }
        [decompressedImage drawInRect: CGRectMake(0, 0, drawSize.width,drawSize.height)];
        //6.获取图片
        decompressedImage = UIGraphicsGetImageFromCurrentImageContext();
        //7.关闭图形上下文
        UIGraphicsEndImageContext();
        
        CGImageRelease(imageRef);
        
        return decompressedImage;
    }
}
- (CGImageRef)imageRefWithFile:(void*)file
                   contentType:(PSImageContentType)contentType
                         bytes:(void*)bytes
                        length:(size_t)length
{
    if (contentType == PSImageContentTypeUnknown || contentType == PSImageContentTypeGif || contentType == PSImageContentTypeTiff) {
        return nil;
    }
    // Create CGImageRef whose backing store *is* the mapped image table entry. We avoid a memcpy this way.
    CGImageRef imageRef = nil;
    CGDataProviderRef dataProvider = nil;
    if (contentType == PSImageContentTypeJPEG) {
        CFRetain(file);
        dataProvider = CGDataProviderCreateWithData(file, bytes, length, __ReleaseAsset);
        imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, YES, kCGRenderingIntentDefault);
        
    } else if (contentType == PSImageContentTypePNG) {
        CFRetain(file);
        dataProvider = CGDataProviderCreateWithData(file, bytes, length, __ReleaseAsset);
        imageRef = CGImageCreateWithPNGDataProvider(dataProvider, NULL, YES, kCGRenderingIntentDefault);
    }
    if (dataProvider != nil) {
        CGDataProviderRelease(dataProvider);
    }
    return imageRef;
}
- (UIImage *)animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        NSUInteger duration = 0.0f;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += [self frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            CGImageRelease(image);
        }
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}
- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    if (!cfFrameProperties) {
        return frameDuration;
    }
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}
@end
