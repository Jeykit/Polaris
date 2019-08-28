//
//  PSImageCacheUtils.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <UIKit/UIKit.h>

size_t FICByteAlign(size_t bytesPerRow, size_t alignment);
size_t FICByteAlignForCoreAnimation(size_t bytesPerRow);

/**
 *  Copy from FastImageCache.
 *
 *  @param rect         draw area
 *  @param cornerRadius draw cornerRadius
 *
 */
CGMutablePathRef _PSCDCreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);

/**
 *  calculate drawing bounds with original image size, target size and contentsGravity of layer.
 *
 *  @param imageSize image size
 *  @param targetSize target size
 *  @param contentsGravity layer's attribute
 */
CGRect _PSImageCalcDrawBounds(CGSize imageSize, CGSize targetSize, NSString* const contentsGravity);

typedef NS_ENUM(NSInteger, PSImageContentType) {
    PSImageContentTypeUnknown,
    PSImageContentTypeJPEG,
    PSImageContentTypePNG,
    PSImageContentTypeWebP,
    PSImageContentTypeGif,
    PSImageContentTypeTiff
    
};

@interface PSImageCacheUtils : NSObject

+ (NSString*)directoryPath;

+ (CGFloat)contentsScale;

+ (int)pageSize;

+ (PSImageContentType)contentTypeForImageData:(NSData*)data;
@end

#define dispatch_main_sync_safeM(block)                   \
if ([NSThread isMainThread]) {                       \
block();                                         \
} else {                                             \
dispatch_sync(dispatch_get_main_queue(), block); \
}

#define dispatch_main_async_safeM(block)                   \
if ([NSThread isMainThread]) {                        \
block();                                          \
} else {                                              \
dispatch_async(dispatch_get_main_queue(), block); \
}
#pragma clang diagnostic pop
