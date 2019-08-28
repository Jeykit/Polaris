//
//  PSProgressiveImageCache.m
//  Expecta
//
//  Created by Jekity on 2019/8/27.
//

#import "PSProgressiveImage.h"
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>
#import "PSImageCacheUtils.h"

@interface PSProgressiveImage()
@property (nonatomic, assign) NSUInteger scannedByte;
@property (atomic, copy) NSArray *progressThresholds;
@property (nonatomic, assign) NSInteger sosCount;
@property (nonatomic, assign) NSUInteger currentThreshold;
@property (nonatomic, assign) CGImageSourceRef imageSource;
@end
@implementation PSProgressiveImage
{
    NSLock *_lock;
}
- (instancetype)init{
    if (self = [super init]) {
        _scannedByte = 0;
        _progressThresholds = @[@0.00, @0.35, @0.65];
        _lock = [[NSLock alloc] init];
        _currentThreshold = 0;
        _imageSource = CGImageSourceCreateIncremental(NULL);
        _currentBlurImage = nil;
       
    }
    return self;
}

- (void)updateProgressiveImageWithData:(NSData *)data imageSource:(CGImageSourceRef)imageSource{
     while ([self l_hasCompletedFirstScan] == NO && self.scannedByte < data.length) {
         NSUInteger startByte = _scannedByte;
         if (startByte > 0) {
             startByte--;
         }
         if ([self l_scanForSOSinData:data startByte:startByte scannedByte:&_scannedByte]) {
             self.sosCount++;
         }
         if (imageSource) {
             CGImageSourceUpdateData(imageSource, (CFDataRef)data, NO);
         }
     }
    
}
- (UIImage *)getBlurProgressiveImageWithDrawSize:(CGSize)drawSize
                                    cornerRadius:(CGFloat)cornerRadius
                                            data:(NSData *)data
                           expectedNumberOfBytes:(int64_t)expectedNumberOfBytes
                            countOfBytesReceived:(int64_t)countOfBytesReceived
{
    [_lock lock];
    [self updateProgressiveImageWithData:data imageSource:_imageSource];
    if (self.imageSource == nil) {
        _currentBlurImage = nil;
        [_lock unlock];
        return nil;
    }
    if (self.currentThreshold == _progressThresholds.count) {
        [_lock unlock];
        return nil;
    }
    if ([self l_hasCompletedFirstScan] == NO) {
        [_lock unlock];
        return nil;
    }
    UIImage *currentImage = nil;
    @autoreleasepool{
        //Size information comes after JFIF so jpeg properties should be available at or before size?
        //attempt to get size info
        CFDictionaryRef dictionaryRef = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        NSDictionary *imageProperties = (__bridge NSDictionary *)dictionaryRef;
        CGSize size = drawSize;
        if (size.width <= 0 && imageProperties[(NSString *)kCGImagePropertyPixelWidth]) {
            size.width = [imageProperties[(NSString *)kCGImagePropertyPixelWidth] floatValue];
        }
        
        if (size.height <= 0 && imageProperties[(NSString *)kCGImagePropertyPixelHeight]) {
            size.height = [imageProperties[(NSString *)kCGImagePropertyPixelHeight] floatValue];
        }
  
        NSDictionary *jpegProperties = imageProperties[(NSString *)kCGImagePropertyJFIFDictionary];
        NSNumber *isProgressive = jpegProperties[(NSString *)kCGImagePropertyJFIFIsProgressive];
        BOOL isProgressiveJPEG = jpegProperties && [isProgressive boolValue];
        
        CFRelease(dictionaryRef);
        
        float progress = 0;
        if (expectedNumberOfBytes > 0) {
            progress = countOfBytesReceived / (float)expectedNumberOfBytes;
        }
        //    Don't bother if we're basically done
        if (progress >= 0.99) {
            [_lock unlock];
            return nil;
        }
        if (isProgressiveJPEG && size.width > 0 && size.height > 0 && progress > [_progressThresholds[self.currentThreshold] floatValue] ) {
            while (self.currentThreshold < _progressThresholds.count && progress > [_progressThresholds[self.currentThreshold] floatValue]) {
                self.currentThreshold++;
            }
            CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
            if (image) {
                currentImage = [self l_postProcessImage:[UIImage imageWithCGImage:image] withProgress:progress];
                CGFloat contentsScale = [PSImageCacheUtils contentsScale];
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
                [currentImage drawInRect: CGRectMake(0, 0, drawSize.width,drawSize.height)];
                //6.获取图片
                currentImage = UIGraphicsGetImageFromCurrentImageContext();
                //7.关闭图形上下文
                UIGraphicsEndImageContext();
            }
            CGImageRelease(image);
        }
    }
    [_lock unlock];
    _currentBlurImage = currentImage;
    return currentImage;
}
- (BOOL)l_scanForSOSinData:(NSData *)data startByte:(NSUInteger)startByte scannedByte:(NSUInteger *)scannedByte
{
    //check if we have a complete scan
    Byte scanMarker[2];
    //SOS marker
    scanMarker[0] = 0xFF;
    scanMarker[1] = 0xDA;
    
    //scan one byte back in case we only got half the SOS on the last data append
    NSRange scanRange;
    scanRange.location = startByte;
    scanRange.length = data.length - scanRange.location;
    NSRange sosRange = [data rangeOfData:[NSData dataWithBytes:scanMarker length:2] options:0 range:scanRange];
    if (sosRange.location != NSNotFound) {
        if (scannedByte) {
            *scannedByte = NSMaxRange(sosRange);
        }
        return YES;
    }
    if (scannedByte) {
        *scannedByte = NSMaxRange(scanRange);
    }
    return NO;
}

