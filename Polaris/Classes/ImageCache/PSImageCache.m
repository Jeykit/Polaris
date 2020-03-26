//
//  PSImageCache.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSImageCache.h"
#import "PSImageDataFileManager.h"
#import "PSImageRetrieveOperation.h"
#import "PSImageDecoder.h"
#import "PSImageCacheUtils.h"
#import <objc/message.h>

#define kImageInfoIndexFileName 0
#define kImageInfoIndexContentType 1
#define kImageInfoIndexWidth 2
#define kImageInfoIndexHeight 3
#define kImageInfoIndexLock 4


static void _transactionGroupRunLoopObserverCallbackM(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

@interface PSImageCache ()
@property (nonatomic,strong) PSImageDecoder *decoder;
@property (nonatomic, strong) PSImageDataFileManager* dataFileManager;
@property (nonatomic, assign) BOOL needToSavedFile;
@end
@implementation PSImageCache
{
    NSLock* _lock;
    NSString* _metaPath;
    
    NSMutableDictionary* _images;
    NSMutableDictionary* _addingImages;
    NSOperationQueue* _retrievingQueue;
}
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static PSImageCache* __instance = nil;
    dispatch_once(&onceToken, ^{
        NSString *metaPath = [[PSImageCacheUtils directoryPath] stringByAppendingPathComponent:@"/__images"];
        __instance = [[[self class] alloc] initWithMetaPath:metaPath];
    });
    
    return __instance;
}
- (instancetype)initWithMetaPath:(NSString*)metaPath
{
    if (self = [super init]) {
        //注册Runloop
        [self registerTransactionGroupAsMainRunloopObserver];
        
        _needToSavedFile = NO;
        _lock = [[NSLock alloc] init];
        _addingImages = [[NSMutableDictionary alloc] init];
        _maxCachedBytes = 1024 * 1024 * 512;
        _retrievingQueue = [NSOperationQueue new];
        _retrievingQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        _retrievingQueue.maxConcurrentOperationCount = 6;

        _metaPath = [metaPath copy];
        NSString* folderPath = [[_metaPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"/files"];
        self.dataFileManager = [[PSImageDataFileManager alloc] initWithFolderPath:folderPath];
        
        _metaPath = [metaPath copy];
        _decoder = [[PSImageDecoder alloc] init];
        
        [self loadMetadata];
        
    }
    return self;
}
- (void)loadMetadata
{
    // load content from index file
    NSError* error;
    NSData* metadataData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_metaPath] options:NSDataReadingMappedAlways error:&error];
    if (error != nil || metadataData == nil) {
        [self createMetadata];
        return;
    }
    
    NSDictionary* parsedObject = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:metadataData options:kNilOptions error:&error];
    if (error != nil || parsedObject == nil) {
        [self createMetadata];
        return;
    }
    _images = [NSMutableDictionary dictionaryWithDictionary:parsedObject];
}

