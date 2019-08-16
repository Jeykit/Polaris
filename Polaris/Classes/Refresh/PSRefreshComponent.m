//
//  PSRefreshComponent.m
//  Pods
//
//  Created by Jekity on 2017/9/1.
//
//

#import "PSRefreshComponent.h"
#import "PSRefreshHeaderComponent.h"
#import "UIView+PSNormal.h"


@interface PSRefreshLabel : UILabel<CAAnimationDelegate>
- (void)startAnimating;
@end
@implementation PSRefreshLabel{
    CAGradientLayer * gradientLayer;
}

-(instancetype)init{
    if (self = [super init]) {
        
        gradientLayer = [CAGradientLayer new];
        gradientLayer.locations = @[@0.2,@0.5,@0.8];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        self.layer.masksToBounds = YES;
        [self.layer addSublayer:gradientLayer];
        
    }
    return self;
}
- (void)layoutSubviews{
    gradientLayer.frame = CGRectMake(0, 0, 0, self.heightPS);
    gradientLayer.position = CGPointMake(self.widthPS/2.0, self.heightPS/2.);
}
- (void)startAnimating{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 1.0;
    }];
    gradientLayer.colors = @[(id)[self.textColor colorWithAlphaComponent:0.2].CGColor,
                   (id)[self.textColor colorWithAlphaComponent:0.2].CGColor,
                   (id)[self.textColor colorWithAlphaComponent:0.2].CGColor];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    animation.fromValue = @(0);
    animation.toValue = @(CGRectGetWidth(self.frame)/2.0);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.3;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [gradientLayer addAnimation:animation forKey:animation.keyPath];
}

- (void)stopAnimating{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0.0;
    }];
    [gradientLayer removeAllAnimations];
}

@end
@interface PSRefreshComponent()
@property (nonatomic, weak) __kindof UIScrollView *scrollView;
@property (nonatomic, getter=isRefresh) BOOL refresh;
@property (assign, nonatomic,getter=isObservering) BOOL observering;
@property (strong, nonatomic) PSRefreshLabel *alertLabel;
@property (assign, nonatomic, getter=isShouldNoLongerRefresh) BOOL shouldNoLongerRefresh;
@property(nonatomic, assign)BOOL firstRefreshing;
@end

static NSString * const PSContentOffset = @"contentOffset";
static NSString * const PSContentSize = @"contentSize";
static CGFloat const PSRefreshHeight = 44.;
static CGFloat const kStretchOffsetYAxisThreshold = 1.0;
@implementation PSRefreshComponent

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupProperties];
    }
    return self;
}
- (void)setupProperties{
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.;
    [self addSubview:self.alertLabel];
    _firstRefreshing = YES;
    _refreshState = PSRefreshStateNone;
    _stretchOffsetYAxisThreshold = kStretchOffsetYAxisThreshold;
    _shouldNoLongerRefresh = NO;
    _refresh = NO;
    if (CGRectEqualToRect(self.frame, CGRectZero)) self.frame = CGRectMake(0, 0, 1, 1);
}
-(void)setRefreshState:(PSRefreshingState)refreshState{
    if (_refreshState == refreshState) return;
    _refreshState = refreshState;
    
#define MU_SET_ALPHA(a) __weak typeof(self) weakSelf = self;\
[self setAnimateBlock:^{\
weakSelf.alpha = (a);\
} completion:NULL];
    
    switch (refreshState) {
        case PSRefreshStateNone:{
            MU_SET_ALPHA(0.);
            break;
        }
        case PSRefreshStateScrolling:{
            ///when system adjust contentOffset atuomatically,
            ///will trigger refresh control's state changed.
            if (!self.isAutoRefreshing && !self.scrollView.isTracking) {
                return;
            }
            MU_SET_ALPHA(1.);
            break;
        }
        case PSRefreshStateReady:{
            ///because of scrollView contentOffset is not continuous change.
            ///need to manually adjust progress
            if (self.progress < self.stretchOffsetYAxisThreshold) {
                [self PSDidScrollWithProgress:self.stretchOffsetYAxisThreshold max:self.stretchOffsetYAxisThreshold];
            }
            MU_SET_ALPHA(1.);
            break;
        }
        case PSRefreshStateRefreshing:{
            break;
        }
        case PSRefreshStateWillEndRefresh:{
            MU_SET_ALPHA(1.);
            break;
        }
    }
    [self PSRefreshStateDidChange:refreshState];//刷新状态改变
    
}
- (void)setProgress:(CGFloat)progress{
    if (_progress == progress) return;
    _progress = progress;
    [self PSDidScrollWithProgress:progress max:self.stretchOffsetYAxisThreshold];
}

- (void)setStretchOffsetYAxisThreshold:(CGFloat)stretchOffsetYAxisThreshold{
    if (_stretchOffsetYAxisThreshold != stretchOffsetYAxisThreshold &&
        stretchOffsetYAxisThreshold > 1.0) {
        _stretchOffsetYAxisThreshold = stretchOffsetYAxisThreshold;
    }
}

