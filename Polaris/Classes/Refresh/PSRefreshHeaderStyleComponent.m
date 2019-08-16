//
//  PSRefreshHeaderStyleComponent.m
//  PSKit
//
//  Created by Jekity on 2018/6/4.
//

#import "PSRefreshHeaderStyleComponent.h"
#import "UIView+PSNormal.h"

@interface PSRefreshHeaderStyleComponent()

@property (strong, nonatomic) UIActivityIndicatorView * indicator;
@property (strong, nonatomic) PSReplicatorLayer * replicatorLayer;
@end
@implementation PSRefreshHeaderStyleComponent

- (void)setupProperties{
    [super setupProperties];
    self.animationStyle = self.replicatorLayer.animationStyle;
    [self.layer addSublayer:self.replicatorLayer];
    [self addSubview:self.indicator];
}
- (void)setAnimationStyle:(PSReplicatorLayerAnimationStyle)animationStyle{
    if (_animationStyle != animationStyle) {
        _animationStyle = animationStyle;
        self.replicatorLayer.animationStyle = animationStyle;
        [self setNeedsLayout];
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    switch (self.animationStyle) {
        case PSReplicatorLayerAnimationStyleAllen:
        case PSReplicatorLayerAnimationStyleDot:
        case PSReplicatorLayerAnimationStyleWoody:
        case PSReplicatorLayerAnimationStyleCircle:
        case PSReplicatorLayerAnimationStyleArc:
        case PSReplicatorLayerAnimationStyleTriangle:
            self.replicatorLayer.frame = CGRectMake(0, 0, self.widthPS, self.heightPS);
            self.replicatorLayer.indicatorShapeLayer.backgroundColor = self.styleColor.CGColor?:[UIColor lightGrayColor].CGColor;
            [self.indicator removeFromSuperview];
            break;
        case PSReplicatorLayerAnimationStyleNone:
            self.indicator.center = CGPointMake(self.widthPS/2., self.heightPS/2.);
            [self.replicatorLayer removeFromSuperlayer];
            break;
        default:
            self.indicator.center = CGPointMake(self.widthPS/2., self.heightPS/2.);
            [self.replicatorLayer removeFromSuperlayer];
            break;
    }
}
-(void)setStyleColor:(UIColor *)styleColor{
    if (_styleColor != styleColor) {
        _styleColor = styleColor;
    }
}

- (void)PSDidScrollWithProgress:(CGFloat)progress max:(const CGFloat)max{
#define kOffset 0.7
    if (progress >= 0.8) {
        progress = (progress-kOffset)/(max - kOffset);
    }
    switch (self.animationStyle) {
        case PSReplicatorLayerAnimationStyleWoody:{
            break;
        }
        case PSReplicatorLayerAnimationStyleAllen:{
            
            break;
        }
        case PSReplicatorLayerAnimationStyleCircle:{
            
            break;
        }
        case PSReplicatorLayerAnimationStyleDot:{
            
            break;
        }
        case PSReplicatorLayerAnimationStyleArc:{
            self.replicatorLayer.indicatorShapeLayer.strokeEnd = progress;
            break;
        }
        case PSReplicatorLayerAnimationStyleTriangle:{
            
            break;
        }
        default:
            break;
    }
}

- (void)PSRefreshStateDidChange:(PSRefreshingState)state{
    [super PSRefreshStateDidChange:state];
    switch (state) {
        case PSRefreshStateNone:
        case PSRefreshStateScrolling:break;
        case PSRefreshStateReady:{
            self.replicatorLayer.opacity = 1.;
            break;
        }
        case PSRefreshStateRefreshing:{
            [self.indicator startAnimating];
            [self.replicatorLayer startAnimating];
            break;
        }
        case PSRefreshStateWillEndRefresh:{
            [self.indicator stopAnimating];
            [self.replicatorLayer stopAnimating];
            break;
        }
    }
}
- (PSReplicatorLayer *)replicatorLayer{
    if (!_replicatorLayer) {
        _replicatorLayer = [PSReplicatorLayer layer];
    }
    return _replicatorLayer;
}

#pragma mark - getter
- (UIActivityIndicatorView *)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = NO;
    }
    return _indicator;
}
@end
