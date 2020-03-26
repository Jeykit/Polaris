//
//  LayoutManager.m
//  Expecta
//
//  Created by Jekity on 2019/7/11.
//

#import "LayoutManager+Private.h"
#import "UIView+LayoutManager.h"

typedef NS_ENUM(NSUInteger, viewStyle) {
    viewStyleDefalue,
    viewStyleImageView,
    viewStyleLabel,
    viewStyleButton,
};

@interface LayoutManager()

@property (nonatomic, weak, readonly) UIView *view;
@property (nonatomic, strong) NSArray<LayoutManager *> *childNodes;
@property (nonatomic, strong) NSArray<LayoutManager *> *splitNodes;
@property (nonatomic, weak) LayoutManager *parentNode;
@property (nonatomic, assign) viewStyle style;
@property (nonatomic, assign) CGFloat computeFlexGrow;
@property (nonatomic, assign) CGFloat computeFlexShrik;
@property (nonatomic, assign) CGFloat surplus;
@end

@implementation LayoutManager
- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init]) {
        _view = view;
        _isEnabled = NO;
        _isIncludedInLayout = YES;
        _flexDirection = PSFlexDirectionRow;
        _computeFlexGrow = 0;
        _computeFlexShrik = 0;
        _surplus = 0;
        _fitSizeSelf = YES;
        if ([view isKindOfClass:[UILabel class]])
        {
            _style = viewStyleLabel;
        }else if ([view isKindOfClass:[UIImageView class]])
        {
            _style = viewStyleImageView;
        }else if ([view isKindOfClass:[UIButton class]]){
            _style = viewStyleButton;
        }
        else
        {
            _style = viewStyleDefalue;
        }
    }
    return self;
}
- (void)setPadding:(CGFloat)padding{
    _padding = padding;
    _paddingTop = padding;
    _paddingLeft = padding;
    _paddingRight = padding;
    _paddingBottom = padding;
}
- (void)setHidden:(BOOL)hidden{
    _hidden = hidden;
    if (hidden == YES) {
        self.isEnabled = NO;
        self.view.hidden = YES;
    }else{
        self.isEnabled = YES;
        self.view.hidden = NO;
    }
}
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
{
    [self calculateLayoutWithNode:self];
    [self calculateLayoutFrameWithNode:self];
    PolarisApplyLayoutToViewHierarchy(self.view, preserveOrigin);
}
- (void)calculateLayoutFrameWithNode:(LayoutManager *)node
{
    PSFlexDirection flexDirection = node.flexDirection;
    PSFlexJustify justifyContent = node.justifyContent;
    PSFlexAlign flexAlign = node.align_items;
    LayoutManager *previousNode = nil;
    LayoutManager *prevousMaxNode = nil;
    CGFloat surplus = 0;
    if (node.flexWrap == PSFlexWrapWrap) {
        LayoutManager *copyNode = [node copy];
        for (NSArray *childArray in node.splitNodes) {
            copyNode.childNodes = childArray;
            previousNode = nil;
            LayoutManager *maxNode = nil;
            CGFloat margain = [self getMargainWithNode:copyNode];
            if (flexDirection == PSFlexDirectionRow) {
                surplus = node.height - [self getChildNodesHeight:copyNode] - margain + [self getVerticalMargin:copyNode];
                maxNode = [self getChildNodesMaxHeight:copyNode];
            }else{
                surplus = node.width - [self getChildNodesWidth:copyNode] - margain + [self getHorizontalMargin:copyNode];
                maxNode = [self getChildNodesMaxWidth:copyNode];
            }
            for (LayoutManager *childNode in copyNode.childNodes) {
                CGFloat left = [self computerLeftValueWithNode:childNode previousNode:previousNode maxNode:maxNode previousMaxNode:prevousMaxNode parentNode:node flexDirection:flexDirection justifyContent:justifyContent surplus:surplus];
                CGFloat top = [self computerTopValueWithNode:childNode previousNode:previousNode maxNode:maxNode previousMaxNode:prevousMaxNode parentNode:node flexDirection:flexDirection justifyContent:justifyContent surplus:surplus];
                childNode.left = left;
                childNode.top = top;
                previousNode = childNode;
            }
            prevousMaxNode  = maxNode;
            if (flexDirection == PSFlexDirectionRow) {
                surplus = (flexAlign == PSFlexAlignEnd)?(node.height - [self getChildNodesHeight:copyNode] - margain + [self getVerticalMargin:copyNode]):0;
            }else{
                surplus = (flexAlign == PSFlexAlignEnd)?(node.width - [self getChildNodesWidth:copyNode] - margain + [self getHorizontalMargin:copyNode]):0;
            }
            [self fitAlign_Items:copyNode flexDirection:flexDirection flexAlign:flexAlign surplusValue:surplus wrap:YES];
            [self fitJustifyContentAround:copyNode flexDirection:flexDirection justifyContent:justifyContent];
        }
    }else{
        CGFloat margain = [self getMargainWithNode:node];
        if (flexDirection == PSFlexDirectionColumn) {
            surplus = node.height - [self getChildNodesHeight:node] - margain + [self getVerticalMargin:node];
        }else{
            surplus = node.width - [self getChildNodesWidth:node] - margain + [self getHorizontalMargin:node];
        }
        for (LayoutManager *childNode in node.childNodes) {
            if (node.computeFlexShrik > 0 && surplus < 0) {
                childNode.width += (flexDirection == PSFlexDirectionRow)?(surplus * childNode.flexShrik / node.computeFlexShrik):0;
                childNode.height += (flexDirection == PSFlexDirectionColumn)?(surplus * childNode.flexShrik / node.computeFlexShrik):0;
            }
            if (childNode.flexShrik > 0) {
                CGFloat surplusTemp = (flexDirection == PSFlexDirectionColumn)?(node.width - childNode.width - (node.paddingLeft + node.marginLeft) - (node.paddingRight + childNode.marginRight)):(node.height - childNode.height - (node.paddingTop + node.marginTop) - (node.paddingBottom + childNode.marginBottom));
                if (surplusTemp < 0) {
                    childNode.width += (flexDirection == PSFlexDirectionColumn)?surplusTemp:0;
                    childNode.height += (flexDirection == PSFlexDirectionRow)?surplusTemp:0;
                }
            }
            CGFloat left = [self computerLeftValueWithNode:childNode previousNode:previousNode maxNode:nil previousMaxNode:nil parentNode:node flexDirection:flexDirection justifyContent:justifyContent surplus:surplus];
            CGFloat top = [self computerTopValueWithNode:childNode previousNode:previousNode maxNode:nil previousMaxNode:nil parentNode:node flexDirection:flexDirection justifyContent:justifyContent surplus:surplus];
            childNode.left  = left;
            childNode.top = top;
            previousNode = childNode;
        }
        if (flexDirection == PSFlexDirectionRow) {
            surplus = (flexAlign == PSFlexAlignEnd)?(node.height - [self getChildNodesHeight:node] - margain + [self getVerticalMargin:node]):0;
        }else{
            surplus = (flexAlign == PSFlexAlignEnd)?(node.width - [self getChildNodesWidth:node] - margain + [self getHorizontalMargin:node]):0;
        }
        [self fitAlign_Items:node flexDirection:flexDirection flexAlign:flexAlign surplusValue:surplus wrap:NO];
        [self fitJustifyContentAround:node flexDirection:flexDirection justifyContent:justifyContent];
    }
    for (LayoutManager *childNode in node.childNodes) {
        [self calculateLayoutFrameWithNode:childNode];
    }
}

