//
//  PSRefreshFooterStyleComponent.h
//  PSKit
//
//  Created by Jekity on 2018/6/4.
//

#import "PSRefreshFooterComponent.h"
#import "PSReplicatorLayer.h"

@interface PSRefreshFooterStyleComponent : PSRefreshFooterComponent

@property (assign, nonatomic) PSReplicatorLayerAnimationStyle animationStyle;
@property (nonatomic,strong) UIColor *styleColor;
@end
