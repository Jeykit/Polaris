//
//  UIViewController+NavigationM.h
//  Expecta
//
//  Created by Jekity on 2019/8/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (NavigationM)
/**
 当前导航栏是否为透明
 Whether or not the navigation bar is currently translucent.
 */
@property(nonatomic, assign) BOOL             navigationBarTranslucentM;

/**
 当前导航栏的透明度
 Setting the navigation bar Alpha with a value(0 ~ 1).
 */
@property(nonatomic, assign) CGFloat          navigationBarAlphaM;


/**
 当前导航栏是否隐藏
 Whether or not the navigation bar is currently hidden.
 */
@property(nonatomic, assign) BOOL             navigationBarHiddenM;


/**
 当前导航栏颜色(不建议使用)
 Setting the navigation bar backgroundColor with UIColor.
 */
@property(nonatomic, strong) UIColor          *navigationBarBackgroundColorM;


/**
 当前导航栏背景图片(建议使用)
 Setting the navigation bar backgroundImage with UIImage.
 */
@property(nonatomic, strong) UIImage          *navigationBarBackgroundImageM;


/**
 当前导航栏的阴影线是否隐藏
 Whether or not the navigation bar shadow is currently hidden.
 */
@property(nonatomic, assign) BOOL             navigationBarShadowImageHiddenM;//隐藏阴影线


/**
 当前导航栏的标题颜色
 Setting the navigation bar titleColor by UIColor.
 */
@property(nonatomic, strong) UIColor          *titleColorM;


/**
 更改当前导航栏的默认控件或字体的颜色，如返回按钮的颜色
 Setting the navigation bar controls color by UIColor.
 */
@property(nonatomic, strong) UIColor          *navigationBarTintColor;//控件颜色


/**
 当前控制器不是导航控制器时，设置电池电量条的颜色
 Setting the statusBar Style in the UIControler which is not kind of UINavigationController.
 */
@property(nonatomic, assign) UIStatusBarStyle statusBarStyleM;


/**
 当前控制器是导航控制器时，设置电池电量条的颜色
 Setting the statusBar Style in the UIControler which is kind of UINavigationController.
 */
@property(nonatomic, assign) UIBarStyle       barStyleM;


/**
 控制器返回按钮图片，也可通过‘navigationBarTintColor’属性直接设置返回按钮的颜色
 Setting the  navigation bar backIndicatorImage with UIImage.
 */
@property(nonatomic, strong) UIImage          *backIndicatorImageM;


/**
 返回按钮文字是否显示
 Whether or not the  navigation bar backItem title is currently hidden.
 */
@property(nonatomic, assign) BOOL             showBackBarButtonItemText;



/**
 导航条和电池电量条高度
 Return a value of navigation bar and status Bar height.
 */
@property(nonatomic, assign ,readonly) CGFloat navigationBarAndStatusBarHeight;


/**
 标题字体大小
 Setting the navigation bar titleFont with UIFont.
 */
@property(nonatomic, strong) UIFont            *titleFontM;


/**
 当前导航栏在y轴方向上偏移距离
 Setting the navigation bar translation in the y axis with a value.
 */
@property(nonatomic, assign) CGFloat            navigationBarTranslationY;//导航在y轴方向上偏移距离


/**
 UIBarButtonLeftItem
 */
@property(nonatomic, readonly ,weak) UIBarButtonItem *leftButtonItem;


/**
 UIBarButtonRightItem
 */
@property(nonatomic, readonly ,weak) UIBarButtonItem *rightButtonItem;


/**
 UIBarButtonBackItem
 */
@property(nonatomic, readonly ,weak) UIBarButtonItem *backButtonItem;

@property(nonatomic, assign) BOOL interactivePopGestureRecognizer;


@end

NS_ASSUME_NONNULL_END
