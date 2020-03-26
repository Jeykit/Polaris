//
//  TableViewManager.m
//  Expecta
//
//  Created by Jekity on 2019/7/15.
//

#import "TableViewManager.h"
#import "TableViewManager+Private.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIView+LayoutManager.h"
#import "PSDynamicsProperty.h"


@interface TableViewManager()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)NSMutableArray *innerModelArray;
@property (nonatomic,weak) UITableView *tableView;
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

static NSString * const rowHeight = @"PSRowHeight";
@implementation TableViewManager
{
    BOOL _isSection;
    CGFloat _rowHeight;
    NSString *_cellReuseIdentifier;
    UITableViewCell *_tableViewCell;
}
- (instancetype)initWithTableView:(UITableView *)tableView{
    if (self = [super init]) {
        _tableView = tableView;
        _rowHeight = tableView.rowHeight;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _cellClassName = @"UITableViewCell";
        _cellReuseIdentifier = @"PolarisCellReuseIdentifier";
        _dynamicProperty = [[PSDynamicsProperty alloc] init];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}
-(void)setScaleView:(UIView *)scaleView{
    _tableView.delegate = self;
    _scaleView = scaleView;
    _originalRect = scaleView.frame;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    _originalRect.size.width = screenWidth;
    scaleView.frame = _originalRect;
    _scaleCenterX = screenWidth/2.;
    
}
- (void)setModelArray:(NSArray *)modelArray
{
    NSAssert(self.cellClassName.length  > 0, @"Please register a cell class at first");
    if (_tableViewCell == nil) {
        _tableViewCell       = [[NSClassFromString(self.cellClassName) alloc]init];
        [_tableView registerClass:NSClassFromString(self.cellClassName) forCellReuseIdentifier:_cellReuseIdentifier];
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
            self.tableView.backgroundView = self.tipView;
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:modelArray];
            self.innerModelArray = mArray;
        }
    }else{
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:modelArray];
        self.innerModelArray = mArray;
    }
    if (self.innerModelArray.count > 0) {
        self.tableView.backgroundView = nil;
    }else{
        self.tableView.backgroundView = self.tipView;
    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
    
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
#pragma mark - dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isSection) {
        return self.innerModelArray.count;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_isSection) {
        id model = self.innerModelArray[section];
        NSArray *subArray = [model valueForKey:_keyPath];
        return subArray.count;
    }
    return self.innerModelArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    UITableViewCell *resultCell = nil;
    if (self.renderBlock) {
        resultCell = self.renderBlock(resultCell,indexPath,object);
        if (resultCell == nil) {
            resultCell = [tableView dequeueReusableCellWithIdentifier:_cellReuseIdentifier forIndexPath:indexPath];
            resultCell = self.renderBlock(resultCell,indexPath,object);
        }
    }
    [resultCell.contentView.layoutM applyLayoutPreservingOrigin:NO];
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return resultCell;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    CGFloat cellHeight = _rowHeight;
    if (cellHeight > 0) {
        return cellHeight;
    }
    if ([object respondsToSelector:@selector(PSRowHeight)] == NO) {
        [self.dynamicProperty addDynamicPropertyToObject:object propertyName:rowHeight type:PSDynamicPropertyTypeAssign];
    }
    cellHeight =  [self.dynamicProperty getFloatValueFromObject:object name:rowHeight];
    if (cellHeight > 0) {
        return cellHeight;
    }
    UITableViewCell *resultCell = _tableViewCell;
    if (self.renderBlock) {
        resultCell = self.renderBlock(resultCell,indexPath,object);
    };
    resultCell.contentView.layoutM.height = -1;
    [resultCell.contentView.layoutM applyLayoutPreservingOrigin:YES];
    cellHeight = resultCell.contentView.layoutM.height;
    [self.dynamicProperty setFloatValueToObject:object name:rowHeight value:cellHeight];
    return cellHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView      = nil;
    if (!self.headerViewBlock) {
        return headerView;
    }
    id model = nil;
    if (self.innerModelArray.count > section) {
        model = self.innerModelArray[section];
    }
    headerView = self.headerViewBlock(tableView,section,model);
    [headerView.contentView.layoutM applyLayoutPreservingOrigin:NO];
    return headerView;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//刷新数据时调用
    id model = nil;
    UITableViewHeaderFooterView *headerView      = nil;
    if (self.innerModelArray.count > section) {
        model = self.innerModelArray[section];
    }
    if (self.headerViewBlock) {
        headerView = self.headerViewBlock(tableView,section,model);
    }
    headerView.contentView.layoutM.height = -1;
    [headerView.contentView.layoutM applyLayoutPreservingOrigin:YES];
    CGFloat height = headerView.contentView.layoutM.height;
    return height;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UITableViewHeaderFooterView *footerView      = nil;
    if (!self.footerViewBlock) {
        return footerView;
    }
    id model = nil;
    if (self.innerModelArray.count > section) {
        model = self.innerModelArray[section];
    }
    footerView = self.footerViewBlock(tableView,section,model);
    [footerView.contentView.layoutM applyLayoutPreservingOrigin:NO];
    return footerView;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//刷新数据时调用
    id model = nil;
    UITableViewHeaderFooterView *footerView      = nil;
    if (self.innerModelArray.count > section) {
        model = self.innerModelArray[section];
    }
    if (self.footerViewBlock) {
        footerView = self.footerViewBlock(tableView,section,model);
    }
    footerView.contentView.layoutM.height = -1;
    [footerView.contentView.layoutM applyLayoutPreservingOrigin:YES];
    return footerView.contentView.layoutM.height;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.selectedCellBlock) {
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
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectedCellBlock(cell, indexPath, object);
    }
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
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
    NSArray *array = @[];
    if (self.editActionsForRowAtIndexPathBlock) {
        
        array = self.editActionsForRowAtIndexPathBlock(tableView,indexPath,object);
    }
    return array;
}
/**
 集成UITableView上下拉刷新
 */
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
        [_tableView willChangeValueForKey:MUFootKeyPath];
        [_tableView addSubview:_refreshFooter];
        [_tableView didChangeValueForKey:MUFootKeyPath];
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
        [_tableView willChangeValueForKey:MUHeadKeyPath];
        [_tableView addSubview:_refreshHeader];
        [_tableView didChangeValueForKey:MUHeadKeyPath];
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
- (UIImage *)nomalSnapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.scaleView.frame.size, NO, [UIScreen mainScreen].scale);
    [self.scaleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (UIImageView *)snapshotImageView{
    if (!_snapshotImageView) {
        _snapshotImageView = [[UIImageView alloc]init];
    }
    return  _snapshotImageView;
}
/**
 处理UIScrollView滚动
 */
#pragma mark - scroll
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.scaleView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if(offsetY <= 0)
        {
            if (!self.snapshotImage) {
                self.snapshotImage = [self nomalSnapshotImage];
                self.snapshotImageView.image = self.snapshotImage;
                self.snapshotImageView.frame = self.scaleView.frame;
                [self.scaleView addSubview:self.snapshotImageView];
                [self.scaleView bringSubviewToFront:self.snapshotImageView];
            }
            CGFloat totalOffset = CGRectGetHeight(_originalRect) + fabs(offsetY);
            CGFloat f = totalOffset / CGRectGetHeight(_originalRect);
            CGRect rect = self.snapshotImageView.frame;
            rect.origin.y = offsetY - .2;
            rect.size     = CGSizeMake(CGRectGetWidth(_originalRect) * f, CGRectGetHeight(_originalRect) - offsetY);
            self.snapshotImageView.frame = rect;
            CGPoint point = self.snapshotImageView.center;
            point.x = self.scaleCenterX;
            self.snapshotImageView.center = point;
            if (@available(iOS 11.0, *)) {
            }else{
                self.snapshotImageView.translatesAutoresizingMaskIntoConstraints = NO;
            }
            if (offsetY == 0) {
                [self.snapshotImageView removeFromSuperview];
                self.snapshotImage = nil;
            }
        }
    }
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
        if (self.tableView.backgroundView) {
            _tipView.frame = self.tableView.backgroundView.bounds;
            [self.tableView.backgroundView addSubview:_tipView];
        }else{
            self.tableView.backgroundView = _tipView;
        }
    }
    return _tipView;
}
- (void)clearData{
    _tableView.backgroundView  =self.tipsView;
    self.innerModelArray = [NSMutableArray array];
    [_tableView reloadData];
}
- (CGFloat)totalCellHeight{
    CGFloat totalHeight = 0;
    if (_isSection) {//拆解模型
        for (NSUInteger j = 0; j < self.innerModelArray.count; j++) {
            id innerObject = self.innerModelArray[j];
            NSArray *subArray = [innerObject valueForKey:_keyPath];
            for (NSUInteger i = 0; i < subArray.count; i++) {
                id object = subArray[i];
                CGFloat cellHeight = 0;
                if ([object respondsToSelector:@selector(PSRowHeight)] == NO) {
                    [self.dynamicProperty addDynamicPropertyToObject:object propertyName:rowHeight type:PSDynamicPropertyTypeAssign];
                }
                cellHeight =  [self.dynamicProperty getFloatValueFromObject:object name:rowHeight];
                if (cellHeight == 0) {
                    UITableViewCell *resultCell = _tableViewCell;
                    if (self.renderBlock) {
                        resultCell = self.renderBlock(resultCell,[NSIndexPath indexPathForRow:0 inSection:i],object);
                    };
                    resultCell.contentView.layoutM.height = -1;
                    [resultCell.contentView.layoutM applyLayoutPreservingOrigin:YES];
                    cellHeight = resultCell.contentView.layoutM.height;
                    [self.dynamicProperty setFloatValueToObject:object name:rowHeight value:cellHeight];
                }
                totalHeight += cellHeight;
            }
        }
    }else{
        CGFloat cellHeight = 0;
        for (NSUInteger i = 0; i < self.innerModelArray.count; i++) {
            id object = self.innerModelArray[i];
            if ([object respondsToSelector:@selector(PSRowHeight)] == NO) {
                [self.dynamicProperty addDynamicPropertyToObject:object propertyName:rowHeight type:PSDynamicPropertyTypeAssign];
            }
            cellHeight =  [self.dynamicProperty getFloatValueFromObject:object name:rowHeight];
            if (cellHeight == 0) {
                UITableViewCell *resultCell = _tableViewCell;
                if (self.renderBlock) {
                    resultCell = self.renderBlock(resultCell,[NSIndexPath indexPathForRow:0 inSection:i],object);
                };
                resultCell.contentView.layoutM.height = -1;
                [resultCell.contentView.layoutM applyLayoutPreservingOrigin:YES];
                cellHeight = resultCell.contentView.layoutM.height;
                [self.dynamicProperty setFloatValueToObject:object name:rowHeight value:cellHeight];
            }
            totalHeight += cellHeight;
        }
        
        
    }
    return totalHeight;
    
}

#pragma clang diagnostic pop
@end
