//
//  PopupView.m
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import "PopupView.h"
#import "PSSheetView.h"
#import "PSAlertView.h"
#import "PSPopupView.h"

@interface PopupView()<PSAlertViewSelectedDelegate, PSSheetViewSelectedDelegate , PSPopupViewSelectedDelegate>
@property (nonatomic, strong) UIWindow *rootWindow;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentview;
@property (nonatomic, strong) PSSheetView *sheetView;
@property (nonatomic, strong) PSAlertView *alertView;
@property (nonatomic, strong) PSPopupView *popupView;

@property (nonatomic,copy) void(^selectedBlock)(NSUInteger index);
@end
@implementation PopupView

+ (instancetype)sharedInstance{
    
    static PopupView *popupview = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        popupview = [[[self class] alloc] init];
    });
    return popupview;
}
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        CGRect frame = [self screenFrame];
        self.frame = frame;
        [self addSubview:self.backgroundView];
    }
    return self;
}
- (BOOL)isIphoneX
{
    static dispatch_once_t onceToken;
    static BOOL isIphoneXAfter = NO;
    dispatch_once(&onceToken, ^{
        isIphoneXAfter =  [UIApplication sharedApplication].statusBarFrame.size.height == 44 ? YES :NO;
    });
    return isIphoneXAfter;
}
- (void)showSheetViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void (^)(NSUInteger))block{
    
    _sheetView = [[PSSheetView alloc] initWithTitle:title
                                             detail:detail
                                              items:options
                                             cancel:cancel];
    
    _sheetView.delegate = self;
    self.selectedBlock = block;
    [self.contentview addSubview:_sheetView];
    self.rootWindow.hidden = NO;
    [self.rootWindow addSubview:self];
   
    [self showAnimationWithView:self.sheetView];
}
- (void)showSheetViewWithTitile:(NSString *)title
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void (^)(NSUInteger))block

{
    
    _sheetView = [[PSSheetView alloc] initWithTitle:title
    detail:nil
     items:options
    cancel:cancel];
    _sheetView.delegate = self;
     self.selectedBlock = block;
     [self.contentview addSubview:_sheetView];
     self.rootWindow.hidden = NO;
     [self.rootWindow addSubview:self];
    
     [self showAnimationWithView:self.sheetView];
}

- (void)showSheetViewWithItems:(NSArray *)options
                        cancel:(PSPopupItem *)cancel
                         block:(void (^)(NSUInteger))block{
    
    _sheetView = [[PSSheetView alloc] initWithTitle:nil
      detail:nil
       items:options
      cancel:cancel];
      _sheetView.delegate = self;
       self.selectedBlock = block;
       [self.contentview addSubview:_sheetView];
       self.rootWindow.hidden = NO;
       [self.rootWindow addSubview:self];
      
       [self showAnimationWithView:self.sheetView];
    
}
- (void)showAlertViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                          block:(void (^)(NSUInteger))block{
    
    _alertView = [[PSAlertView alloc] initWithTitle:title
                                             detail:detail
                                              items:options];
    
    self.selectedBlock = block;
    _alertView.delegate = self;
    self.contentview.layer.cornerRadius = 5.;
    self.contentview.clipsToBounds = YES;
    self.contentview.layer.borderWidth = (1/[UIScreen mainScreen].scale);
    self.contentview.layer.borderColor = [UIColor colorWithRed:200./255. green:200./255.  blue:200./255.  alpha:.25].CGColor;
    
    [self.contentview addSubview:_alertView];
    self.rootWindow.hidden = NO;
    [self.rootWindow addSubview:self];
    
    [self showAnimationWithAlertView:self.alertView];
    
}
- (void)showPopupViewWithView:(UIView *)view
                      options:(NSArray *)options
                        block:(void (^)(NSUInteger))block
{
    _popupView = [[PSPopupView alloc] initPopupViewWithView:view
                                                      items:options];
    [self.contentview addSubview:_popupView];
    _popupView.delegate  = self;
    self.selectedBlock = block;
    _contentview.backgroundColor = [UIColor clearColor];
    self.rootWindow.hidden = NO;
    [self.rootWindow addSubview:self];
    
    [self showAnimationWithPopupView:_popupView];
}
- (void)showAnimationWithView:(UIView *)view
{
    CGRect frame = self.backgroundView.frame;
    BOOL isIphoneAfter = [self isIphoneX];
    self.contentview.frame = CGRectMake(0, frame.size.height, view.frame.size.width, 0);
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = .25;
        CGRect frame = self.backgroundView.frame;
        CGSize contentSize = view.frame.size;
        if (isIphoneAfter) {
            contentSize.height += 34.;
        }
        self.contentview.frame = CGRectMake(0, frame.size.height - contentSize.height, view.frame.size.width, contentSize.height);
        
    } completion:^(BOOL finished) {
        self.backgroundView.userInteractionEnabled = YES;
    }];
}