- (BOOL)l_hasCompletedFirstScan
{
    return self.sosCount >= 2;
}

//Heavily cribbed from https://developer.apple.com/library/ios/samplecode/UIImageEffects/Listings/UIImageEffects_UIImageEffects_m.html#//apple_ref/doc/uid/DTS40013396-UIImageEffects_UIImageEffects_m-DontLinkElementID_9
- (UIImage *)l_postProcessImage:(UIImage *)inputImage withProgress:(float)progress
{
    UIImage *outputImage = nil;
    CGImageRef inputImageRef = CGImageRetain(inputImage.CGImage);
    if (inputImageRef == nil) {
        return nil;
    }
    
    CGSize inputSize = inputImage.size;
    if (inputSize.width < 1 ||
        inputSize.height < 1) {
        CGImageRelease(inputImageRef);
        return nil;
    }
    CGFloat imageScale = inputImage.scale;
    
    CGFloat radius = (inputImage.size.width / 25.0) * MAX(0, 1.0 - progress);
    radius *= imageScale;
    
    //we'll round the radius to a whole number below anyway,
    if (radius < FLT_EPSILON) {
        CGImageRelease(inputImageRef);
        return inputImage;
    }
    
    CGContextRef ctx;
    UIGraphicsBeginImageContextWithOptions(inputSize, YES, imageScale);
    ctx = UIGraphicsGetCurrentContext();
    
    
    if (ctx) {
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextTranslateCTM(ctx, 0, -inputSize.height);
        
        vImage_Buffer effectInBuffer;
        vImage_Buffer scratchBuffer;
        
        vImage_Buffer *inputBuffer;
        vImage_Buffer *outputBuffer;
        
        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel = 32,
            .colorSpace = NULL,
            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
            // requests a BGRA buffer.
            .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
            .version = 0,
            .decode = NULL,
            .renderingIntent = kCGRenderingIntentDefault
        };
        
        vImage_Error e = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, NULL, inputImage.CGImage, kvImagePrintDiagnosticsToConsole);
        if (e == kvImageNoError)
        {
            e = vImageBuffer_Init(&scratchBuffer, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
            if (e == kvImageNoError) {
                inputBuffer = &effectInBuffer;
                outputBuffer = &scratchBuffer;
                
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                if (radius - 2. < __FLT_EPSILON__)
                    radius = 2.;
                uint32_t wholeRadius = floor((radius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
                
                wholeRadius |= 1; // force wholeRadius to be odd so that the three box-blur methodology works.
                
                //calculate the size necessary for vImageBoxConvolve_ARGB8888, this does not actually do any operations.
                NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, wholeRadius, wholeRadius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
                void *tempBuffer = malloc(tempBufferSize);
                
                if (tempBuffer) {
                    //errors can be ignored because we've passed in allocated memory
                    vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, wholeRadius, wholeRadius, NULL, kvImageEdgeExtend);
                    vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, wholeRadius, wholeRadius, NULL, kvImageEdgeExtend);
                    vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, wholeRadius, wholeRadius, NULL, kvImageEdgeExtend);
                    
                    free(tempBuffer);
                    
                    //switch input and output
                    vImage_Buffer *temp = inputBuffer;
                    inputBuffer = outputBuffer;
                    outputBuffer = temp;
                    
                    CGImageRef effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &cleanupBuffer, NULL, kvImageNoAllocate, NULL);
                    if (effectCGImage == NULL) {
                        //if creating the cgimage failed, the cleanup buffer on input buffer will not be called, we must dealloc ourselves
                        free(inputBuffer->data);
                    } else {
                        // draw effect image
                        CGContextSaveGState(ctx);
                        CGContextDrawImage(ctx, CGRectMake(0, 0, inputSize.width, inputSize.height), effectCGImage);
                        CGContextRestoreGState(ctx);
                        CGImageRelease(effectCGImage);
                    }
                    // Cleanup
                    free(outputBuffer->data);
                    
                    outputImage = UIGraphicsGetImageFromCurrentImageContext();
                    
                }
            } else {
                if (scratchBuffer.data) {
                    free(scratchBuffer.data);
                }
                free(effectInBuffer.data);
            }
        } else {
            if (effectInBuffer.data) {
                free(effectInBuffer.data);
            }
        }
    }
    CGImageRelease(inputImageRef);
    return outputImage;
}
static void cleanupBuffer(void *userData, void *buf_data)
{
    free(buf_data);
}
- (void)dealloc{
    if (_imageSource) {
        CFRelease(_imageSource);
    }
}
@end