- (BOOL)isRefresh{
    return (_refreshState == PSRefreshStateRefreshing);
}
#pragma mark - layout

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.heightPS = (self.heightPS < 44.) ? PSRefreshHeight  : self.heightPS;
    self.frame = CGRectMake(0, 0, self.scrollView.widthPS, self.heightPS);
    self.alertLabel.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    if (self.superview && newSuperview == nil) {
        if (_observering) {
            [self.superview removeObserver:self forKeyPath:PSContentOffset];
            [self.superview removeObserver:self forKeyPath:PSContentSize];
            _observering = NO;
        }
    }
    else if (self.superview == nil && newSuperview){
        if (!_observering) {
            _scrollView = (UIScrollView *)newSuperview;
            //sometimes, this method called before `layoutSubviews`,such as UICollectionViewController
            [self layoutIfNeeded];
            _preSetContentInsets = ((UIScrollView *)newSuperview).realContentInsetPS;
            [newSuperview addObserver:self forKeyPath:PSContentOffset options:options context:nil];
            [newSuperview addObserver:self forKeyPath:PSContentSize options:options context:nil];
            _observering = YES;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([self isKindOfClass:[PSRefreshHeaderComponent class]] && self.firstRefreshing){
        return;
    }
    if ([keyPath isEqualToString:PSContentOffset]) {
        //If you disable the control's refresh feature, set the control to hidden
        if (self.isHidden) return;
        
        CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        //If you quickly scroll scrollview in an instant, contentoffset changes are not continuous
        [self privateContentOffsetOfScrollViewDidChange:point];
    }
    else if([keyPath isEqualToString:PSContentSize]){
        [self layoutSubviews];
    }
}

- (void)privateContentOffsetOfScrollViewDidChange:(CGPoint)contentOffset{}

-(void)beginRefreshing{
    
    if ([self isKindOfClass:[PSRefreshHeaderComponent class]] && self.firstRefreshing) {
        
        if (self.refreshHandler) {
            self.refreshHandler(self);
            self.firstRefreshing = NO;
        }
        return;
    }
    if (self.refreshState != PSRefreshStateNone || self.isHidden || self.isAutoRefreshing) return;
    if (self.isShouldNoLongerRefresh)  self.alertLabel.hidden = YES;
    self.shouldNoLongerRefresh = NO;
    self.autoRefreshing = YES;
    [self setScrollViewToRefreshLocation];
}

- (void)setScrollViewToRefreshLocation{
    self.animating = YES;
}

- (void)endRefreshing{
    [self endRefreshingWithText:nil completion:nil];
}

- (void)endRefreshingWithText:(NSString *)text completion:(dispatch_block_t)completion {
    if ([self isKindOfClass:[PSRefreshHeaderComponent class]] && self.firstRefreshing) {
        if (completion) {
            completion();
        }
    }
    if((!self.isRefresh && !self.isAnimating) || self.isHidden) return;
    if (text) {
        [self bringSubviewToFront:self.alertLabel];
        self.alertLabel.text = text;
        [self.alertLabel startAnimating];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.alertLabel stopAnimating];
            [weakSelf _endRefresh];
            if (completion) completion();
        });
    }else{
        [self _endRefresh];
    }
}

- (void)endRefreshingAndNoLongerRefreshingWithAlertText:(NSString *)text{
    if((!self.isRefresh && !self.isAnimating) || self.isHidden) return;
    if (self.isShouldNoLongerRefresh) return;
    self.shouldNoLongerRefresh = YES;
    __weak typeof(self) weakSelf = self;
    if (self.alertLabel.alpha == 0.0){
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.alertLabel.alpha = 1.0;
        }];
    }
    [self bringSubviewToFront:self.alertLabel];
    self.alertLabel.text = text;
    if (text) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf _endRefresh];
        });
    }else{
        [self _endRefresh];
    }
}

- (void)resumeRefreshAvailable{
    self.shouldNoLongerRefresh = NO;
    self.alertLabel.alpha = 0.0;
}

- (void)_endRefresh{
    [self PSRefreshStateDidChange:PSRefreshStateWillEndRefresh];
    self.refreshState = PSRefreshStateScrolling;
    [self setScrollViewToOriginalLocation];
}

- (void)setScrollViewToOriginalLocation{}

#pragma mark -

#pragma mark - progress callback
-(void)PSRefreshStateDidChange:(PSRefreshingState)state{}
-(void)PSDidScrollWithProgress:(CGFloat)progress max:(const CGFloat)max{}

#pragma mark - getter

- (PSRefreshLabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [PSRefreshLabel new];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.font =  [UIFont fontWithName:@"Helvetica" size:15.f];
        _alertLabel.textColor = [UIColor blackColor];
        _alertLabel.alpha = 0.0;
        _alertLabel.backgroundColor = [UIColor whiteColor];
    }
    return _alertLabel;
}
-(void)setTextColor:(UIColor *)textColor{
    if (_textColor != textColor) {
        _textColor = textColor;
        _alertLabel.textColor = textColor;
        
    }
}
- (void)setAnimateBlock:(dispatch_block_t)block completion:(dispatch_block_t)completion{
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:block
                     completion:^(BOOL finished) {
                         if (completion) completion();
                     }];
}
@end
