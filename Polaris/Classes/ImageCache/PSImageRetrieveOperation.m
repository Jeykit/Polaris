//
//  PSImageRetrieveOperation.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSImageRetrieveOperation.h"
#import <UIKit/UIKit.h>

typedef UIImage * (^RetrieveOperationBlock)(void);
@implementation PSImageRetrieveOperation
{
     NSMutableArray* _blocks;
     RetrieveOperationBlock _retrieveBlock;
}
- (instancetype)initWithRetrieveBlock:(UIImage * _Nonnull (^)(void))block{
    
    if (self =  [super init]) {
        _blocks = nil;
        _retrieveBlock = block;
    }
    return self;
}
- (void)addBlock:(void (^)(NSString * _Nonnull key, UIImage * _Nonnull image))block{
    if (_blocks == nil) {
        _blocks = [NSMutableArray array];
    }
    if (block) {
        if (_blocks) {
            [_blocks addObject:block];
        }
    }
}

- (void)executeWithImage:(UIImage *)image{
    typedef void (^PSImageCacheRetrieveBlock)(NSString* key, UIImage* image);
    for (PSImageCacheRetrieveBlock block in _blocks) {
        if (block) {
            block(self.name, image);
        }
    }
    [_blocks removeAllObjects];
}
- (void)main
{
    if (self.isCancelled) {
        return;
    }
    
    UIImage* image = _retrieveBlock();
    [self executeWithImage:image];
}
- (void)cancel
{
    if (self.isFinished)
        return;
    [super cancel];
    
    [self executeWithImage:nil];
}
@end
