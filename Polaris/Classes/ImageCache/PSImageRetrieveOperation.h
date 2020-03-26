//
//  PSImageRetrieveOperation.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>

@interface PSImageRetrieveOperation : NSOperation
- (instancetype)initWithRetrieveBlock:(UIImage* (^)(void))block;
- (void)addBlock:(void (^)(NSString* key, UIImage* image))block;
- (void)executeWithImage:(UIImage*)image;
@end

