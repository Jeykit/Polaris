//
//  UICollectionView+CollectionViewManager.m
//  Expecta
//
//  Created by Jekity on 2019/7/22.
//

#import "UICollectionView+CollectionViewManager.h"
#import "CollectionViewManager+Private.h"
#import <objc/runtime.h>

@implementation UICollectionView (CollectionViewManager)
- (CollectionViewManager *)collectionViewM{
    CollectionViewManager *collectionViewM = objc_getAssociatedObject(self, @selector(collectionViewM));
    if (!collectionViewM) {
        collectionViewM = [[CollectionViewManager alloc] initWithCollectionView:self];
        objc_setAssociatedObject(self, @selector(collectionViewM), collectionViewM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return collectionViewM;
}
- (void)configureCollectionViewWithBlock:(void (^)(CollectionViewManager * _Nonnull))block
{
    if (block != nil) {
        block(self.collectionViewM);
    }
}

@end
