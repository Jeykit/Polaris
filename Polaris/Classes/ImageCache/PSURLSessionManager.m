//
//  PSURLSessionManager.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSURLSessionManager.h"
#import <Security/Security.h>

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif
#ifndef __Require_noErr_Quiet
#define __Require_noErr_Quiet(errorCode, exceptionLabel)                      \
do                                                                          \
{                                                                           \
if ( __builtin_expect(0 != (errorCode), 0) )                            \
{                                                                       \
goto exceptionLabel;                                                \
}                                                                       \
} while ( 0 )
#endif
static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t ps_url_session_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ps_url_session_manager_creation_queue = dispatch_queue_create("com.imagecacheM.networking.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return ps_url_session_manager_creation_queue;
}
static void url_session_manager_create_task_safely(dispatch_block_t block) {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        // Fix of bug
        // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
        // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
        dispatch_sync(url_session_manager_creation_queue(), block);
    } else {
        block();
    }
}
static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t ps_url_session_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ps_url_session_manager_processing_queue = dispatch_queue_create("com.muimagecache.networking.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return ps_url_session_manager_processing_queue;
}
static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t ps_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ps_url_session_manager_completion_group = dispatch_group_create();
    });
    
    return ps_url_session_manager_completion_group;
}
typedef NSURL * (^PSURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionTask *downloadTask, NSURL *location);
typedef void (^PSURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);
typedef void (^PSURLSessionDownloadDataTaskProgressBlock)(NSData *data, int64_t countOfBytesExpectedToReceive, int64_t countOfBytesReceived);

@interface PSURLSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
- (instancetype)initWithTask:(NSURLSessionTask *)task;
@property (nonatomic, weak)   PSURLSessionManager *manager;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, copy)   NSURL *downloadFileURL;
@property (nonatomic, copy)   PSURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (nonatomic, copy)   PSURLSessionTaskCompletionHandler completionHandler;
@property (nonatomic, copy)   PSURLSessionDownloadDataTaskProgressBlock progressBlock;
@property (nonatomic,weak) NSURLSessionTask *task;
@end
@implementation PSURLSessionManagerTaskDelegate
- (instancetype)initWithTask:(NSURLSessionTask *)task {
    if (self = [super init]) {
        _mutableData      = [NSMutableData data];
        _task = task;
    }
    return self;
}
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    __block id responseObject = nil;
    
    //Performance Improvement from #2672
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        _mutableData = nil;
    }
    if (error) {
        dispatch_group_async(url_session_manager_completion_group(), dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }
        });
    } else {
        if (data.length > 0) {
            if (self.downloadTaskDidFinishDownloading) {
                self.downloadFileURL = self.downloadTaskDidFinishDownloading(session, task, nil);
                if (self.downloadFileURL) {
                    [data writeToFile:[self.downloadFileURL path] atomically:YES];
                    data = nil;
                }
            }
        }
        dispatch_async(url_session_manager_processing_queue(), ^{
            if (self.downloadFileURL) {
                responseObject = self.downloadFileURL;
            }
            dispatch_group_async(url_session_manager_completion_group(), dispatch_get_main_queue(), ^{
                if (self.completionHandler) {
                    self.completionHandler(task.response, responseObject, nil);
                }
            });
        });
    }
}
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
    if (self.progressBlock) {
        @autoreleasepool{
            NSData *copyData = [self.mutableData copy];
            self.progressBlock(copyData, dataTask.countOfBytesExpectedToReceive, dataTask.countOfBytesReceived);
            copyData = nil;
        }
    }
}
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    self.downloadFileURL = nil;
    
    if (self.downloadTaskDidFinishDownloading) {
        self.downloadFileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (self.downloadFileURL) {
            NSError *fileManagerError = nil;
            // remove error file
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:self.downloadFileURL.path]) {
                [[NSFileManager defaultManager] removeItemAtURL:self.downloadFileURL error:nil];
            }
            if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:self.downloadFileURL error:&fileManagerError]) {
                NSLog(@"error ==== %@",fileManagerError);
            }
        }
    }
}

@end

@interface PSURLSessionManager ()<NSURLSessionDelegate, NSURLSessionDataDelegate ,NSURLSessionTaskDelegate ,NSURLSessionDownloadDelegate>

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
@property (readonly, nonatomic, copy) NSString *taskDescriptionForSessionTasks;
@property (readwrite, nonatomic, strong) NSLock *lock;

