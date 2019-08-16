//
//  UIViewController+NavigationM.m
//  Expecta
//
//  Created by Jekity on 2019/8/2.
//

#import "NavigationManager.h"
#import <objc/runtime.h>

@interface NavigationManager : NSObject
@property(nonatomic, assign) BOOL navigationBarTranslucentM;
@property(nonatomic, assign) CGFloat navigationBarAlphaM;
@property(nonatomic, assign) BOOL navigationBarHiddenM;
@property(nonatomic, strong) UIColor *navigationBarBackgroundColorM;
@property(nonatomic, strong) UIImage *navigationBarBackgroundImageM;
@property(nonatomic, assign) BOOL  navigationBarShadowImageHiddenM;
@property(nonatomic, strong) UIColor *titleColorM;
@property(nonatomic, strong) UIFont  *titleFontM;
@property(nonatomic, strong) UIColor *navigationBarTintColor;
@property(nonatomic, assign) UIStatusBarStyle statusBarStyleM;
@property(nonatomic, assign) UIBarStyle barStyleM;
@property(nonatomic, strong) UIImage  *backIndicatorImageM;
@property(nonatomic, assign) CGFloat  navigationBarTranslationY;
@property(nonatomic, assign) BOOL     showBackBarButtonItemText;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) UIImageView *fakeNavigationBar;
@property (nonatomic,assign) BOOL clipsToBounds;
@property(nonatomic, assign) BOOL interactivePopGestureRecognizer;
@end
@implementation NavigationManager
- (instancetype)init{
    if (self = [super init]) {
        _navigationBarAlphaM = 1.;
        _clipsToBounds = NO;
        _interactivePopGestureRecognizer = YES;
    }
    return self;
}
@end

