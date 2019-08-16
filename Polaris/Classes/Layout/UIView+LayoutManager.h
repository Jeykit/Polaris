//
//  UIView+LayoutManager.h
//  Expecta
//
//  Created by Jekity on 2019/7/11.
//

#import <UIKit/UIKit.h>
#import "LayoutManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LayoutManager)

@property (nonatomic, strong, readonly) LayoutManager *layoutM;

- (void)configureLayoutWithBlock:(void (^)(LayoutManager *layoutM))block;

@end

NS_ASSUME_NONNULL_END
