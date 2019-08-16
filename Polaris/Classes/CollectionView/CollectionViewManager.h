//
//  CollectionViewManager.h
//  Expecta
//
//  Created by Jekity on 2019/7/22.
//

#import <UIKit/UIKit.h>
#import "PSRefreshHeaderStyleComponent.h"
#import "PSRefreshFooterStyleComponent.h"
#import "PSTipsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewManager : NSObject
@property (nonatomic, copy) NSString *cellClassName;
@property (nonatomic ,copy) NSString *keyPath;
@property (nonatomic, assign) CGFloat itemCounts;
@property(nonatomic, copy)UICollectionViewCell *(^renderBlock)(UICollectionViewCell *  cell ,NSIndexPath * indexPath ,id  model);
@property(nonatomic, copy)void (^selectedCellBlock)(UICollectionViewCell *cell ,NSIndexPath *  indexPath ,id model);

@property(nonatomic, copy) UICollectionReusableView *(^headerViewBlock)(UICollectionReusableView * view ,NSUInteger section, id model);
@property(nonatomic, copy)UICollectionReusableView *(^footerViewBlock)(UICollectionReusableView *  view ,NSUInteger section, id model);

@property (nonatomic,assign , readonly) CGFloat maxCellHeight;

@property (nonatomic ,strong)NSArray *modelArray;

@property(nonatomic, weak)PSRefreshHeaderStyleComponent *refreshHeaderComponent;
@property(nonatomic, weak)PSRefreshFooterStyleComponent *refreshFooterComponent;
/**
 下拉刷新
 */
- (void)addHeaderRefreshing:(void(^)(PSRefreshComponent *refresh))block;
/**
 上拉刷新
 */
- (void)addFooterRefreshing:(void(^)(PSRefreshComponent *refresh))block;

@property(nonatomic, weak)UIView                         *scaleView;//下拉缩放的图片backgroundView image
/**
 UISrollView的代理方法
 */
@property(nonatomic, copy)void (^scrollViewDidScroll)(UIScrollView *  scrollView);
@property(nonatomic, copy)void (^scrollViewWillBeginDragging)(UIScrollView *  scrollView);
@property(nonatomic, copy)void (^scrollViewDidEndDragging)(UIScrollView *  scrollView , BOOL decelerate);
@property(nonatomic, copy)void (^scrollViewDidEndScrollingAnimation)(UIScrollView *  scrollView);

/**
 UITableView数据为空时，则通过它设置相应的提示信息
 */
@property(nonatomic, readonly)PSTipsView                 *tipsView;

- (void)clearData;
@end

NS_ASSUME_NONNULL_END
