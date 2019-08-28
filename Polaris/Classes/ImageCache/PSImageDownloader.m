//
//  PSImageDownloader.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSImageDownloader.h"
#import <CommonCrypto/CommonDigest.h>
#import "PSURLSessionManager.h"
#import "PSImageCacheUtils.h"

@interface PSImageDownloaderResponseHandler : NSObject
@property (nonatomic, strong) NSUUID* uuid;
@property (nonatomic, strong) PSImageDownloadProgressBlock processingBlock;
@property (nonatomic, strong) PSImageDownloadSuccessBlock successBlock;
@property (nonatomic, strong) PSImageDownloadFailedBlock failedBlock;
@end

@implementation PSImageDownloaderResponseHandler

- (instancetype)initWithUUID:(NSUUID*)uuid
                    progress:(PSImageDownloadProgressBlock)progress
                     success:(PSImageDownloadSuccessBlock)success
                      failed:(PSImageDownloadFailedBlock)failed
{
    if (self = [super init]) {
        self.uuid = uuid;
        self.processingBlock = progress;
        self.successBlock = success;
        self.failedBlock = failed;
    }
    return self;
}
@end
@interface PSImageDownloaderMergedTask : NSObject
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSMutableArray* handlers;
@property (nonatomic, strong) NSURLSessionTask* task;
@end
@implementation PSImageDownloaderMergedTask
- (instancetype)initWithIdentifier:(NSString*)identifier task:(NSURLSessionTask*)task
{
    if (self = [super init]) {
        self.identifier = identifier;
        self.task = task;
        self.handlers = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)addResponseHandler:(PSImageDownloaderResponseHandler*)handler
{
    [self.handlers addObject:handler];
}

- (void)removeResponseHandler:(PSImageDownloaderResponseHandler*)handler
{
    [self.handlers removeObject:handler];
}

- (void)clearHandlers
{
    [self.handlers removeAllObjects];
}

@end

@interface NSString (Extension)
- (NSString*)md5;
@end

@implementation NSString (Extension)
- (NSString*)md5
{
    const char* cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],
            result[1],
            result[2],
            result[3],
            result[4],
            result[5],
            result[6],
            result[7],
            result[8],
            result[9],
            result[10],
            result[11],
            result[12],
            result[13],
            result[14],
            result[15]];
}
@end

@interface PSImageDownloader()
@property (nonatomic, strong) NSMutableDictionary* downloadFile;
@property (nonatomic, strong) NSMutableDictionary* mergedTasks;
@property (nonatomic, strong) NSMutableArray* queuedMergedTasks;
@property (nonatomic, assign) NSInteger activeRequestCount;
@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;
@property (nonatomic, strong) dispatch_queue_t responseQueue;
@property (nonatomic, strong) NSMutableArray * complectedTasks;
@end

