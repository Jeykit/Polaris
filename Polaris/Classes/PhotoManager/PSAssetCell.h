//
//  MUAssetCell.h
//  MUKit_Example
//
//  Created by Jekity on 2017/11/7.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSVideoIndicatorView.h"
#import "PSOverlayView.h"

@interface PSAssetCell : UICollectionViewCell
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)PSOverlayView *overlayView;
@property(nonatomic, strong)PSVideoIndicatorView *videoIndicatorView;
@property(nonatomic, assign ,getter=isPicked)BOOL picked;
@property(nonatomic, strong)UIColor *tintColor;
@end
