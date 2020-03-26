//
//  MUTapDetectingView.h
//  MUKit_Example
//
//  Created by Jekity on 2017/11/9.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSTapDetectingViewDelegate;

@interface PSTapDetectingView : UIView {}

@property (nonatomic, weak) id <PSTapDetectingViewDelegate> tapDelegate;

@end

@protocol PSTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end

