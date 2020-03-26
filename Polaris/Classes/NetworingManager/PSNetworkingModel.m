//
//  PSNetworkingModel.m
//  MUKit_Example
//
//  Created by Jekity on 2018/5/7.
//  Copyright © 2018年 Jeykit. All rights reserved.
//

#import "PSNetworkingModel.h"
#import "PSHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"

@implementation PSNetworkingModel
#pragma mark- network
+(void)POST:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters progress:(void (^)(NSProgress *))progress success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance] POST:URLString parameters:parameters progress:progress success:success failure:failure];;
}
+(void)POST:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance] POST:URLString parameters:parameters success:success failure:failure];
}

#pragma mark -image
+(void)POST:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters images:(NSMutableArray *)images formData:(void (^)(id<AFMultipartFormData>))block progress:(void (^)(NSProgress *))progress success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance]POST:URLString parameters:parameters images:images formData:block progress:progress success:success failure:failure];
    
}
+(void)POST:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters images:(NSMutableArray *)images formData:(void (^)(id<AFMultipartFormData>))block success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance]POST:URLString parameters:parameters images:images formData:block success:success failure:failure];
    
    
}
+(void)POST:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters images:(NSMutableArray *)images success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance]POST:URLString parameters:parameters images:images formData:nil success:success failure:failure];
    
}

#pragma mark -get
+(void)GET:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters progress:(void (^)(NSProgress *))progress success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance]GET:URLString parameters:parameters progress:progress success:success failure:failure];
}
+(void)GET:(NSString *)URLString parameters:(void (^)(PSParameterModel *))parameters success:(void (^)(PSNetworkingModel *, NSArray<PSNetworkingModel *> *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *, NSString *))failure{
    [[PSHTTPSessionManager sharedInstance]GET:URLString parameters:parameters success:success failure:failure];
}

////参数配置
+(void)GlobalStatus:(void (^)(NSUInteger, NSString *))statusBlock networkingStatus:(void (^)(NSUInteger))networkingStatus{
     [[PSHTTPSessionManager sharedInstance]GlobalStatus:statusBlock networkingStatus:networkingStatus];
}
//+(void)GlobalConfigurationWithModelName:(NSString *)name domain:(NSString *)domain Certificates:(NSString *)certificates requestHeader:(NSDictionary *)header publicParameters:(NSDictionary *)parameters dataFormat:(NSDictionary *)dataFormat{
//    [[MUHTTPSessionManager sharedInstance]GlobalConfigurationWithModelName:name Domain:domain Certificates:certificates requestHeader:header publicParameters:parameters dataFormat:dataFormat];
//}
//+(void)GlobalConfigurationWithModelName:(NSString *)name parameterModel:(NSString *)parameter domain:(NSString *)domain Certificates:(NSString *)certificates requestHeader:(NSDictionary *)header publicParameters:(NSDictionary *)parameters dataFormat:(NSDictionary *)dataFormat{
//    [MUHTTPSessionManager GlobalConfigurationWithModelName:name parameterModel:parameter domain:domain Certificates:certificates requestHeader:header publicParameters:parameters dataFormat:dataFormat];
//}
+(void)GlobalConfigurationWithModelName:(NSString *)name parameterModel:(NSString *)parameter domain:(NSString *)domain Certificates:(NSString *)certificates dataFormat:(NSDictionary *)dataFormat{
    [PSHTTPSessionManager GlobalConfigurationWithModelName:name parameterModel:parameter domain:domain Certificates:certificates dataFormat:dataFormat];
}
+(void)GlobalConfigurationWithModelName:(NSString *)name parameterModel:(NSString *)parameter domain:(NSString *)domain Certificates:(NSString *)certificates dataFormat:(NSDictionary *)dataFormat timeout:(NSUInteger)timeout{
    [PSHTTPSessionManager GlobalConfigurationWithModelName:name parameterModel:parameter domain:domain Certificates:certificates dataFormat:dataFormat timeout:0];
}
//公共参数
+(void)publicParameters:(NSDictionary *)parameters;{
    [PSHTTPSessionManager publicParameters:parameters]; ;
}
//qing
+(void)requestHeader:(NSDictionary *)parameters{
    [PSHTTPSessionManager requestHeader:parameters];
}
+(void)networkingReachabilityStartMonitoring:(BOOL)start Status:(void (^)(MUNetworkingStatus))block{
    if (start) {
         [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    if (block) {
                        block(MUNetworkingStatusUnknown);
                    }
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    if (block) {
                        block(MUNetworkingStatusNotReachable);
                    }
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    if (block) {
                        block(MUNetworkingStatusReachableViaWWAN);
                    }
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    if (block) {
                        block(MUNetworkingStatusReachableViaWiFi);
                    }
                    break;
                default:
                    break;
            }
        }];
    }else{
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    }
}


@end
