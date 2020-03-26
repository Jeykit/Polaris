//
//  PSReplicatorLayer.h
//  AFNetworking
//
//  Created by Jekity on 2018/6/4.
//

#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSInteger,PSReplicatorLayerAnimationStyle) {
    PSReplicatorLayerAnimationStyleWoody,
    PSReplicatorLayerAnimationStyleAllen,
    PSReplicatorLayerAnimationStyleCircle,
    PSReplicatorLayerAnimationStyleDot,
    PSReplicatorLayerAnimationStyleArc,
    PSReplicatorLayerAnimationStyleTriangle,
    PSReplicatorLayerAnimationStyleNone
};
@interface PSReplicatorLayer : CALayer
@property (strong, nonatomic) CAReplicatorLayer *replicatorLayer;
@property (strong, nonatomic) CAShapeLayer *indicatorShapeLayer;
@property (assign, nonatomic) PSReplicatorLayerAnimationStyle animationStyle;

- (void)startAnimating;

- (void)stopAnimating;
@end