//alert View
- (void)showAnimationWithAlertView:(UIView *)view
{
    CGRect frame = self.backgroundView.frame;
    CGSize contentSize = view.frame.size;
    self.contentview.alpha = 0;
    self.contentview.frame = CGRectMake((frame.size.width - view.frame.size.width)/2., (frame.size.height - contentSize.height)/2., view.frame.size.width, contentSize.height);
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = .25;
        self.contentview.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        self.backgroundView.userInteractionEnabled = YES;
    }];
}

//popup view
- (void)showAnimationWithPopupView:(PSPopupView *)view
{
    CGSize contentSize = view.frame.size;
    self.contentview.alpha = 0;
    self.contentview.frame = CGRectMake(view.XPosition, view.YPosition, view.frame.size.width, contentSize.height);
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.05;
        self.contentview.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        self.backgroundView.userInteractionEnabled = YES;
    }];
}
- (void)hideAnimationWithView:(UIView *)view
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.backgroundView setAlpha:0];
        [self.backgroundView setUserInteractionEnabled:NO];
        
        CGRect frame = self.contentview.frame;
        frame.origin.y = self.backgroundView.frame.size.height;
        frame.size.height = 0;
        [self.contentview setFrame:frame];
        
    } completion:^(BOOL finished){
        [view removeFromSuperview];
        [self removeFromSuperview];
        self.rootWindow.hidden = YES;
    }];
}
- (void)hideAnimationWithAlertView:(UIView *)view
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.backgroundView setAlpha:0];
        [self.backgroundView setUserInteractionEnabled:NO];
        
        self.contentview.alpha = 0;
        
    } completion:^(BOOL finished){
        [view removeFromSuperview];
        [self removeFromSuperview];
        self.rootWindow.hidden = YES;
    }];
}
- (UIWindow *)rootWindow{
    if (!_rootWindow) {
        CGRect frame = [self screenFrame];
        _rootWindow = [[UIWindow alloc] initWithFrame:frame];
        _rootWindow.windowLevel = UIWindowLevelStatusBar;
        _rootWindow.backgroundColor = [UIColor clearColor];
        _rootWindow.hidden = YES;
    }
    return _rootWindow;
}

- (CGRect)screenFrame
{
    static CGRect frame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frame = [UIScreen mainScreen].bounds;
    });
    return frame;
}

- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        CGRect frame = [self screenFrame];
        _backgroundView.frame = frame;
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.alpha = 0;
        _backgroundView.backgroundColor = [UIColor colorWithRed:46./255. green:49./255. blue:50./255. alpha:1.];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [_backgroundView addGestureRecognizer:singleTap];
        _backgroundView.userInteractionEnabled = NO;
    }
    return _backgroundView;
}
- (UIView *)contentview{
    if (!_contentview) {
        _contentview = [[UIView alloc] init];
        _contentview.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentview];
    }
    return _contentview;
}
- (void)dismiss:(UITapGestureRecognizer *)tap
{
    if (self.sheetView) {
        [self hideAnimationWithView:self.sheetView];
        _contentview = nil;
        self.sheetView = nil;
        self.selectedBlock = nil;
    }
   
    if (self.popupView) {
        [self hideAnimationWithAlertView:self.popupView];
        _contentview = nil;
        self.popupView = nil;
        self.selectedBlock = nil;
    }
}
- (void)alertViewOptionsSelected:(NSUInteger)index{
    [self hideAnimationWithAlertView:self.alertView];
    if (self.selectedBlock) {
        self.selectedBlock(index);
    }
    _contentview = nil;
    self.alertView = nil;
    self.selectedBlock = nil;
}
- (void)sheetViewOptionsSelected:(NSUInteger)index{
    [self hideAnimationWithView:self.sheetView];
    if (self.selectedBlock && index != 100000) {
        self.selectedBlock(index);
    }
    _contentview = nil;
    self.sheetView = nil;
    self.selectedBlock = nil;
}
- (void)popupViewOptionsSelected:(NSUInteger)index{
    [self hideAnimationWithAlertView:self.popupView];
    if (self.selectedBlock) {
        self.selectedBlock(index);
    }
    _contentview = nil;
    self.popupView = nil;
    self.selectedBlock = nil;
}
@end
