//
//  UIView+PSNormal.h
//  Polaris_Example
//
//  Created by Jekity on 2019/7/18.
//  Copyright © 2019 392071745@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PSNormal)
@property (assign,nonatomic) CGFloat xPS;
@property (assign,nonatomic) CGFloat yPS;

@property (nonatomic, assign) CGSize sizePS;
@property (nonatomic, assign) CGPoint originPS;

@property (nonatomic, assign) CGFloat centerXPS;
@property (nonatomic, assign) CGFloat centerYPS;
@property (nonatomic, assign) CGFloat widthPS;
@property (nonatomic, assign) CGFloat heightPS;
@end

@interface UIScrollView (PSNormal)
@property (assign, readonly) UIEdgeInsets realContentInsetPS;
@property (nonatomic ,assign) CGFloat offsetXPS;
@property (nonatomic ,assign) CGFloat offsetYPS;
@property (nonatomic ,assign) CGFloat insetTopPS;
@property (nonatomic ,assign) CGFloat insetBottomPS;
@property (nonatomic, readonly) CGFloat contentHeightPS;
@end
NS_ASSUME_NONNULL_END
