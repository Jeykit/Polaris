//
//  PSImageDownloader.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
typedef NSUUID PSImageDownloadHandlerId; // Unique ID of handler
typedef void (^PSImageDownloadProgressBlock)(NSData *data, int64_t countOfBytesExpectedToReceive, int64_t countOfBytesReceived);
typedef void (^PSImageDownloadSuccessBlock)(NSURLRequest* request, NSURL* filePath);
typedef void (^PSImageDownloadFailedBlock)(NSURLRequest* request, NSError* error);

@interface PSImageDownloader : NSObject

@property (nonatomic, copy) NSString* destinationPath;
@property (nonatomic, assign) NSInteger maxDownloadingCount; // Default is 5;

+ (instancetype)sharedInstance;

- (instancetype)initWithDestinationPath:(NSString*)destinationPath;

/**
 *  Send a download request with callbacks
 */
- (PSImageDownloadHandlerId*)downloadImageForURLRequest:(NSURLRequest*)request
                                                success:(PSImageDownloadSuccessBlock)success
                                                 failed:(PSImageDownloadFailedBlock)failed;

- (PSImageDownloadHandlerId*)downloadImageForURLRequest:(NSURLRequest*)request
                                               progress:(PSImageDownloadProgressBlock)progress
                                                success:(PSImageDownloadSuccessBlock)success
                                                 failed:(PSImageDownloadFailedBlock)failed;

@end

NS_ASSUME_NONNULL_END
