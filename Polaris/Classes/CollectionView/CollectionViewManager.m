//
//  CollectionViewManager.m
//  Expecta
//
//  Created by Jekity on 2019/7/22.
//

#import "CollectionViewManager.h"
#import "CollectionViewManager+Private.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIView+LayoutManager.h"
#import "PSDynamicsProperty.h"

@interface CollectionViewManager ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong)NSMutableArray *innerModelArray;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic ,strong)PSDynamicsProperty *dynamicProperty;
@property(nonatomic, strong)PSRefreshFooterStyleComponent *refreshFooter;
@property(nonatomic, strong)PSRefreshHeaderStyleComponent *refreshHeader;
@property (nonatomic,assign) BOOL isRefreshingWithFooter;
@property (nonatomic,strong) UIImage *snapshotImage;
@property (nonatomic,strong) UIImageView *snapshotImageView;
@property(nonatomic, assign)CGRect originalRect;
@property(nonatomic, assign)CGFloat scaleCenterX;
@property(nonatomic, strong)PSTipsView *tipView;
@end
static NSString * const itemHeight            = @"PSItemHeight";
@implementation CollectionViewManager
{
    BOOL _isSection;
    NSString *_cellReuseIdentifier;
    UICollectionViewCell *_collectionViewCell;
    CGFloat _itemWidth;
}
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    if (self = [super init]) {
        _collectionView = collectionView;
        _cellClassName = @"UICollectionViewCell";
        _cellReuseIdentifier = @"PolarisCollectionViewCellReuseIdentifier";
        _dynamicProperty = [[PSDynamicsProperty alloc] init];
    }
    return self;
}
- (void)setModelArray:(NSArray *)modelArray
{
    NSAssert(self.cellClassName.length  > 0, @"Please register a cell class at first");
    NSAssert(_itemCounts != 0, @"Please setting itemCounts");
    if (_collectionViewCell == nil) {
        _collectionViewCell       = [[NSClassFromString(self.cellClassName) alloc]init];
        [_collectionView registerClass:NSClassFromString(self.cellClassName) forCellWithReuseIdentifier:_cellReuseIdentifier];
    }
    if (modelArray.count > 0 && _keyPath.length > 0) {
        _isSection = [self isSectionWithArray:modelArray keyPath:_keyPath];
    }
    
    if (_isRefreshingWithFooter == YES) {
        if (self.innerModelArray.count > 0) {
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.innerModelArray];
            [mArray addObjectsFromArray:modelArray];
            self.innerModelArray = mArray;
        }else{
            self.collectionView.backgroundView = self.tipView;
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:modelArray];
            self.innerModelArray = mArray;
        }
    }else{
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:modelArray];
        self.innerModelArray = mArray;
    }
    if (self.innerModelArray.count > 0) {
        self.collectionView.backgroundView = nil;
    }else{
        self.collectionView.backgroundView = self.tipView;
    }
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView reloadData];
    
}
- (NSArray *)modelArray{
    return self.innerModelArray;
}
-(BOOL)isSectionWithArray:(NSArray *)array keyPath:(NSString *)keyPath{
    NSObject *object = array.firstObject;
    NSArray *subArray = [object valueForKey:keyPath];
    BOOL section = NO;
    if (subArray || subArray.count > 0) {
        section = YES;
    }
    return section;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_isSection) {
        return self.innerModelArray.count;
    }
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_isSection) {
        id model = self.innerModelArray[section];
        NSArray *subArray = [model valueForKey:_keyPath];
        return subArray.count;
    }
    return self.innerModelArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = nil;
    if (_isSection) {//拆解模型
        if (self.innerModelArray.count > indexPath.section) {
            object  = self.innerModelArray[indexPath.section];
        }
        NSArray *subArray = [object valueForKey:_keyPath];
        if (subArray.count > indexPath.row) {
            object  = subArray[indexPath.row];
        }
    }else{
        if (self.innerModelArray.count>indexPath.row) {
            object  = self.innerModelArray[indexPath.row];
        }
    }
    UICollectionViewCell *resultCell = nil;
    if (self.renderBlock) {
        resultCell = self.renderBlock(resultCell,indexPath,object);
        if (resultCell == nil) {
            resultCell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellReuseIdentifier forIndexPath:indexPath];
            resultCell = self.renderBlock(resultCell,indexPath,object);
        }
    }
    resultCell.contentView.layoutM.width = _itemWidth;
    [resultCell.contentView.layoutM applyLayoutPreservingOrigin:NO];
    return resultCell;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    id object              = nil;
    if (_isSection) {
        if (self.innerModelArray.count>indexPath.section) {
            object  = self.innerModelArray[indexPath.section];
        }
        NSArray *subArray = [object valueForKey:_keyPath];
        if (subArray.count>indexPath.row) {
            object  = subArray[indexPath.row];
        }
        
    }else{
        if (self.innerModelArray.count>indexPath.row) {
            object  = self.innerModelArray[indexPath.row];
        }
    }
    if ([object respondsToSelector:@selector(PSItemHeight)] == NO) {
        [self.dynamicProperty addDynamicPropertyToObject:object propertyName:itemHeight type:PSDynamicPropertyTypeAssign];
    }
    CGFloat height =  [self.dynamicProperty getFloatValueFromObject:object name:itemHeight];
    
    if (_itemWidth == 0) {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        _itemWidth = (collectionView.layoutM.width - flowLayout.minimumInteritemSpacing * (_itemCounts - 1))/_itemCounts;//计算item宽度
    }
    if (height > 0) {
        return CGSizeMake(_itemWidth, height);
    }
    UICollectionViewCell *cell = self.renderBlock(_collectionViewCell, indexPath, object);//取回真实的cell，实现cell的动态行高;
    cell.contentView.layoutM.width = _itemWidth;
    cell.contentView.layoutM.height = -1;
    [cell.contentView.layoutM applyLayoutPreservingOrigin:YES];
    height = cell.contentView.layoutM.height;
    [self.dynamicProperty setFloatValueToObject:object name:itemHeight value:height];
    return CGSizeMake(_itemWidth, height);
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    id object = nil;
    if (_isSection) {
        object  = self.innerModelArray[indexPath.section];
    }else{
        object  = self.innerModelArray[indexPath.row];
    }
    
    UICollectionReusableView *resuableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (self.headerViewBlock) {
            resuableView = self.headerViewBlock(resuableView, indexPath.section, object);//检测是否有自定义cell
            resuableView.layoutM.width = collectionView.layoutM.width;
            [resuableView.layoutM applyLayoutPreservingOrigin:NO];
        }
        
    }else if (kind == UICollectionElementKindSectionFooter){
        if (self.footerViewBlock) {
            resuableView = self.footerViewBlock(resuableView, indexPath.section, object);//检测是否有自定义cell
            resuableView.layoutM.width = collectionView.layoutM.width;
            [resuableView.layoutM applyLayoutPreservingOrigin:NO];
        }
    }
    return resuableView;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    UICollectionReusableView *reusableView = nil;
    id model = nil;
    if (self.innerModelArray.count > section) {
        model = self.innerModelArray[section];
    }
    if (self.footerViewBlock) {
        reusableView = self.headerViewBlock(reusableView, section, model);
    }
    reusableView.layoutM.width = collectionView.layoutM.width;
    reusableView.layoutM.height = -1;
    [reusableView.layoutM applyLayoutPreservingOrigin:YES];
    return CGSizeMake(reusableView.layoutM.width, reusableView.layoutM.height);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    UICollectionReusableView *reusableView = nil;
    id model = nil;
    if (self.innerModelArray.count > section) {
        model = self.innerModelArray[section];
    }
    if (self.footerViewBlock) {
        reusableView = self.footerViewBlock(reusableView, section, model);
    }
    reusableView.layoutM.width = collectionView.layoutM.width;
    reusableView.layoutM.height = -1;
    [reusableView.layoutM applyLayoutPreservingOrigin:YES];
    return CGSizeMake(reusableView.layoutM.width, reusableView.layoutM.height);
}
//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    _itemWidth = (collectionView.layoutM.width - flowLayout.minimumInteritemSpacing * (_itemCounts - 1))/_itemCounts;//计算item宽度
    return UIEdgeInsetsZero;//分别为上、左、下、右
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectedCellBlock) {
        id object = nil;
        if (_isSection) {
            object  = self.innerModelArray[indexPath.section];
            NSArray *subArray = [object valueForKey:_keyPath];
            object  = subArray[indexPath.row];
        }else{
            object  = self.innerModelArray[indexPath.row];
        }
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        self.selectedCellBlock(cell, indexPath, object);
    }
}
#pragma mark -refreshing
static NSString * const MUHeadKeyPath = @"PSHeadKeyPath";
static NSString * const MUFootKeyPath = @"PSHeadKeyPath";
-(void)addFooterRefreshing:(void (^)(PSRefreshComponent *))block{
    if (!_refreshFooter) {
        _refreshFooter = [PSRefreshFooterStyleComponent new];
        _refreshFooterComponent = _refreshFooter;
    }
    __weak typeof(self)weakSelf = self;
    _refreshFooter.refreshHandler = ^(PSRefreshComponent *component) {
        weakSelf.isRefreshingWithFooter = YES;
        if (block) {
            block(component);
        }
    };
    //    _refreshFooter.refreshHandler = callback;
    _refreshFooter.backgroundColor = [UIColor clearColor];
    if (!_refreshFooter.superview) {
        [_collectionView willChangeValueForKey:MUFootKeyPath];
        [_collectionView addSubview:_refreshFooter];
        [_collectionView didChangeValueForKey:MUFootKeyPath];
    }
}
-(void)addHeaderRefreshing:(void (^)(PSRefreshComponent *))block{
    if (!_refreshHeader) {
        _refreshHeader = [PSRefreshHeaderStyleComponent new];
        _refreshHeaderComponent = _refreshHeader;
    }
    __weak typeof(self)weakSelf = self;
    _refreshHeader.refreshHandler = ^(PSRefreshComponent *component) {
        weakSelf.isRefreshingWithFooter = NO;
        if (block) {
            block(component);
        }
    };
    _refreshHeader.backgroundColor = [UIColor clearColor];
    if (!_refreshHeader.superview) {
        [_collectionView willChangeValueForKey:MUHeadKeyPath];
        [_collectionView addSubview:_refreshHeader];
        [_collectionView didChangeValueForKey:MUHeadKeyPath];
        [_refreshHeader beginRefreshing];
    }
}
-(PSRefreshHeaderStyleComponent *)refreshHeaderComponent{
    if (!_refreshHeader) {
        _refreshHeader = [PSRefreshHeaderStyleComponent new];
    }
    return _refreshHeader;
}
-(PSRefreshFooterStyleComponent *)refreshFooterComponent{
    if (!_refreshFooter) {
        _refreshFooter = [PSRefreshFooterStyleComponent new];
    }
    return _refreshFooter;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(scrollView);
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (self.scrollViewDidEndDragging) {
        self.scrollViewDidEndDragging(scrollView, decelerate);
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (self.scrollViewDidEndScrollingAnimation) {
        self.scrollViewDidEndScrollingAnimation(scrollView);
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.scrollViewWillBeginDragging) {
        self.scrollViewWillBeginDragging(scrollView);
    }
}
- (PSTipsView *)tipsView{
    if (!_tipView) {
        _tipView = [[PSTipsView alloc]init];
        if (self.collectionView.backgroundView) {
            _tipView.frame = self.collectionView.backgroundView.bounds;
            [self.collectionView.backgroundView addSubview:_tipView];
        }else{
            self.collectionView.backgroundView = _tipView;
        }
    }
    return _tipView;
}
- (void)clearData{
    _collectionView.backgroundView  =self.tipsView;
    self.innerModelArray = [NSMutableArray array];
    [_collectionView reloadData];
}
- (CGFloat)maxCellHeight{
    CGFloat totalHeight = 0;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return 0;
    }
    if (_isSection) {//拆解模型
        NSUInteger preIndex  = 0;
        CGFloat maxHeight = 0;
        for (NSUInteger j = 0; j < self.innerModelArray.count; j++) {
            preIndex = j;
            id innerObject = self.innerModelArray[j];
            NSArray *subArray = [innerObject valueForKey:_keyPath];
            for (NSUInteger i = 0; i < subArray.count; i++) {
                id object = subArray[i];
                if ([object respondsToSelector:@selector(PSItemHeight)] == NO) {
                    [self.dynamicProperty addDynamicPropertyToObject:object propertyName:itemHeight type:PSDynamicPropertyTypeAssign];
                }
                CGFloat cellHeight =  [self.dynamicProperty getFloatValueFromObject:object name:itemHeight];
                if (cellHeight == 0) {
                    
                    UICollectionViewCell *resultCell = _collectionViewCell;
                    if (self.renderBlock) {
                        resultCell = self.renderBlock(resultCell,[NSIndexPath indexPathForRow:0 inSection:i],object);
                    };
                    if (_itemWidth == 0) {
                        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
                        _itemWidth = (_collectionView.layoutM.width - flowLayout.minimumInteritemSpacing * (_itemCounts - 1))/_itemCounts;//计算item宽度
                    }
                    resultCell.contentView.layoutM.width = _itemWidth;
                    resultCell.contentView.layoutM.height = -1;
                    [resultCell.contentView.layoutM applyLayoutPreservingOrigin:YES];
                    cellHeight = resultCell.contentView.layoutM.height;
                    [self.dynamicProperty setFloatValueToObject:object name:itemHeight value:cellHeight];
                }
                [self.dynamicProperty setFloatValueToObject:object name:itemHeight value:cellHeight];
                if (preIndex == j) {
                    maxHeight = MAX(maxHeight, cellHeight);
                }
            }
            totalHeight += maxHeight;
            maxHeight = 0;
        }
    }else{
        for (NSUInteger i = 0; i < self.innerModelArray.count; i++) {
            id object = self.innerModelArray[i];
            if ([object respondsToSelector:@selector(PSItemHeight)] == NO) {
                [self.dynamicProperty addDynamicPropertyToObject:object propertyName:itemHeight type:PSDynamicPropertyTypeAssign];
            }
            CGFloat cellHeight =  [self.dynamicProperty getFloatValueFromObject:object name:itemHeight];
            if (cellHeight == 0) {
                
                UICollectionViewCell *resultCell = _collectionViewCell;
                if (self.renderBlock) {
                    resultCell = self.renderBlock(resultCell,[NSIndexPath indexPathForRow:0 inSection:i],object);
                };
                if (_itemWidth == 0) {
                    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
                    _itemWidth = (_collectionView.layoutM.width - flowLayout.minimumInteritemSpacing * (_itemCounts - 1))/_itemCounts;//计算item宽度
                }
                resultCell.contentView.layoutM.width = _itemWidth;
                resultCell.contentView.layoutM.height = -1;
                [resultCell.contentView.layoutM applyLayoutPreservingOrigin:YES];
                cellHeight = resultCell.contentView.layoutM.height;
                [self.dynamicProperty setFloatValueToObject:object name:itemHeight value:cellHeight];
            }
            totalHeight = MAX(totalHeight, cellHeight);
        }
        
        
    }
    return totalHeight+4.;
    
}
#pragma clang diagnostic pop
@end