- (void)createMetadata
{
    _images = [NSMutableDictionary dictionary];
}
- (void)dealloc
{
    [_retrievingQueue cancelAllOperations];
}
- (void)addImageWithKey:(NSString *)key
               filename:(NSString *)filename
               drawSize:(CGSize)drawSize
           cornerRadius:(CGFloat)cornerRadius
        contentsGravity:(NSString *const)contentsGravity
              completed:(void (^)(NSString * _Nonnull, UIImage * _Nonnull))completed{
    [self doAddImageWithKey:key
                   filename:filename
                   drawSize:drawSize
            contentsGravity:contentsGravity
               cornerRadius:cornerRadius
                  completed:completed];
    
}
- (void)doAddImageWithKey:(NSString*)key
                 filename:(NSString*)filename
                 drawSize:(CGSize)drawSize
          contentsGravity:(NSString* const)contentsGravity
             cornerRadius:(CGFloat)cornerRadius
                completed:(void (^)(NSString * _Nonnull, UIImage * _Nonnull))completed
{
    NSParameterAssert(key != nil);
    NSParameterAssert(filename != nil);
    
    if ([self isImageExistWithURLString:key] && completed != nil) {
        [self asyncGetImageWithURLString:key
                    placeHolderImageName:nil
                                drawSize:drawSize
                         contentsGravity:contentsGravity
                            cornerRadius:cornerRadius
                               completed:completed];
        return;
    }
    // ignore draw size when add images
    @synchronized(_addingImages)
    {
        if ([_addingImages objectForKey:key] == nil) {
            NSMutableArray* blocks = [NSMutableArray array];
            if (completed != nil) {
                [blocks addObject:completed];
            }
            
            [_addingImages setObject:blocks forKey:key];
        } else {
            // waiting for drawing
            NSMutableArray* blocks = [_addingImages objectForKey:key];
            if (completed != nil) {
                [blocks addObject:completed];
            }
            return;
        }
    }
    [self doAddImageWithKey:[key copy]
                   filename:[filename copy]
                   drawSize:drawSize
            contentsGravity:contentsGravity
               cornerRadius:cornerRadius];
}
- (void)doAddImageWithKey:(NSString*)key
                 filename:(NSString*)filename
                 drawSize:(CGSize)drawSize
          contentsGravity:(NSString* const)contentsGravity
             cornerRadius:(CGFloat)cornerRadius{
    
    static dispatch_queue_t __drawingQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = [NSString stringWithFormat:@"com.imagecache.addimage.%@", [[NSUUID UUID] UUIDString]];
        __drawingQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], NULL);
    });
    __weak typeof(self)weakSelf = self;
    NSMutableDictionary *images = _images;
    dispatch_async(__drawingQueue, ^{
        __strong typeof(weakSelf)self = weakSelf;
        // get image meta
        CGSize imageSize = CGSizeZero;
        PSImageContentType contentType;
        NSString *filePath = [self.dataFileManager.folderPath stringByAppendingPathComponent:filename];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        contentType = [PSImageCacheUtils contentTypeForImageData:fileData];
        [self.dataFileManager addExistFileName:filename];
        PSImageDataFile *dataFile = [self.dataFileManager retrieveFileWithName:filename];
        if ([dataFile open] == NO ) {
            [self afterAddImage:nil key:key];
            return;
        }
        void *bytes = dataFile.address;
        size_t fileLength = (size_t)dataFile.fileLength;

        // callback with image
        UIImage *decodeImage = [self.decoder imageWithFile:(__bridge void *)(dataFile)
                                               contentType:contentType
                                                     bytes:bytes
                                                    length:fileLength
                                                  drawSize:CGSizeEqualToSize(drawSize, CGSizeZero) ? imageSize : drawSize
                                           contentsGravity:contentsGravity
                                              cornerRadius:cornerRadius];
        [self afterAddImage:decodeImage key:key];
        if (decodeImage == nil) {
            return ;
        }
        @synchronized (images) {
            // path, width, height, length
            NSArray *imageInfo = @[ filename,
                                    @(contentType),
                                    @(imageSize.width),
                                    @(imageSize.height) ];
            [images setObject:imageInfo forKey:key];
        }
    });
    self.needToSavedFile = YES;
}
- (void)afterAddImage:(UIImage*)image
                  key:(NSString*)key
{
    NSArray* blocks = nil;
    @synchronized(_addingImages)
    {
        blocks = [[_addingImages objectForKey:key] copy];
        [_addingImages removeObjectForKey:key];
    }
    typedef void (^PSImageCacheRetrieveBlock)(NSString* key, UIImage* image);
    for ( PSImageCacheRetrieveBlock block in blocks) {
        block(key, image);
    }
}
- (BOOL)isImageExistWithURLString:(NSString *)imageURLString{
    NSParameterAssert(imageURLString != nil);
    @synchronized(_images)
    {
        return [_images objectForKey:imageURLString] != nil;
    }
}
- (void)asyncGetImageWithURLString:(NSString *)ImageURLString
              placeHolderImageName:(NSString *)imageName
                          drawSize:(CGSize)drawSize
                   contentsGravity:(NSString *const)contentsGravity
                      cornerRadius:(CGFloat)cornerRadius
                         completed:(void (^)(NSString *, UIImage *))completed{
    
    NSParameterAssert(ImageURLString != nil);
    NSParameterAssert(completed != nil);
    
    NSArray* imageInfo;
    @synchronized(_images)
    {
        imageInfo = [_images objectForKey:ImageURLString];
    }
    
    if (imageInfo == nil || [imageInfo count] <= kImageInfoIndexHeight) {
        completed(ImageURLString, nil);
        return ;
    }
    
    // filename, width, height, length
    NSString* filename = [imageInfo firstObject];
    PSImageDataFile* dataFile = [self.dataFileManager retrieveFileWithName:filename];
    if (dataFile == nil) {
        @synchronized(_images)
        {
            [_images removeObjectForKey:ImageURLString];
        }
        completed(ImageURLString, nil);
        return;
    }
    
    NSArray *tempArray = [_retrievingQueue.operations copy];
    for (PSImageRetrieveOperation* operation in tempArray) {
        if ([operation.name isEqualToString:ImageURLString]) {
            NSString* renderer = objc_getAssociatedObject(self,@selector(asyncGetImageWithURLString:placeHolderImageName:drawSize:contentsGravity:cornerRadius:completed:));
            CGSize innerSize = CGSizeZero;
            if (renderer) {
                innerSize = CGSizeFromString(renderer);
            }
            if (CGSizeEqualToSize(drawSize, innerSize)) {
                [operation addBlock:completed];
                return;
            }
            break ;
        }
    }
    
    CGSize imageSize = drawSize;
    if (drawSize.width == 0 && drawSize.height == 0) {
        CGFloat imageWidth = [[imageInfo objectAtIndex:kImageInfoIndexWidth] floatValue];
        CGFloat imageHeight = [[imageInfo objectAtIndex:kImageInfoIndexHeight] floatValue];
        imageSize = CGSizeMake(imageWidth, imageHeight);
    }
    objc_setAssociatedObject(self,@selector(asyncGetImageWithURLString:placeHolderImageName:drawSize:contentsGravity:cornerRadius:completed:), NSStringFromCGSize(imageSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     PSImageContentType contentType = [[imageInfo objectAtIndex:kImageInfoIndexContentType] integerValue];
    __weak __typeof__(self) weakSelf = self;
    PSImageRetrieveOperation* operation = [[PSImageRetrieveOperation alloc] initWithRetrieveBlock:^UIImage * {
        if ( [dataFile open] == NO) {
            return nil;
        }
        return [weakSelf.decoder imageWithFile:(__bridge void *)(dataFile)
                                   contentType:contentType
                                         bytes:dataFile.address
                                        length:(size_t)dataFile.fileLength
                                      drawSize:CGSizeEqualToSize(drawSize, CGSizeZero) ? imageSize : drawSize
                               contentsGravity:contentsGravity
                                  cornerRadius:cornerRadius];
    }];
    operation.name = ImageURLString;
    [operation addBlock:completed];
    [_retrievingQueue addOperation:operation];
}
- (void)saveMetadata
{
    if (_images.allKeys.count == 0) {
        return ;
    }
    static dispatch_queue_t __metadataQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = [NSString stringWithFormat:@"com.imagecache.metadata.%@", [[NSUUID UUID] UUIDString]];
        __metadataQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], NULL);
    });
    NSLock *lock = _lock;
    NSString *metaPath = _metaPath;
    NSMutableDictionary *images = [_images copy];
    dispatch_async(__metadataQueue, ^{
        [lock lock];
        NSArray *meta = [images mutableCopy];
        [lock unlock];
        NSData *data = [NSJSONSerialization dataWithJSONObject:meta options:kNilOptions error:NULL];
        BOOL fileWriteResult = [data writeToFile:metaPath atomically:YES];
        if (fileWriteResult == NO) {
            NSLog(@"couldn't save metadata");
        }
    });
}
- (void)cancelGetImageWithURLString:(NSString *)imageURLString{
    NSParameterAssert(imageURLString != nil);
    for (PSImageRetrieveOperation* operation in _retrievingQueue.operations) {
        if (!operation.cancelled && !operation.finished && [operation.name isEqualToString:imageURLString]) {
            [operation cancel];
            return;
        }
    }
}
- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger))block{
    __block NSUInteger size = 0;
    [self.dataFileManager calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        size += totalSize;
        if (block) {
            block(size);
        }
    }];
}
- (void)cleanCacheImage{
    NSMutableArray* lockedFilenames = [NSMutableArray array];
    @synchronized(_images)
    {
        NSMutableArray* lockedKeys = [NSMutableArray array];
        for (NSString* key in _images) {
            NSArray* imageInfo = [_images objectForKey:key];
            if ([imageInfo count] > kImageInfoIndexLock && [[imageInfo objectAtIndex:kImageInfoIndexLock] boolValue]) {
                [lockedFilenames addObject:[imageInfo objectAtIndex:kImageInfoIndexFileName]];
                [lockedKeys addObject:key];
            }
        }
        
        // remove unlock keys
        NSArray* allKeys = [_images allKeys];
        for (NSString* key in allKeys) {
            if ([lockedKeys indexOfObject:key] == NSNotFound) {
                [_images removeObjectForKey:key];
            }
        }
    }
    
    [_retrievingQueue cancelAllOperations];
    
    @synchronized(_addingImages)
    {
        for (NSString* key in _addingImages) {
            NSArray* blocks = [_addingImages objectForKey:key];
            dispatch_main_async_safeM(^{
                typedef void (^PSImageCacheRetrieveBlock)(NSString* key, UIImage* image);
                for ( PSImageCacheRetrieveBlock block in blocks) {
                    block(key, nil);
                }
            });
        }
        
        [_addingImages removeAllObjects];
    }
    // remove files
    [self.dataFileManager purgeWithExceptions:lockedFilenames toSize:0 completed:nil];
    [self saveMetadata];
}

# pragma runloop 监听
- (void)registerTransactionGroupAsMainRunloopObserver
{
    static CFRunLoopObserverRef observer;
    NSAssert(observer == NULL, @"A observer should not be registered on the main runloop twice");
    // defer the commit of the transaction so we can add more during the current runloop iteration
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | // before the run loop starts sleeping
                                kCFRunLoopExit);          // before exiting a runloop run
    CFRunLoopObserverContext context = {
        0,           // version
        (__bridge void *)self,  // info
        &CFRetain,   // retain
        &CFRelease,  // release
        NULL         // copyDescription
    };
    
    observer = CFRunLoopObserverCreate(NULL,        // allocator
                                       activities,  // activities
                                       YES,         // repeats
                                       INT_MAX,     // order after CA transaction commits
                                       &_transactionGroupRunLoopObserverCallbackM,  // callback
                                       &context);   // context
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

- (void)commit{
    if (self.needToSavedFile == YES) {
        self.needToSavedFile = NO;
        [self saveMetadata];
    }
}
@end

static void _transactionGroupRunLoopObserverCallbackM(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    PSImageCache *group = (__bridge PSImageCache *)info;
    [group commit];
    
}
