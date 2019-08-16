//
//  MUOverlayView.h
//  MUKit_Example
//
//  Created by Jekity on 2017/11/8.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCircleView.h"
#import "PSCheckmarkView.h"

@interface PSOverlayView : UIView
@property(nonatomic, strong)PSCircleView *circleView;
@property(nonatomic, strong)PSCheckmarkView *checkmarkView;
@property(nonatomic, strong)UIColor *tintColor;
@end