static NSString* kPSImageKeySuccessArray = @"sa";
static NSString* kPSImageKeyFilePath = @"fp";
static NSString* kPSImageKeyRequest = @"r";
@implementation PSImageDownloader
{
    PSURLSessionManager* _sessionManager;
    NSLock *_lock;
}
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static PSImageDownloader* __instance = nil;
    dispatch_once(&onceToken, ^{
        NSString *metaPath = [[PSImageCacheUtils directoryPath] stringByAppendingPathComponent:@"/__images"];
        NSString* folderPath = [[metaPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"/files"];//目录与dataFileManager存储的文件目录是一样的，这样才能映射到正确的文件
        __instance = [[[self class] alloc] initWithDestinationPath:folderPath];
    });
    
    return __instance;
}
- (instancetype)initWithDestinationPath:(NSString*)destinationPath
{
    if (self = [super init]) {
        _maxDownloadingCount = 5;
        _mergedTasks = [[NSMutableDictionary alloc] initWithCapacity:_maxDownloadingCount];
        _queuedMergedTasks = [[NSMutableArray alloc] initWithCapacity:_maxDownloadingCount];
        _complectedTasks = [NSMutableArray arrayWithCapacity:100];
        
        _lock = [[NSLock alloc]init];
        _destinationPath = [destinationPath copy];
        
        NSString* name = [NSString stringWithFormat:@"com.imagecache.imagedownloader.synchronizationqueue-%@", [[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        
        name = [NSString stringWithFormat:@"com.imagecache.imagedownloader.responsequeue-%@", [[NSUUID UUID] UUIDString]];
        self.responseQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
        _sessionManager = [[PSURLSessionManager alloc] init];

    }
    return self;
}
- (PSImageDownloadHandlerId *)downloadImageForURLRequest:(NSURLRequest *)request success:(PSImageDownloadSuccessBlock)success failed:(PSImageDownloadFailedBlock)failed
{
    NSParameterAssert(request != nil);
    __block PSImageDownloadHandlerId* handlerId = nil;
    dispatch_sync(_synchronizationQueue, ^{
        if (request.URL.absoluteString == nil) {
            if (failed) {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
                dispatch_main_sync_safeM(^{
                    failed(request, error);
                });
            }
            return;
        }
        NSString *identifier = [request.URL.absoluteString md5];
        handlerId = [NSUUID UUID];

        // 1) Append the success and failure blocks to a pre-existing request if it already exists
        PSImageDownloaderMergedTask *existingMergedTask = self.mergedTasks[identifier];
        if (existingMergedTask != nil) {
            PSImageDownloaderResponseHandler *handler = [[PSImageDownloaderResponseHandler alloc] initWithUUID:handlerId progress:nil success:success failed:failed];
            [existingMergedTask addResponseHandler:handler];
            return;
        }

        NSURLSessionTask *task =  [self handlerDownload:request identifier:identifier];
        // 4) Store the response handler for use when the request completes
        existingMergedTask = [[PSImageDownloaderMergedTask alloc] initWithIdentifier:identifier task:task];
        self.mergedTasks[ identifier ] = existingMergedTask;

        PSImageDownloaderResponseHandler *handler = [[PSImageDownloaderResponseHandler alloc] initWithUUID:handlerId progress:nil success:success failed:failed];
        [existingMergedTask addResponseHandler:handler];

        // 5) Either start the request or enqueue it depending on the current active request count
        if ([self isActiveRequestCountBelowMaximumLimit]) {
            [self startMergedTask:existingMergedTask];
        } else {
            [self enqueueMergedTask:existingMergedTask];
        }
    });

    return handlerId;
}
- (PSImageDownloadHandlerId *)downloadImageForURLRequest:(NSURLRequest *)request progress:(PSImageDownloadProgressBlock)progress success:(PSImageDownloadSuccessBlock)success failed:(PSImageDownloadFailedBlock)failed
{
    NSParameterAssert(request != nil);
    __block PSImageDownloadHandlerId* handlerId = nil;
    dispatch_sync(_synchronizationQueue, ^{
        if (request.URL.absoluteString == nil) {
            if (failed) {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
                dispatch_main_sync_safeM(^{
                    failed(request, error);
                });
            }
            return;
        }
        NSString *identifier = [request.URL.absoluteString md5];
        handlerId = [NSUUID UUID];
        
        // 1) Append the success and failure blocks to a pre-existing request if it already exists
        PSImageDownloaderMergedTask *existingMergedTask = self.mergedTasks[identifier];
        if (existingMergedTask != nil) {
            PSImageDownloaderResponseHandler *handler = [[PSImageDownloaderResponseHandler alloc] initWithUUID:handlerId progress:progress success:success failed:failed];
            [existingMergedTask addResponseHandler:handler];
            return;
        }
        
        NSURLSessionTask *task =  [self handlerProgressDownload:request progress:progress identifier:identifier];
        // 4) Store the response handler for use when the request completes
        existingMergedTask = [[PSImageDownloaderMergedTask alloc] initWithIdentifier:identifier task:task];
        self.mergedTasks[ identifier ] = existingMergedTask;
        
        PSImageDownloaderResponseHandler *handler = [[PSImageDownloaderResponseHandler alloc] initWithUUID:handlerId progress:progress success:success failed:failed];
        [existingMergedTask addResponseHandler:handler];
        
        // 5) Either start the request or enqueue it depending on the current active request count
        if ([self isActiveRequestCountBelowMaximumLimit]) {
            [self startMergedTask:existingMergedTask];
        } else {
            [self enqueueMergedTask:existingMergedTask];
        }
    });
    
    return handlerId;
}
- (NSURLSessionTask *)handlerDownload:(NSURLRequest *)request identifier:(NSString *)identifier{
    __weak __typeof__(self) weakSelf = self;
    NSString *destinationPath = _destinationPath;
    return [_sessionManager downloadTaskWithRequest:request
                                        destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                            return [NSURL fileURLWithPath:[destinationPath stringByAppendingPathComponent:identifier]];
                                        }
                                  completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                      dispatch_async(weakSelf.responseQueue, ^{
                                          __strong __typeof__(weakSelf) strongSelf = weakSelf;
                                          PSImageDownloaderMergedTask *mergedTask = strongSelf.mergedTasks[identifier];
                                          if (error != nil) {
                                              
                                              NSArray *tempArray = [mergedTask.handlers mutableCopy];
                                              for (PSImageDownloaderResponseHandler *handler in tempArray) {
                                                  if (handler.failedBlock) {
                                                      handler.failedBlock(request, error);
                                                  }
                                              }
                                              // remove error file
                                              [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
                                          }else{
                                              
                                              NSArray *tempArray = [mergedTask.handlers copy];
                                              for (PSImageDownloaderResponseHandler *handler in tempArray) {
                                                  if (handler.successBlock) {
                                                      handler.successBlock(request, filePath);
                                                  }
                                              }
                                          }
                                          
                                          // remove exist task
                                          [strongSelf.mergedTasks removeObjectForKey:identifier];
                                          
                                          [strongSelf safelyDecrementActiveTaskCount];
                                          [strongSelf safelyStartNextTaskIfNecessary];
                                      });
                                  }];
}
- (NSURLSessionTask *)handlerProgressDownload:(NSURLRequest *)request
                                     progress:(PSImageDownloadProgressBlock)progress
                                   identifier:(NSString *)identifier{
    __weak __typeof__(self) weakSelf = self;
    NSString *destinationPath = _destinationPath;
    return [_sessionManager downloadDataTaskWithRequest:request progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
         return [NSURL fileURLWithPath:[destinationPath stringByAppendingPathComponent:identifier]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        dispatch_async(weakSelf.responseQueue, ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            PSImageDownloaderMergedTask *mergedTask = strongSelf.mergedTasks[identifier];
            if (error != nil) {
                NSArray *tempArray = [mergedTask.handlers mutableCopy];
                for (PSImageDownloaderResponseHandler *handler in tempArray) {
                    if (handler.failedBlock) {
                        handler.failedBlock(request, error);
                    }
                }
                // remove error file
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            }else{
                
                NSArray *tempArray = [mergedTask.handlers copy];
                for (PSImageDownloaderResponseHandler *handler in tempArray) {
                    if (handler.successBlock) {
                        handler.successBlock(request, filePath);
                    }
                }
            }
            
            // remove exist task
            [strongSelf.mergedTasks removeObjectForKey:identifier];
            
            [strongSelf safelyDecrementActiveTaskCount];
            [strongSelf safelyStartNextTaskIfNecessary];
        });
    }];
}
- (BOOL)isActiveRequestCountBelowMaximumLimit
{
    return self.activeRequestCount < self.maxDownloadingCount;
}
- (void)startMergedTask:(PSImageDownloaderMergedTask*)mergedTask
{
    [mergedTask.task resume];
    ++self.activeRequestCount;
}
- (PSImageDownloaderMergedTask*)dequeueMergedTask
{
    PSImageDownloaderMergedTask* mergedTask = nil;
    mergedTask = [_queuedMergedTasks lastObject];
    [self.queuedMergedTasks removeObject:mergedTask];
    return mergedTask;
}
- (void)enqueueMergedTask:(PSImageDownloaderMergedTask*)mergedTask
{
    // default is AFImageDownloadPrioritizationLIFO
    [_queuedMergedTasks insertObject:mergedTask atIndex:0];
}
- (void)safelyDecrementActiveTaskCount
{
    dispatch_sync(_synchronizationQueue, ^{
        if (self.activeRequestCount > 0) {
            self.activeRequestCount -= 1;
        }
    });
}

- (void)safelyStartNextTaskIfNecessary
{
    NSMutableArray *queuedMergedTasks = _queuedMergedTasks;
    dispatch_sync(_synchronizationQueue, ^{
        while ([self isActiveRequestCountBelowMaximumLimit] && [queuedMergedTasks count] > 0 ) {
            PSImageDownloaderMergedTask *mergedTask = [self dequeueMergedTask];
            [self startMergedTask:mergedTask];
        }
    });
}
@end
