//
//  MUZoomingScrollView.h
//  MUKit_Example
//
//  Created by Jekity on 2017/11/10.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PSTapDetectingView.h"
#import "PSTapDetectingImageView.h"

@protocol PSZoomingScrollViewDelegate;

@interface PSZoomingScrollView : UIScrollView<UIScrollViewDelegate, PSTapDetectingImageViewDelegate, PSTapDetectingViewDelegate>
@property(nonatomic, strong)UIImage *image;
@property(nonatomic, strong )UIImageView *imageView;
@property (nonatomic,assign) NSUInteger             mediaType;//1代表图片，2代表视频

@property (nonatomic, weak) id <PSZoomingScrollViewDelegate> tapDelegate;
@end

@protocol PSZoomingScrollViewDelegate <NSObject>

@optional

- (void)muZoomingScrollView:(UIScrollView *)view mediaType:(NSInteger)mediaType;
- (void)muPlayVideo:(UIScrollView *)view mediaType:(NSInteger)mediaType;
- (void)muZoomingScrollViewDragging:(UIScrollView *)view cancle:(BOOL)cancle;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end
