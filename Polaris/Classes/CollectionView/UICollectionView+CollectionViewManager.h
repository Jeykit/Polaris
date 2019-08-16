//
//  UICollectionView+CollectionViewManager.h
//  Expecta
//
//  Created by Jekity on 2019/7/22.
//

#import <UIKit/UIKit.h>
#import "CollectionViewManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (CollectionViewManager)
@property (nonatomic, strong , readonly) CollectionViewManager *collectionViewM;
- (void)configureCollectionViewWithBlock:(void (^)(CollectionViewManager *collectionViewM))block;
@end

NS_ASSUME_NONNULL_END
