//
//  PSRefreshHeaderStyleComponent.h
//  PSKit
//
//  Created by Jekity on 2018/6/4.
//

#import "PSRefreshHeaderComponent.h"
#import "PSReplicatorLayer.h"

@interface PSRefreshHeaderStyleComponent : PSRefreshHeaderComponent

@property (assign, nonatomic) PSReplicatorLayerAnimationStyle animationStyle;

@property (nonatomic,strong) UIColor *styleColor;
@end
