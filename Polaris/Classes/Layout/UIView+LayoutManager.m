//
//  UIView+LayoutManager.m
//  Expecta
//
//  Created by Jekity on 2019/7/11.
//

#import "UIView+LayoutManager.h"
#import <objc/runtime.h>
#import "LayoutManager+Private.h"

@implementation UIView (LayoutManager)

- (LayoutManager *)layoutM
{
    LayoutManager *layoutM = objc_getAssociatedObject(self, @selector(layoutM));
    if (!layoutM) {
        layoutM = [[LayoutManager alloc] initWithView:self];
        objc_setAssociatedObject(self, @selector(layoutM), layoutM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layoutM;
}
- (void)configureLayoutWithBlock:(void (^)(LayoutManager * _Nonnull))block
{
    if (block != nil) {
        block(self.layoutM);
    }
}
@end