@interface UINavigationBar ()
@property (nonatomic, strong) NavigationManager *navigationM;
@end
@interface UINavigationBar (NavigationM)
@property (nonatomic, assign ,readonly) CGFloat statusBarHeight;
@property (nonatomic, assign, readonly) CGFloat navigationBarAndStatusBarHeight;
- (void)setBackgroundImageM:(UIImage *)image;
- (void)setBackgroundColorM:(UIColor *)color;
- (void)setBackgroundAlphaM:(CGFloat)alpha;
- (void)removeM;
@end
@implementation UINavigationBar (NavigationM)
- (NavigationManager *)navigationM{
    NavigationManager *navigationM = objc_getAssociatedObject(self, @selector(navigationM));
    if (navigationM == nil) {
        self.translucent = YES;
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navigationM = [[NavigationManager alloc] init];
        objc_setAssociatedObject(self, @selector(navigationM), navigationM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navigationM;
}

- (CGFloat)statusBarHeight{
    static CGFloat height = 0;
    if (height == 0) {
        height = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return height;
}
- (CGFloat)navigationBarAndStatusBarHeight{
    static CGFloat totalHeight = 0;
    if (totalHeight == 0) {
        totalHeight = [UIApplication sharedApplication].statusBarFrame.size.height + CGRectGetHeight(self.bounds);
    }
    return totalHeight;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_11_0
- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *aView in self.subviews) {
        if ([@[@"_UINavigationBarBackground", @"_UIBarBackground"] containsObject:NSStringFromClass([aView class])]) {
            aView.frame = CGRectMake(0, -CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+CGRectGetMinY(self.frame));
            aView.backgroundColor = [UIColor clearColor];
        }
    }
}
#endif
- (void)setBackgroundImageM:(UIImage *)image{
    if (!image) {
        return ;
    }
    [self.navigationM.backgroundView removeFromSuperview];
    if (!self.navigationM.backgroundImageView.superview) {
        if (!self.navigationM.backgroundImageView) {
            CGFloat statusBarHeight = self.statusBarHeight;
            CGFloat height = self.navigationBarAndStatusBarHeight;
            if (statusBarHeight == 40.) {
                height -= 20.;
            }else if(statusBarHeight == 88.){
                height -= 44.;
            }
            self.navigationM.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), height)];
        }
    }
    // _UIBarBackground is first subView for navigationBar
    /** iOS11下导航栏不显示问题 */
    if (self.subviews.count > 0) {
        [self.subviews.firstObject insertSubview:self.navigationM.backgroundImageView atIndex:0];
    } else {
        [self insertSubview:self.navigationM.backgroundImageView atIndex:0];
    }
    self.navigationM.backgroundImageView.image = image;
}
- (void)setBackgroundColorM:(UIColor *)color{
    if (!color) {
        return ;
    }
    [self.navigationM.backgroundImageView removeFromSuperview];
    if (!self.navigationM.backgroundView.superview) {
        if (!self.navigationM.backgroundView) {
             CGFloat statusBarHeight = self.statusBarHeight;
            CGFloat height = self.navigationBarAndStatusBarHeight;
            if (statusBarHeight == 40.) {
                height -= 20.;
            }else if(statusBarHeight == 88.){
                height -= 44.;
            }
            self.navigationM.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), height)];
            self.navigationM.backgroundView.userInteractionEnabled = NO;
        }
        if (self.subviews.count > 0) {
            [self.subviews.firstObject insertSubview:self.navigationM.backgroundView atIndex:0];
        } else {
            [self insertSubview:self.navigationM.backgroundView atIndex:0];
        }
    }
    self.navigationM.backgroundView.backgroundColor = color;
}
- (void)setBackgroundAlphaM:(CGFloat)alpha{
    self.navigationM.backgroundImageView.alpha = alpha;
    self.navigationM.backgroundView.alpha      = alpha;
    UIView *barBackgroundView = self.subviews.firstObject;
    barBackgroundView.alpha = alpha;
    if (@available(iOS 11.0, *)) {  // iOS11 下 UIBarBackground -> UIView/UIImageViwe
        for (UIView *view in self.subviews) {
            if ([NSStringFromClass([view class]) containsString:@"_UIBarBackground"]) {
                view.alpha = alpha;
                break;
            }
        }
        // iOS 下如果不设置 UIBarBackground 下的UIView的透明度，会显示不正常
        if (barBackgroundView.subviews.firstObject) {
            barBackgroundView.subviews.firstObject.alpha = alpha;
        }
    }
}
- (void)removeM{
    [self.navigationM.backgroundImageView removeFromSuperview];
    [self.navigationM.backgroundView removeFromSuperview];
}
@end

@interface UIViewController()
@property (nonatomic,strong) NavigationManager *navigationM;
@end

