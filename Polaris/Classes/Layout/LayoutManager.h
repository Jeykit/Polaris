//
//  LayoutManager.h
//  Expecta
//
//  Created by Jekity on 2019/7/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSFlexDirection) {
    PSFlexDirectionRow,
    PSFlexDirectionColumn,
};
typedef NS_ENUM(NSUInteger, PSFlexWrap) {
    PSFlexWrapNoWrap,
    PSFlexWrapWrap,
};

typedef NS_ENUM(NSUInteger, PSFlexJustify) {
    PSFlexJustifyStart,
    PSFlexJustifyStartAround,
    PSFlexJustifyCenter,
    PSFlexJustifyEnd,
    PSFlexJustifyEndAround,
};

typedef NS_ENUM(NSUInteger, PSFlexAlign) {
    PSFlexAlignDefalut,
    PSFlexAlignStart,
    PSFlexAlignCenter,
    PSFlexAlignEnd,
};

@interface LayoutManager : NSObject

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin;

@property (nonatomic, assign, setter=setIncludedInLayout:) BOOL isIncludedInLayout;
@property (nonatomic, assign, setter=setEnabled:) BOOL isEnabled;

@property (nonatomic, assign) PSFlexDirection flexDirection;
@property (nonatomic, assign) PSFlexWrap flexWrap;
@property (nonatomic, assign) PSFlexJustify justifyContent;
@property (nonatomic, assign) PSFlexAlign align_items;

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat aspectRatio;//宽高比

@property (nonatomic, assign) CGFloat paddingLeft;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingRight;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, assign) CGFloat marginLeft;
@property (nonatomic, assign) CGFloat marginTop;
@property (nonatomic, assign) CGFloat marginRight;
@property (nonatomic, assign) CGFloat marginBottom;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, assign) CGFloat flexGrow;//defalut is 0
@property (nonatomic, assign) CGFloat flexShrik;//defalut is 0

@property (nonatomic, assign) NSUInteger flexCount;//换行显示时，设置这个可以限制主轴方向每行的个数
@property (nonatomic, assign) NSUInteger flexNumberOfLine;//换行显示时，设置这个可以限制主轴方向行数
@property (nonatomic, assign) BOOL hidden;//defalut is NO
@property (nonatomic, assign) BOOL fitSizeSelf;//defalut Yes ，如果图片不需要自适应自身尺寸，则设置宽高，或把z此参数置为NO

@end

NS_ASSUME_NONNULL_END
