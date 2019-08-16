//
//  MUCarouselView.h
//  MUKit_Example
//
//  Created by Jekity on 2017/11/9.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPageControl.h"


@interface PSCarouselView : UIView

/**图片模型数组，支持任意对象*/
@property (nonatomic,strong) NSArray *imageArray;

@property (nonatomic, copy) void(^configuredImageBlock)(UIImageView *imageView ,NSUInteger index ,id model);

/**点击图片后调用的block*/
@property (nonatomic, copy) void(^clickedImageBlock)(UIImageView *imageView ,NSUInteger index ,id model);

/**图片滑动后调用的block*/
@property(nonatomic, copy)void (^doneUpdateCurrentIndex)(NSUInteger index ,id model);

/**轮播时间，默认2s*/
@property(assign ,nonatomic) NSTimeInterval duration;

/**内容边距*/
@property (nonatomic,assign) NSUInteger contentMargain;

/**自动滚动，默认为Yes*/
@property (assign ,nonatomic, getter=isAutoScroll) BOOL autoScroll;

//当前显示的轮播图索引
@property(nonatomic, assign ,readonly) NSUInteger currentIndex;


@property (nonatomic, strong) PSPageControl *pageControl;
@end