@implementation UIViewController (NavigationM)
- (NavigationManager *)navigationM{
    NavigationManager *navigationM = objc_getAssociatedObject(self, @selector(navigationM));
    if (navigationM == nil) {
        navigationM = [[NavigationManager alloc] init];
        objc_setAssociatedObject(self, @selector(navigationM), navigationM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navigationM;
}
//侧滑手势
- (void)setInteractivePopGestureRecognizer:(BOOL)interactivePopGestureRecognizer{
    self.navigationController.interactivePopGestureRecognizer.enabled = interactivePopGestureRecognizer;
    self.navigationM.interactivePopGestureRecognizer = interactivePopGestureRecognizer;
}
- (BOOL)interactivePopGestureRecognizer{
    return self.navigationM.interactivePopGestureRecognizer;
}
//透明导航栏
- (void)setNavigationBarTranslucentM:(BOOL)navigationBarTranslucentM{
    self.edgesForExtendedLayout = UIRectEdgeTop;
    if (navigationBarTranslucentM == YES) {
        [self.navigationController.navigationBar setBackgroundAlphaM:0];
    }else{
        [self.navigationController.navigationBar setBackgroundAlphaM:1.];
    }
    self.navigationM.navigationBarTranslucentM = navigationBarTranslucentM;
}
- (BOOL)navigationBarTranslucentM{
    return self.navigationM.navigationBarTranslucentM;
}
//透明度变化
- (void)setNavigationBarAlphaM:(CGFloat)navigationBarAlphaM{
    self.edgesForExtendedLayout = UIRectEdgeTop;
    [self.navigationController.navigationBar setBackgroundAlphaM:navigationBarAlphaM];
    self.navigationM.navigationBarAlphaM = navigationBarAlphaM;
}
- (CGFloat)navigationBarAlphaM{
    return self.navigationM.navigationBarAlphaM;
}
//隐藏导航栏
- (void)setNavigationBarHiddenM:(BOOL)navigationBarHiddenM{
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.navigationM.navigationBarHiddenM = navigationBarHiddenM;
}

- (BOOL)navigationBarHiddenM{
    return self.navigationM.navigationBarHiddenM;
}
//背景颜色
- (void)setNavigationBarBackgroundColorM:(UIColor *)navigationBarBackgroundColorM{
    [self.navigationController.navigationBar setBackgroundColorM:navigationBarBackgroundColorM];
    self.navigationM.navigationBarBackgroundColorM = navigationBarBackgroundColorM;
}
- (UIColor *)navigationBarBackgroundColorM{
    return self.navigationM.navigationBarBackgroundColorM?:self.navigationController.navigationBarBackgroundColorM?:[UIColor groupTableViewBackgroundColor];
}
//背景图片
- (void)setNavigationBarBackgroundImageM:(UIImage *)navigationBarBackgroundImageM{
    [self.navigationController.navigationBar setBackgroundImageM:navigationBarBackgroundImageM];
    self.navigationM.navigationBarBackgroundImageM = navigationBarBackgroundImageM;
}
- (UIImage *)navigationBarBackgroundImageM{
    return self.navigationM.navigationBarBackgroundImageM?:self.navigationController.navigationBarBackgroundImageM;
}
//阴影线
- (void)setNavigationBarShadowImageHiddenM:(BOOL)navigationBarShadowImageHiddenM{
    self.navigationM.navigationBarShadowImageHiddenM = navigationBarShadowImageHiddenM;
}
- (BOOL)navigationBarShadowImageHiddenM{
    return self.navigationM.navigationBarShadowImageHiddenM;
}
//标题颜色
- (void)setTitleColorM:(UIColor *)titleColorM{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : titleColorM};
    self.navigationM.titleColorM = titleColorM;
}
- (UIColor *)titleColorM{
    return self.navigationM.titleColorM?:self.navigationController.navigationM.titleColorM?:[UIColor blackColor];
}
//控件颜色
- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor{
    self.navigationController.navigationBar.tintColor = navigationBarTintColor;
    self.navigationM.navigationBarTintColor = navigationBarTintColor;
}
- (UIColor *)navigationBarTintColor{
    return self.navigationM.navigationBarTintColor?:self.navigationController.navigationM.navigationBarTintColor?:[self defalutTintColor];
}
//标题字体
- (void)setTitleFontM:(UIFont *)titleFontM{
    self.navigationM.titleFontM = titleFontM;
}
- (UIFont *)titleFontM{
    return self.navigationM.titleFontM?:self.navigationController.navigationM.titleFontM?:[UIFont boldSystemFontOfSize:17.];
}
- (void)setStatusBarStyleM:(UIStatusBarStyle)statusBarStyleM{
    self.navigationM.statusBarStyleM = statusBarStyleM;
     [self setNeedsStatusBarAppearanceUpdate];
}
- (UIStatusBarStyle)statusBarStyleM{
    return  self.navigationM.statusBarStyleM?:self.navigationController.navigationM.statusBarStyleM?:UIStatusBarStyleDefault;
}
//电池电量
- (void)setBarStyleM:(UIBarStyle)barStyleM{
     self.navigationController.navigationBar.barStyle  = barStyleM;
     self.navigationM.barStyleM = barStyleM;
}
- (UIBarStyle)barStyleM{
    return self.navigationM.barStyleM?:self.navigationController.barStyleM?:UIBarStyleDefault;
}
//返回按钮图片
- (void)setBackIndicatorImageM:(UIImage *)backIndicatorImageM{
    self.navigationController.navigationBar.backIndicatorImage = backIndicatorImageM;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backIndicatorImageM;
    self.navigationM.backIndicatorImageM = backIndicatorImageM;
}
- (UIImage *)backIndicatorImageM{
    return self.navigationM.backIndicatorImageM?:self.navigationController.navigationM.backIndicatorImageM;
}
-(UIBarButtonItem *)leftButtonItem{
    return self.navigationItem.leftBarButtonItem;
}
-(UIBarButtonItem *)rightButtonItem{
    return self.navigationItem.rightBarButtonItem;
}
-(UIBarButtonItem *)backButtonItem{
    return self.navigationItem.backBarButtonItem;
}
- (CGFloat)navigationBarAndStatusBarHeight {
    static CGFloat height = 0;
    if (height == 0) {
        height = CGRectGetHeight(self.navigationController.navigationBar.bounds) +
        CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    }
    return height;
}
- (void)setNavigationBarTranslationY:(CGFloat)navigationBarTranslationY{
    self.navigationM.navigationBarTranslationY = navigationBarTranslationY;
}
- (CGFloat)navigationBarTranslationY{
    return  self.navigationM.navigationBarTranslationY;
}
- (void)setShowBackBarButtonItemText:(BOOL)showBackBarButtonItemText{
    self.navigationM.showBackBarButtonItemText = showBackBarButtonItemText;
}
- (BOOL)showBackBarButtonItemText{
    return self.navigationM.showBackBarButtonItemText?:self.navigationController.navigationM.showBackBarButtonItemText?:NO;
}
- (UIColor *)defalutTintColor{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color =  [UINavigationBar new].tintColor;
    });
    return color;
}
- (void)deallocM{
#if DEBUG
    NSLog(@"%@ ---------------  dealloc",NSStringFromClass([self class]));
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [self deallocM];
}
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self methodSwizzling:@selector(viewDidLoad) newSelectorName:@selector(viewDidLoadM)];
        [self methodSwizzling:@selector(viewWillAppear:) newSelectorName:@selector(viewWillAppearM:)];
        [self methodSwizzling:@selector(viewWillDisappear:) newSelectorName:@selector(viewWillDisappearM:)];
        [self methodSwizzling:@selector(viewDidAppear:) newSelectorName:@selector(viewDidAppearM:)];
        [self methodSwizzling:@selector(viewDidDisappear:) newSelectorName:@selector(viewDidDisappearM:)];
        [self methodSwizzling:@selector(viewDidLayoutSubviews) newSelectorName:@selector(viewDidLayoutSubviewsM)];
        [self methodSwizzling:NSSelectorFromString(@"dealloc") newSelectorName:@selector(deallocM)];
    });
}
+ (void)methodSwizzling:(SEL)selectorName
        newSelectorName:(SEL)newSelectorName
{
    Class originalClass = [self class];
    Method oldMethod = class_getInstanceMethod(originalClass, selectorName);
    Method newMethod = class_getInstanceMethod(originalClass, newSelectorName);
    method_exchangeImplementations(oldMethod, newMethod);
    
}
- (void)viewDidLoadM
{
    [self viewDidLoadM];
    if ([self canUpdateNavigationBar]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        if (@available(iOS 11.0, *)) {
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
}
- (void)didChangeStatusBarFrame {
    
    CGFloat statusBarHeight = self.navigationController.navigationBar.statusBarHeight;
    CGFloat height = self.navigationController.navigationBar.navigationBarAndStatusBarHeight;
    if (statusBarHeight == 20.0 || statusBarHeight == 44.0) {
        CGRect frame =  self.navigationController.navigationBar.navigationM.backgroundImageView.frame;
        frame.size.height = height;
        self.navigationController.navigationBar.navigationM.backgroundImageView.frame = frame;
        self.navigationController.navigationBar.navigationM.backgroundView.frame = frame;
        
    } else {
        if (statusBarHeight == 40. ) {
            height -= 20.;
        }else if(statusBarHeight == 88.){
            height -= 44.;
        }
        CGRect frame =  self.navigationController.navigationBar.navigationM.backgroundImageView.frame;
        frame.size.height = height;
        self.navigationController.navigationBar.navigationM.backgroundImageView.frame = frame;
        self.navigationController.navigationBar.navigationM.backgroundView.frame = frame;
        
    }
    
}
- (void)viewWillAppearM:(BOOL)animated
{
    [self viewWillAppearM:animated];
    if ([self canUpdateNavigationBar]) {
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        [self.navigationController setNavigationBarHidden:self.navigationBarHiddenM animated:YES];
        [self now_updateNaviagationBarInfo];
        if ([self shouldAddFakeNavigationBar]) {
            [self addFakeNavigationBar];
        }
    }
}
- (void)viewDidAppearM:(BOOL)animated
{
    [self viewDidAppearM:animated];
    if ([self canUpdateNavigationBar]) {//判断当前控制器有无导航控制器
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        [self.navigationController setNavigationBarHidden:self.navigationBarHiddenM animated:NO];
        [self removeFakeNavigationBar];
    }
}
- (void)viewWillDisappearM:(BOOL)animated
{
    [self viewWillDisappearM:animated];
    if ([self canUpdateNavigationBar]) {//判断当前控制器有无导航控制器
        if (self.navigationBarTranslationY > 0) {
            self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
            self.navigationBarTranslationY = 0;
        }
        [self.navigationController setNavigationBarHidden:self.navigationBarHiddenM animated:YES];
    }
}
- (void)viewDidDisappearM:(BOOL)animated
{
    [self removeFakeNavigationBar];
    [self viewDidDisappearM:animated];
}
- (void)viewDidLayoutSubviewsM
{
    [self viewDidLayoutSubviewsM];
    if (self.navigationM.fakeNavigationBar) {
        [self.view bringSubviewToFront:self.navigationM.fakeNavigationBar];
        
    }
}
- (BOOL)canUpdateNavigationBar {
    // 如果当前有导航栏//且没有手动设置隐藏导航栏
    NSString *string = NSStringFromClass([self.navigationController class]);
    if (self.navigationController && ([string isEqualToString:@"UINavigationController"] || [string isEqualToString:@"PSNavigationController"])) {//如果有自定义的导航栏则过滤掉
        return YES;
    }
    return NO;
}
-(void)now_updateNaviagationBarInfo{
    if (self.navigationBarTranslucentM == YES) {
        [self.navigationController.navigationBar setBackgroundAlphaM:0];
    }else{
        [self.navigationController.navigationBar setBackgroundAlphaM:self.navigationBarAlphaM];
    }
    self.navigationController.navigationBar.backIndicatorImage = self.backIndicatorImageM;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = self.backIndicatorImageM;
    if (!self.showBackBarButtonItemText) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = item;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = self.interactivePopGestureRecognizer;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : self.titleColorM, NSFontAttributeName:self.titleFontM};
    self.navigationController.navigationBar.tintColor = self.navigationBarTintColor;
    self.navigationController.navigationBar.barStyle  = self.barStyleM;
    [self showBottomLineInView:self.navigationController.navigationBar hidden:self.navigationBarShadowImageHiddenM];
    if (self.navigationM.navigationBarHiddenM||self.navigationM.navigationBarTranslucentM) {
        return;
    }
    if (!self.navigationM.fakeNavigationBar) {
        if (self.navigationM.navigationBarBackgroundImageM) {
            [self.navigationController.navigationBar setBackgroundImageM:self.navigationBarBackgroundImageM];
        }else{
            [self.navigationController.navigationBar setBackgroundColorM:self.navigationBarBackgroundColorM];
        }
    }
}
- (void)showBottomLineInView:(UIView *)view hidden:(BOOL)hidden{
    UIImageView *navBarLineImageView = [self findLineImageViewUnder:view];
    navBarLineImageView.hidden = hidden;
}

- (UIImageView *)findLineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findLineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}
-(UIViewController *)fromViewController{
    return [self.navigationController.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
}
-(UIViewController *)toViewController{
    return [self.navigationController.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
}
-(BOOL)shouldAddFakeNavigationBar{
    
    UIViewController *fromViewController = self.fromViewController;
    UIViewController *toViewController   = self.toViewController;
    if ((fromViewController && (fromViewController.navigationBarAlphaM != 1.  || (toViewController && (toViewController.navigationBarAlphaM != 1. || toViewController.navigationBarHiddenM == YES || toViewController.navigationBarTranslucentM == YES))))) {//透明度变化，隐藏导航栏，透明导航栏，导航栏颜色与navigationController颜色不同时,导航栏图片不同时
        
        return YES;
    }
    return NO;
}
// 添加一个假的 NavigationBar
- (void)addFakeNavigationBar {
    
    //    [self configuredFakeNavigationBar:self];
    UIViewController *fromViewController = self.fromViewController;
    UIViewController *toViewController   = self.toViewController;
    if (fromViewController && !fromViewController.navigationM.fakeNavigationBar) {
        
        [self configuredFakeNavigationBar:fromViewController];
    }
    if (toViewController && !toViewController.navigationM.fakeNavigationBar) {
        toViewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : toViewController.titleColorM?:toViewController.navigationController.titleColorM?:[UIColor blackColor]};
        [self configuredFakeNavigationBar:toViewController];
    }
}
-(void)configuredFakeNavigationBar:(UIViewController *)viewController{
    
    if (self.navigationBarTranslucentM || self.navigationBarAlphaM != 1.) {
        [self showBottomLineInView:self.navigationController.navigationBar hidden:YES];
        self.navigationBarShadowImageHiddenM = YES;
    }
    CGFloat y = 0;
    if (viewController.navigationBarBackgroundColorM || viewController.navigationBarBackgroundImageM) {
        y = -self.navigationBarAndStatusBarHeight;
    }
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {//tableView默认是打开裁剪的，必需关闭，否则假的navigationbar就会被裁剪，而达不到逾期效果
        viewController.navigationM.clipsToBounds   = viewController.view.clipsToBounds;
        viewController.view.clipsToBounds = NO;
        UIScrollView *tableView = (UIScrollView *)viewController.view;
        y  += tableView.contentOffset.y;
    }
    
    viewController.navigationM.fakeNavigationBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth([UIScreen mainScreen].bounds), self.navigationBarAndStatusBarHeight)];
    if (viewController.navigationM.navigationBarTranslucentM) {
        viewController.navigationM.fakeNavigationBar.alpha = 0.;
        viewController.navigationM.fakeNavigationBar.image = nil;
        viewController.navigationM.fakeNavigationBar.backgroundColor = [UIColor clearColor];
    }else{
        viewController.navigationM.fakeNavigationBar.alpha = viewController.navigationBarAlphaM;
        viewController.navigationM.fakeNavigationBar.userInteractionEnabled = NO;
    }
    
    if (!viewController.navigationBarTranslucentM) {
        viewController.navigationM.fakeNavigationBar.image           = viewController.navigationBarBackgroundImageM;
        viewController.navigationM.fakeNavigationBar.backgroundColor = viewController.navigationBarBackgroundColorM;
    }
    [viewController.view addSubview:viewController.navigationM.fakeNavigationBar];
    [viewController.view bringSubviewToFront:viewController.navigationM.fakeNavigationBar];
}
- (void)removeFakeNavigationBar {
    if (self.navigationM.fakeNavigationBar) {
        [self.navigationM.fakeNavigationBar removeFromSuperview];
        self.navigationM.fakeNavigationBar = nil;
        self.view.clipsToBounds = self.navigationM.clipsToBounds;
    }
}
@end
@implementation UIScrollView (navigationM)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class originalClass = [self class];
        Method oldMethod = class_getInstanceMethod(originalClass, @selector(initWithFrame:));
        Method newMethod = class_getInstanceMethod(originalClass, @selector(initWithFrameM:));
        method_exchangeImplementations(oldMethod, newMethod);
        
    });
}
-(void)initWithFrameM:(CGRect)frame{
    if (@available(iOS 11.0, *)) {
        if ([self isKindOfClass:[UIScrollView class]]) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    [self initWithFrameM:frame];
}
@end
