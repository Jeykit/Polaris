//
//  MUVideoIndicatorView.h
//  MUKit_Example
//
//  Created by Jekity on 2017/11/8.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSVideoIconView.h"
#import "PSSlomoIconView.h"

@interface PSVideoIndicatorView : UIView
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) PSVideoIconView *videoIcon;
@property (nonatomic, strong) PSSlomoIconView *slomoIcon;

@end