@end
@implementation PSURLSessionManager
- (instancetype)init {
    static NSURLSessionConfiguration* configuration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* configurationIdentifier = [NSString stringWithFormat:@"com.imageCacheM.networking.session.manager.%@", [[NSUUID UUID] UUIDString]];
        configuration = [self configurationWithIdentifier:configurationIdentifier];
    });
    return [self initWithSessionConfiguration:configuration];
}
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if ( self = [super init]) {
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        self.sessionConfiguration = configuration;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
        self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
        
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"com.imagecacheM.networking.session.manager.lock";
        
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
                [self addDelegateForDownloadTask:downloadTask  destination:nil completionHandler:nil];
            }
        }];
    }
    return self;
}
- (NSURLSessionConfiguration*)configurationWithIdentifier:(NSString*)identifier
{
    NSURLSessionConfiguration* configuration;
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1100)
    configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
#else
    configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
#endif
    
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    
    return configuration;
}
- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    PSURLSessionManagerTaskDelegate *delegate = [[PSURLSessionManagerTaskDelegate alloc] initWithTask:downloadTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    
    if (destination) {
        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionTask *task, NSURL *location) {
            return destination(location, task.response);
        };
    }
    downloadTask.taskDescription = self.taskDescriptionForSessionTasks;
    [self setDelegate:delegate forTask:downloadTask];
}
- (void)setDelegate:(PSURLSessionManagerTaskDelegate *)delegate
            forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    [self.lock lock];
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    [self.lock unlock];
}
- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    [self.lock lock];
    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}
- (PSURLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    PSURLSessionManagerTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    return delegate;
}
static BOOL PSServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
_out:
    return isValid;
}
#pragma mark -server trust
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain
{
    NSMutableArray *policies = [NSMutableArray array];
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    return  PSServerTrustIsValid(serverTrust);
}
#pragma mark -public method
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    __block NSURLSessionDownloadTask *downloadTask = nil;
    
    __weak typeof(self)weakSelf = self;
    url_session_manager_create_task_safely(^{
        __strong typeof(weakSelf)self = weakSelf;
        downloadTask = [self.session downloadTaskWithRequest:request];
    });
    
    [self addDelegateForDownloadTask:downloadTask destination:destination completionHandler:completionHandler];
    
    return downloadTask;
}
- (NSURLSessionDataTask *)downloadDataTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSData * _Nonnull, int64_t, int64_t))progress destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination completionHandler:(void (^)(NSURLResponse * _Nonnull, NSURL * _Nonnull, NSError * _Nonnull))completionHandler
{
    __block NSURLSessionDataTask *dataTask = nil;
    __weak typeof(self)weakSelf = self;
    url_session_manager_create_task_safely(^{
        __strong typeof(weakSelf)self = weakSelf;
        dataTask = [self.session dataTaskWithRequest:request];
    });
    
    [self addDelegateForDataTask:dataTask destination:destination progress:progress completionHandler:completionHandler];
    return dataTask;
    
}
- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                      progress:(void(^)(NSData * _Nonnull, int64_t, int64_t))progress
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    PSURLSessionManagerTaskDelegate *delegate = [[PSURLSessionManagerTaskDelegate alloc] initWithTask:dataTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    delegate.progressBlock = progress;
    if (destination) {
        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionTask *task, NSURL *location) {
            return destination(location, task.response);
        };
    }
    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
    [self setDelegate:delegate forTask:dataTask];
}
#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSURLRequest *redirectRequest = request;
    
    
    if (completionHandler) {
        completionHandler(redirectRequest);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    PSURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    // delegate may be nil when completing a task in the background
    if (delegate) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        [self removeDelegateForTask:task];
    }
}
#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    if (completionHandler) {
        completionHandler(disposition);
    }
}
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    PSURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
    
}
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    PSURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];
}
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSCachedURLResponse *cachedResponse = proposedResponse;
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    PSURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    PSURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }
}
#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSURLSessionConfiguration *configuration = [decoder decodeObjectOfClass:[NSURLSessionConfiguration class] forKey:@"sessionConfiguration"];
    self = [self initWithSessionConfiguration:configuration];
    if (!self) {
        return nil;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.session.configuration forKey:@"sessionConfiguration"];
}
#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithSessionConfiguration:self.session.configuration];
}
@end