- (CGFloat)getAlign_ItemsWidthWithWrap:(LayoutManager *)node
                         flexDirection:(PSFlexDirection)flexDirection
                             flexAlign:(PSFlexAlign)flexAlign
{
    if (flexAlign == PSFlexAlignDefalut) {
        return 0;
    }
    CGFloat width = 0;
    CGFloat height = 0;
    LayoutManager *previousMaxNode = nil;
    for (NSArray *childArray in node.splitNodes) {
        LayoutManager *copyNode = [node copy];
        copyNode.childNodes = childArray;
        LayoutManager* maxNode = (flexDirection == PSFlexDirectionColumn)?[self getChildNodesMaxWidth:copyNode]:[self getChildNodesMaxHeight:node];
        CGFloat margin = 0;
        if ( flexDirection == PSFlexDirectionColumn) {
            margin = [self getMaxMargin:maxNode previousNode:previousMaxNode flexDirection:PSFlexDirectionRow];
        }else{
            margin = [self getMaxMargin:maxNode previousNode:previousMaxNode flexDirection:PSFlexDirectionColumn];
        }
        width += margin + maxNode.width - ((previousMaxNode != nil)?0:(maxNode.marginLeft));
        height += margin + maxNode.height - ((previousMaxNode != nil)?0:(maxNode.marginTop));
    }
    CGFloat surplus = 0;
    if (flexDirection == PSFlexDirectionColumn) {
        surplus = node.width - width;
    }else{
        surplus = node.height - height;
    }
    return surplus;
}
- (void)fitAlign_Items:(LayoutManager *)node
         flexDirection:(PSFlexDirection)flexDirection
             flexAlign:(PSFlexAlign)flexAlign
          surplusValue:(CGFloat)surplusValue
                  wrap:(BOOL)wrap
{
    if (flexAlign == PSFlexAlignDefalut) {
        return ;
    }
    LayoutManager *tempNode = nil;
    switch (flexAlign) {
        case PSFlexAlignStart:
            tempNode = (flexDirection == PSFlexDirectionColumn)?[self getChildNodesMinWidth:node]:[self getChildNodesMinHeight:node];
            break;
        case PSFlexAlignCenter:
            tempNode = (flexDirection == PSFlexDirectionColumn)?[self getChildNodesMaxWidth:node]:[self getChildNodesMaxHeight:node];
            break;
        default:
            break;
    }
    CGFloat surplus = 0;
    for (LayoutManager *childNode in node.childNodes) {
        switch (flexAlign) {
            case PSFlexAlignStart:
                childNode.left = (flexDirection == PSFlexDirectionColumn)?tempNode.left:childNode.left;
                childNode.top = (flexDirection == PSFlexDirectionRow)?tempNode.top:childNode.top;
                break;
            case PSFlexAlignEnd:
            {
                childNode.left = (flexDirection == PSFlexDirectionColumn)?(surplusValue - childNode.marginRight - node.parentNode.paddingRight + childNode.left):childNode.left;
                childNode.top = (flexDirection == PSFlexDirectionRow)?(surplusValue - childNode.marginBottom - node.parentNode.paddingBottom + childNode.top):childNode.top;
            }
                break;
            case PSFlexAlignCenter:
            {
                if (wrap == YES) {
                    childNode.left = (flexDirection == PSFlexDirectionColumn)?(tempNode.left - (tempNode.width - childNode.width )/ 2.):childNode.left;
                    childNode.top = (flexDirection == PSFlexDirectionRow)?(tempNode.top - (tempNode.height - childNode.height )/ 2.):childNode.top;
                }else
                {
                    surplus = (flexDirection == PSFlexDirectionColumn)?(node.width - childNode.width):(node.height - childNode.height);
                    childNode.left = (flexDirection == PSFlexDirectionColumn)?(surplus / 2.):childNode.left;
                    childNode.top = (flexDirection == PSFlexDirectionRow)?(surplus / 2.):childNode.top;
                    
                }
                
            }
                break;
            default:
                break;
        }
    }
}
- (void)fitJustifyContentAround:(LayoutManager *)parentNode
                  flexDirection:(PSFlexDirection)flexDirection
                 justifyContent:(PSFlexJustify)justifyContent
{
    if (justifyContent == PSFlexJustifyStartAround) {
        LayoutManager *node = parentNode.childNodes.lastObject;
        node.left = (flexDirection == PSFlexDirectionRow)?(parentNode.width - node.width - parentNode.paddingRight - node.marginRight):node.left;
        node.top = (flexDirection == PSFlexDirectionColumn)?(parentNode.height - node.height - parentNode.paddingBottom - node.marginBottom):node.top;
    }
    if (justifyContent == PSFlexJustifyEndAround) {
        LayoutManager *node = parentNode.childNodes.firstObject;
        node.left = (flexDirection == PSFlexDirectionRow)?(parentNode.paddingLeft + node.marginLeft):node.left;
        node.top = (flexDirection == PSFlexDirectionColumn)?(parentNode.paddingTop + node.marginTop):node.top;
    }
    
}
- (CGFloat)getHorizontalMargin:(LayoutManager *)node
{
    CGFloat margin = 0;
    margin = node.childNodes.firstObject.marginLeft + node.childNodes.lastObject.marginRight;
    margin += (node.paddingLeft + node.paddingRight);
    return margin;
}
- (CGFloat)getVerticalMargin:(LayoutManager *)node
{
    CGFloat margin = 0;
    margin = node.childNodes.firstObject.marginTop + node.childNodes.lastObject.marginBottom;
    margin += (node.paddingTop+ node.paddingBottom);
    return margin;
}
- (void)calculateLayoutWithNode:(LayoutManager *)node
{
    NSAssert([NSThread isMainThread], @"LayoutManager calculation PSst be done on main.");
    NSAssert(self.isEnabled, @"LayoutManager is not enabled for this view.");
    PolarisAttachNodesFromViewHierachy(self.view);
    [self calculateLayoutSizeWithNode:self];
}
- (void)calculateLayoutSizeWithNode:(LayoutManager *)node
{
    if (node.flexWrap == PSFlexWrapWrap) {
        [self calculateLayoutSizeWithWarp:node];
    }else{
        [self calculateLayoutSizeWithNOWarp:node];
    }
    for (LayoutManager *childNode in node.childNodes) {
        [self calculateLayoutSizeWithNode:childNode];
    }
}
- (void)calculateLayoutSizeWithWarp:(LayoutManager *)node
{
    CGFloat computeHeight = 0;
    CGFloat computeWidth = 0;
    CGFloat marginVertical = node.paddingTop + node.paddingBottom;
    CGFloat marginHorizontal = node.paddingLeft + node.paddingRight;
    PSFlexDirection flexDirection = node.flexDirection;
    LayoutManager *previousNode = nil;
    NSUInteger totalCount = node.childNodes.count;
    NSUInteger flexCount = node.flexCount;;
    NSMutableArray *splitArray = [NSMutableArray arrayWithCapacity:totalCount];
    NSUInteger splitIndex = 0;
    if (flexCount > 0) {
        NSUInteger row = totalCount / flexCount;
        if (totalCount % flexCount) {
            row += 1;
        }
        for (NSUInteger i = 0; i < row; i ++) {
            NSUInteger childCount = (i + 1) * flexCount;
            NSUInteger contentCont = flexCount;
            if (childCount > totalCount) {
                contentCont -= (childCount - totalCount);
            }
            NSArray *childArray = [node.childNodes subarrayWithRange:NSMakeRange(i * flexCount, contentCont)];
            NSUInteger childArrayCount = childArray.count;
            [splitArray addObject:childArray];
            for (NSUInteger i = 0; i < childArrayCount; i ++) {
                LayoutManager *childNode = childArray[i];
                CGSize childSize = [self calculateLeafNodeSize:childNode];
                if (childSize.width < 0 || childSize.height < 0) {
                    childNode.width = childSize.width;
                    childNode.height = childSize.height;
                    [self calculateLayoutSizeWithNode:childNode];
                    childSize.width = childNode.width;
                    childSize.height = childNode.height;
                }else{
                    childNode.width = childSize.width;
                    childNode.height = childSize.height;
                }
            }
        }
    }else{
        if (flexDirection == PSFlexDirectionRow) {
            for (NSUInteger i = 0; i < totalCount; i ++) {
                LayoutManager *childNode = node.childNodes[i];
                CGSize childSize = [self calculateLeafNodeSize:childNode];
                if (childSize.width < 0 || childSize.height < 0) {
                    [self calculateLayoutSizeWithNode:childNode];
                    childSize.width = childNode.width;
                    childSize.height = childNode.height;
                }else{
                    childNode.width = childSize.width;
                    childNode.height = childSize.height;
                }
                computeWidth += childSize.width + [self getMaxMargin:childNode previousNode:previousNode flexDirection:flexDirection];
                CGFloat margin = node.width - marginVertical - i * node.margin;
                if (computeWidth > margin) {
                    if (node.flexNumberOfLine == 0 || node.flexNumberOfLine > splitArray.count) {
                        NSMutableArray * childArray = [NSMutableArray array];
                        [childArray addObjectsFromArray:[node.childNodes subarrayWithRange:NSMakeRange(splitIndex, i - splitIndex)]];
                        [splitArray addObject:childArray];
                        splitIndex = i;
                        previousNode = nil;
                        computeWidth = childSize.height + [self getMaxMargin:childNode previousNode:previousNode flexDirection:flexDirection];
                    }
                }
                if (node.flexNumberOfLine > 0 && node.flexNumberOfLine == splitArray.count) {
                    childNode.isEnabled = NO;
                }
                previousNode = childNode;
            }
            if (splitIndex < totalCount) {
                if (node.flexNumberOfLine == 0 || node.flexNumberOfLine > splitArray.count) {
                    NSMutableArray * childArray = [NSMutableArray array];
                    [childArray addObjectsFromArray:[node.childNodes subarrayWithRange:NSMakeRange(splitIndex, totalCount - splitIndex)]];
                    [splitArray addObject:childArray];
                }
            }
        }else{
            for (NSUInteger i = 0; i < totalCount; i ++) {
                LayoutManager *childNode = node.childNodes[i];
                CGSize childSize = [self calculateLeafNodeSize:childNode];
                if (childSize.width < 0 || childSize.height < 0) {
                    [self calculateLayoutSizeWithNode:childNode];
                    childSize.width = childNode.width;
                    childSize.height = childNode.height;
                }else{
                    childNode.width = childSize.width;
                    childNode.height = childSize.height;
                }
                computeHeight += childSize.height + [self getMaxMargin:childNode previousNode:previousNode flexDirection:flexDirection];
                CGFloat margin = node.height - marginVertical - i * node.margin;
                if (computeHeight > margin) {
                    if (node.flexNumberOfLine == 0 || node.flexNumberOfLine > splitArray.count) {
                        NSMutableArray * childArray = [NSMutableArray array];
                        [childArray addObjectsFromArray:[node.childNodes subarrayWithRange:NSMakeRange(splitIndex, i - splitIndex)]];
                        [splitArray addObject:childArray];
                        splitIndex = i;
                        previousNode = nil;
                        computeHeight = childSize.height + [self getMaxMargin:childNode previousNode:previousNode flexDirection:flexDirection];
                    }
                }
                if (node.flexNumberOfLine > 0 && node.flexNumberOfLine == splitArray.count) {
                    childNode.isEnabled = NO;
                }
                previousNode = childNode;
            }
            if (splitIndex < totalCount) {
                if (node.flexNumberOfLine == 0 || node.flexNumberOfLine > splitArray.count) {
                    
                    NSMutableArray * childArray = [NSMutableArray array];
                    [childArray addObjectsFromArray:[node.childNodes subarrayWithRange:NSMakeRange(splitIndex, totalCount - splitIndex)]];
                    [splitArray addObject:childArray];
                }
            }
            
        }
    }
    node.splitNodes = splitArray;
    NSUInteger splitCount = splitArray.count;
    node.surplus = 0;
    node.computeFlexGrow = 0;
    
    previousNode  = nil;
    computeWidth  = 0;
    computeHeight = 0;
    if (node.width < 0) {
        LayoutManager *copyNode = [node copy];
        for (NSArray *childArray in node.splitNodes) {
            copyNode.childNodes = childArray;
            LayoutManager *maxNode = [self getChildNodesMaxWidth:copyNode];
            computeWidth += maxNode.width + [self getMaxMargin:maxNode previousNode:previousNode flexDirection:PSFlexDirectionRow];
            previousNode = maxNode;
        }
        node.width = computeWidth  + ((splitCount == 0)?0:((splitCount - 1) * node.margin +marginHorizontal));
    }
    if (node.height < 0) {
        LayoutManager *copyNode = [node copy];
        for (NSArray *childArray in node.splitNodes) {
            copyNode.childNodes = childArray;
            LayoutManager *maxNode = [self getChildNodesMaxWidth:copyNode];
            computeHeight += maxNode.height + [self getMaxMargin:maxNode previousNode:previousNode flexDirection:PSFlexDirectionColumn];
            previousNode = maxNode;
        }
        node.height = computeHeight + ((splitCount == 0)?0:((splitCount - 1) * node.margin +marginVertical));
    }
    
}
- (void)calculateLayoutSizeWithNOWarp:(LayoutManager *)node
{
    CGFloat computeHeight = 0;
    CGFloat computeWidth = 0;
    PSFlexDirection flexDirection = node.flexDirection;
    CGFloat margain = [self getMargainWithNode:node];
    NSUInteger totalCount = node.childNodes.count;
    LayoutManager *previousNode = nil;
    for (NSUInteger i = 0; i < totalCount; i++) {
        LayoutManager *childNode = node.childNodes[i];
        CGSize childSize = [self calculateLeafNodeSize:childNode];
        if (childSize.width < 0 || childSize.height < 0) {
            childNode.width = childSize.width;
            childNode.height = childSize.height;
            [self calculateLayoutSizeWithNode:childNode];
            childSize.width = childNode.width;
            childSize.height = childNode.height;
        }else{
            childNode.width = childSize.width;
            childNode.height = childSize.height;
        }
        if (flexDirection == PSFlexDirectionColumn) {
            if (childSize.width > computeWidth) {
                computeWidth = childSize.width;
            }
            computeHeight += childSize.height;
        }else{
            if (childSize.height > computeHeight) {
                computeHeight = childSize.height;
            }
            computeWidth += childSize.width;
        }
        
        previousNode = childNode;
    }
    if (node.height < 0) {
        node.height = computeHeight + ((flexDirection == PSFlexDirectionRow)?(node.paddingTop + node.paddingBottom + previousNode.marginTop + previousNode.marginBottom):margain);
    }
    if (node.width < 0) {
        node.width = computeWidth + ((flexDirection == PSFlexDirectionColumn)?(node.paddingLeft + node.paddingRight + previousNode.marginLeft + previousNode.marginRight):margain);
    }
}
- (CGFloat)getMargainWithNode:(LayoutManager *)node
{
    CGFloat margain = 0;
    NSUInteger count = node.childNodes.count;
    if (node.flexDirection == PSFlexDirectionColumn) {
        margain = node.paddingTop + node.paddingBottom + ((count == 0)?0:(count - 1) * node.margin);
        LayoutManager *previousNode = nil;
        for (LayoutManager *childNode in node.childNodes) {
            CGFloat gap = [self getMaxMargin:childNode previousNode:previousNode flexDirection:node.flexDirection];
            margain += gap;
            previousNode = childNode;
        }
        margain += previousNode.marginBottom;
    }else{
        margain = node.paddingLeft + node.paddingRight + ((count == 0)?0:(count - 1) * node.margin);
        LayoutManager *previousNode = nil;
        for (LayoutManager *childNode in node.childNodes) {
            CGFloat gap = [self getMaxMargin:childNode previousNode:previousNode flexDirection:node.flexDirection];
            margain += gap;
            previousNode = childNode;
        }
        margain += previousNode.marginRight;
    }
    return margain;
}
- (CGFloat)getMaxMargin:(LayoutManager *)node
           previousNode:(LayoutManager *)preiviousNode
          flexDirection:(PSFlexDirection)flexDirection
{
    CGFloat margin = 0;
    if (flexDirection == PSFlexDirectionRow) {
        CGFloat max = 0;
        if (preiviousNode.marginRight == 0) {
            max = node.marginLeft;
        }else if (node.marginLeft == 0){
            max = preiviousNode.marginRight;
        }else{
            max =  MAX(preiviousNode.marginRight, node.marginLeft);
        }
        margin = (preiviousNode != nil)?max:node.marginLeft;
    }else{
        CGFloat max = 0;
        if (preiviousNode.marginBottom == 0) {
            max = node.marginTop;
        }else if (node.marginTop == 0){
            max = preiviousNode.marginBottom;
        }else{
            max =  MAX(preiviousNode.marginBottom, node.marginTop);
        }
        margin = (preiviousNode != nil)?max:node.marginTop;
    }
    return margin;
}
- (CGSize)calculateLeafNodeSize:(LayoutManager *)leafNode
{
    
    CGSize nodeSize = CGSizeZero;
    nodeSize.width  = leafNode.width;
    nodeSize.height = leafNode.height;
    
    if (nodeSize.width > 0 && nodeSize.height == 0 ) {
        nodeSize.height = (leafNode.aspectRatio == 0)?nodeSize.height : (nodeSize.width / leafNode.aspectRatio);
    }
    
    if (nodeSize.height > 0 && nodeSize.width == 0 ) {
        nodeSize.width = (leafNode.aspectRatio == 0)?nodeSize.width : (nodeSize.height * leafNode.aspectRatio);
    }
    if (nodeSize.width > 0 && nodeSize.height > 0) {
        return nodeSize;
    }
    if (leafNode.style == viewStyleLabel && leafNode.fitSizeSelf == NO) {
        CGSize fitSize = [leafNode.view sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        nodeSize.width = fitSize.width;
        nodeSize.height = fitSize.height;
    }
    if (nodeSize.width > 0 && nodeSize.height > 0) {
        return nodeSize;
    }
    LayoutManager *parentNode = leafNode.parentNode;
    if (nodeSize.width == 0) {
        if (parentNode.width > 0) {
            CGFloat value = [self fitFlexGrowWithNode:leafNode parentNode:parentNode flexDirection:parentNode.flexDirection];
            if (parentNode.flexDirection == PSFlexDirectionColumn) {
                nodeSize.height += value;
            }else{
                nodeSize.width += value;
            }
            if (nodeSize.width == 0) {
                if (parentNode.childNodes.count == 1 || (parentNode.flexDirection == PSFlexDirectionColumn && parentNode.flexWrap != PSFlexWrapWrap)) {
                    if (parentNode.paddingLeft >= 0 && parentNode.paddingRight >= 0) {
                        nodeSize.width = parentNode.width - parentNode.paddingLeft - parentNode.paddingRight - leafNode.marginLeft - leafNode.marginRight;
                    }
                   
                }
            }
            
            if (leafNode.aspectRatio > 0 && nodeSize.width > 0) {
                nodeSize.height = nodeSize.width / leafNode.aspectRatio;
            }
        }
    }
    if (nodeSize.height == 0) {
        if (parentNode.height > 0) {
            
            CGFloat value = [self fitFlexGrowWithNode:leafNode parentNode:parentNode flexDirection:parentNode.flexDirection];
            if (parentNode.flexDirection == PSFlexDirectionColumn) {
                nodeSize.height += value;
            }else{
                nodeSize.width += value;
            }
            if (nodeSize.height == 0) {
                if (parentNode.childNodes.count == 1 || (parentNode.flexDirection == PSFlexDirectionRow && parentNode.flexWrap != PSFlexWrapWrap)) {
                    if (parentNode.paddingTop >= 0 && parentNode.paddingBottom >= 0) {
                        nodeSize.height = parentNode.height - parentNode.paddingTop - parentNode.paddingBottom - leafNode.marginTop- leafNode.marginBottom;
                    }
                    
                    
                }
            }
            if (leafNode.aspectRatio > 0 && nodeSize.height > 0) {
                nodeSize.width = nodeSize.height * leafNode.aspectRatio;
            }
            
        }
    }
    if (nodeSize.width > 0 && nodeSize.height > 0) {
        return nodeSize;
    }
    if (leafNode.style == viewStyleImageView) {
        UIImageView *imageView = (UIImageView *)leafNode.view;
        UIImage *image = imageView.image;
        if (leafNode.fitSizeSelf == NO) {
            if (image != nil && nodeSize.width == 0) {
                nodeSize.width = image.size.width;
            }
            if (image != nil && nodeSize.height == 0) {
                nodeSize.height = image.size.height;
            }
        }else{
            nodeSize.width =  (image != nil)?image.size.width : nodeSize.width;
            nodeSize.height = (image != nil)?image.size.height : nodeSize.height;
        }
        return nodeSize;
    }
    if (nodeSize.width <=0 ) {
        nodeSize.width = (leafNode.style == viewStyleDefalue)?nodeSize.width : MAXFLOAT;
    }
    if (nodeSize.height <=0 ) {
        nodeSize.height = (leafNode.style == viewStyleDefalue)?nodeSize.height : MAXFLOAT;
    }
    if (nodeSize.width < 0 || nodeSize.height < 0) {
        return nodeSize;
    }
    CGSize fitSize = [leafNode.view sizeThatFits:nodeSize];
    if (nodeSize.width > 0 && nodeSize.width != MAXFLOAT) {
        fitSize.width = nodeSize.width;
    }
    if (nodeSize.height > 0 && nodeSize.height != MAXFLOAT) {
        fitSize.height = nodeSize.height;
    }
    return fitSize;
}
- (CGFloat)fitFlexGrowWithNode:(LayoutManager *)node
                    parentNode:(LayoutManager *)parentNode
                 flexDirection:(PSFlexDirection)flexDirection
{
    CGFloat value = 0;
    if (parentNode.computeFlexGrow > 0) {
        if (flexDirection == PSFlexDirectionColumn) {
            
            if (parentNode.surplus == 0) {
                CGFloat margain = [self getMargainWithNode:parentNode];
                CGFloat height = [self getChildNodesHeight:parentNode];
                CGFloat surplusHeight = parentNode.height - margain - height;
                parentNode.surplus = surplusHeight;
                if (surplusHeight > 0) {
                    value = surplusHeight * node.flexGrow / parentNode.computeFlexGrow;
                    node.flexGrow = 0;
                }
            }else{
                CGFloat surplusHeight = parentNode.surplus;
                if (surplusHeight > 0) {
                    value = surplusHeight * node.flexGrow / parentNode.computeFlexGrow;
                    node.flexGrow = 0;
                }
            }
        }else{
            if (parentNode.surplus == 0) {
                CGFloat margain = [self getMargainWithNode:parentNode];
                CGFloat width = [self getChildNodesWidth:parentNode];
                CGFloat surplusWidth = parentNode.width - margain - width;
                parentNode.surplus = surplusWidth;
                if (surplusWidth > 0) {
                    value = surplusWidth * node.flexGrow / parentNode.computeFlexGrow;
                    node.flexGrow = 0;
                }
            }else{
                CGFloat surplusWidth = parentNode.surplus;
                if (surplusWidth > 0) {
                    value = surplusWidth * node.flexGrow / parentNode.computeFlexGrow;
                    node.flexGrow = 0;
                }
            }
        }
    }else{
        if (parentNode.flexCount > 0) {
            if (flexDirection == PSFlexDirectionColumn) {
                
                if (parentNode.surplus == 0) {
                    LayoutManager *copyNode = [parentNode copy];
                    if (parentNode.childNodes.count >= parentNode.flexCount) {
                        NSArray *childArray = [node.childNodes subarrayWithRange:NSMakeRange(0, parentNode.flexCount)];
                        copyNode.childNodes = childArray;
                    }else{
                        NSMutableArray *mArray = [NSMutableArray arrayWithArray:parentNode.childNodes];
                        NSUInteger count = parentNode.flexCount - parentNode.childNodes.count;
                        for (NSUInteger i = 0; i < count; i++) {
                            LayoutManager *tempNode = [[LayoutManager alloc]init];
                            [mArray addObject:tempNode];
                        }
                    }
                    CGFloat margain = [self getMargainWithNode:copyNode] - [self getVerticalMargin:copyNode];
                    CGFloat surplusHeight = (parentNode.height - margain)/parentNode.flexCount;
                    parentNode.surplus = surplusHeight;
                    if (surplusHeight > 0) {
                        value = surplusHeight;
                    }
                }else{
                    CGFloat surplusHeight = parentNode.surplus;
                    if (surplusHeight > 0) {
                        value = surplusHeight;
                    }
                }
            }else{
                if (parentNode.surplus == 0) {
                    LayoutManager *copyNode = [parentNode copy];
                    if (parentNode.childNodes.count >= parentNode.flexCount) {
                        NSArray *childArray = [parentNode.childNodes subarrayWithRange:NSMakeRange(0, parentNode.flexCount)];
                        copyNode.childNodes = childArray;
                    }else{
                        NSMutableArray *mArray = [NSMutableArray arrayWithArray:parentNode.childNodes];
                        NSUInteger count = parentNode.flexCount - parentNode.childNodes.count;
                        for (NSUInteger i = 0; i < count; i++) {
                            LayoutManager *tempNode = [[LayoutManager alloc]init];
                            [mArray addObject:tempNode];
                        }
                        copyNode.childNodes = mArray;
                    }
                    CGFloat margain = [self getMargainWithNode:copyNode] - [self getVerticalMargin:copyNode];
                    CGFloat surplusWidth = (parentNode.width - margain)/parentNode.flexCount;
                    parentNode.surplus = surplusWidth;
                    if (surplusWidth > 0) {
                        value = surplusWidth;
                    }
                }else{
                    CGFloat surplusWidth = parentNode.surplus;
                    if (surplusWidth > 0) {
                        value = surplusWidth;
                    }
                }
            }
        }
    }
    return value;
}
- (CGFloat)computerLeftValueWithNode:(LayoutManager *)node
                        previousNode:(LayoutManager *)previousNode
                             maxNode:(LayoutManager *)maxNode
                     previousMaxNode:(LayoutManager *)previousMaxNode
                          parentNode:(LayoutManager *)parentNode
                       flexDirection:(PSFlexDirection)flexDirection
                      justifyContent:(PSFlexJustify)justifyContent
                             surplus:(CGFloat)surplus
{
    CGFloat left = 0;
    CGFloat margin = 0;
    if (parentNode.flexWrap == PSFlexWrapWrap && flexDirection == PSFlexDirectionColumn) {
        margin = [self getMaxMargin:maxNode previousNode:previousMaxNode flexDirection:PSFlexDirectionRow];
    }else{
        margin = (flexDirection == PSFlexDirectionRow)?([self getMaxMargin:node previousNode:previousNode flexDirection:flexDirection]):0;
    }
    if (parentNode.flexWrap == PSFlexWrapWrap && flexDirection == PSFlexDirectionColumn) {
        left = (previousMaxNode != nil)?(previousMaxNode.left + margin + previousMaxNode.width + parentNode.margin):(parentNode.paddingLeft + margin);
    }else{
        if (flexDirection == PSFlexDirectionRow) {
            left = (previousNode != nil)?(previousNode.left + margin + previousNode.width + parentNode.margin):(parentNode.paddingLeft + margin);
        }else{
            left = parentNode.paddingLeft + margin + node.marginLeft;
        }
    }
    if (flexDirection == PSFlexDirectionRow) {
        switch (justifyContent) {
            case PSFlexJustifyStart:
            case PSFlexJustifyStartAround:
                left = left;
                break;
            case PSFlexJustifyEnd:
            case PSFlexJustifyEndAround:
                left = (previousNode != nil)?left:(surplus - parentNode.paddingRight - node.marginRight);
                break;
            case PSFlexJustifyCenter:
                left = (previousNode != nil)?left:surplus/2.;
            default:
                break;
        }
    }
    return left;
}
- (CGFloat)computerTopValueWithNode:(LayoutManager *)node
                       previousNode:(LayoutManager *)previousNode
                            maxNode:(LayoutManager *)maxNode
                    previousMaxNode:(LayoutManager *)previousMaxNode
                         parentNode:(LayoutManager *)parentNode
                      flexDirection:(PSFlexDirection)flexDirection
                     justifyContent:(PSFlexJustify)justifyContent
                            surplus:(CGFloat)surplus
{
    CGFloat top = 0;
    CGFloat margin = 0;
    if (parentNode.flexWrap == PSFlexWrapWrap && flexDirection == PSFlexDirectionRow) {
        margin = [self getMaxMargin:maxNode previousNode:previousMaxNode flexDirection:PSFlexDirectionColumn];
    }else{
        margin = (flexDirection == PSFlexDirectionColumn)?([self getMaxMargin:node previousNode:previousNode flexDirection:flexDirection]):0;
    }
    if (parentNode.flexWrap == PSFlexWrapWrap && flexDirection == PSFlexDirectionRow) {
        top = (previousMaxNode != nil)?(previousMaxNode.top + margin + previousMaxNode.height + parentNode.margin):(parentNode.paddingTop + margin);
    }else{
        if (flexDirection == PSFlexDirectionColumn) {
            top = (previousNode != nil)?(previousNode.top + margin + previousNode.height + parentNode.margin):(parentNode.paddingTop + margin);
        }else{
            top = parentNode.paddingTop + margin + node.marginTop;
        }
    }
    if (flexDirection == PSFlexDirectionColumn) {
        
        switch (justifyContent) {
            case PSFlexJustifyStart:
            case PSFlexJustifyStartAround:
                top = top;
                break;
            case PSFlexJustifyEnd:
            case PSFlexJustifyEndAround:
                top = (previousNode != nil)?top:(surplus - parentNode.paddingBottom - parentNode.childNodes.lastObject.marginBottom);
                break;
            case PSFlexJustifyCenter:
                top = (previousNode != nil)?top:(top + surplus/2.);
            default:
                break;
        }
    }
    return top;
}
- (LayoutManager *)getChildNodesMaxHeight:(LayoutManager *)node
{
    LayoutManager *maxNode = nil;
    CGFloat maxHeight = 0;
    for (LayoutManager *childNode in node.childNodes) {
        CGFloat margin = childNode.height + childNode.marginTop + childNode.parentNode.paddingTop;
        if (maxHeight < margin) {
            maxNode = childNode;
            maxHeight = margin;
        }
    }
    return maxNode;
}
- (LayoutManager *)getChildNodesMaxWidth:(LayoutManager *)node
{
    LayoutManager *maxNode = nil;
    CGFloat maxWidth = 0;
    for (LayoutManager *childNode in node.childNodes) {
        CGFloat margin = childNode.width + childNode.marginLeft + childNode.parentNode.paddingLeft;
        if (maxWidth < margin) {
            maxNode = childNode;
            maxWidth = margin;
        }
    }
    return maxNode;
}
- (LayoutManager *)getChildNodesMinHeight:(LayoutManager *)node
{
    LayoutManager *minNode = nil;
    CGFloat minHeight = MAXFLOAT;
    for (LayoutManager *childNode in node.childNodes) {
        CGFloat margin = childNode.height + childNode.marginTop + childNode.parentNode.paddingTop;
        if (minHeight > margin) {
            minNode = childNode;
            minHeight = margin;
        }
    }
    return minNode;
}
- (LayoutManager *)getChildNodesMinWidth:(LayoutManager *)node
{
    LayoutManager *minNode = nil;
    CGFloat minWidth = 0;
    for (LayoutManager *childNode in node.childNodes) {
        CGFloat margin = childNode.width + childNode.marginLeft + childNode.parentNode.paddingLeft;
        if (minWidth > margin) {
            minNode = childNode;
            minWidth = margin;
        }
    }
    return minNode;
}
- (CGFloat )getChildNodesHeight:(LayoutManager *)node
{
    CGFloat maxHeight = 0;
    for (LayoutManager *childNode in node.childNodes) {
        maxHeight += childNode.height;
    }
    return maxHeight;
}
- (CGFloat )getChildNodesWidth:(LayoutManager *)node
{
    CGFloat maxWidth = 0;
    for (LayoutManager *childNode in node.childNodes) {
        maxWidth += childNode.width;
    }
    return maxWidth;
}
static void PolarisAttachNodesFromViewHierachy(UIView *const view)
{
    LayoutManager *const layout = view.layoutM;
    
    NSMutableArray<UIView *> *subviewsToInclude = [[NSMutableArray alloc] initWithCapacity:view.subviews.count];
    for (UIView *subview in view.subviews) {
        if (subview.layoutM.isEnabled && subview.layoutM.isIncludedInLayout) {
            [subviewsToInclude addObject:subview];
        }
    }
    layout.computeFlexGrow = 0;
    layout.computeFlexShrik = 0;
    layout.surplus = 0;
    NSMutableArray *childNodes = [NSMutableArray arrayWithCapacity:subviewsToInclude.count];
    for (UIView *const subview in subviewsToInclude) {
        subview.frame = CGRectZero;
        LayoutManager *subviewLayout = subview.layoutM;
        layout.computeFlexGrow += subviewLayout.flexGrow;
        layout.computeFlexShrik += subviewLayout.flexShrik;
        subviewLayout.parentNode = layout;
        [childNodes addObject:subviewLayout];
    }
    layout.childNodes = childNodes;
    
    for (UIView *const subview in subviewsToInclude) {
        PolarisAttachNodesFromViewHierachy(subview);
    }
}
static void PolarisApplyLayoutToViewHierarchy(UIView *view, BOOL preserveOrigin)
{
    NSCAssert([NSThread isMainThread], @"Frame setting should only be done on the main thread.");
    LayoutManager *layout = view.layoutM;
    if (!layout.isIncludedInLayout) {
        return;
    }
    const CGPoint topLeft = {
        layout.left,
        layout.top,
    };
    const CGPoint bottomRight = {
        topLeft.x + layout.width,
        topLeft.y + layout.height,
    };
    const CGPoint origin = preserveOrigin ? view.frame.origin : CGPointZero;
    view.frame = (CGRect) {
        .origin = {
            .x = (topLeft.x + origin.x),
            .y = (topLeft.y + origin.y),
        },
        .size = {
            .width = (bottomRight.x) - (topLeft.x),
            .height = (bottomRight.y) - (topLeft.y),
        },
    };
    for (UIView *subview in view.subviews) {
        if (subview.layoutM.isEnabled && subview.layoutM.isIncludedInLayout) {
            PolarisApplyLayoutToViewHierarchy(subview, preserveOrigin);
        }
    }
}
- (id)copyWithZone:(NSZone *)zone
{
    LayoutManager *deepCopy = [[[self class] alloc] init];
    deepCopy.paddingLeft = self.paddingLeft;
    deepCopy.paddingRight = self.paddingRight;
    deepCopy.paddingBottom = self.paddingBottom;
    deepCopy.paddingTop = self.paddingTop;
    deepCopy.margin    = self.margin;
    deepCopy.flexDirection = self.flexDirection;
    deepCopy.width = self.width;
    deepCopy.height = self.height;
    return deepCopy;
}
@end
