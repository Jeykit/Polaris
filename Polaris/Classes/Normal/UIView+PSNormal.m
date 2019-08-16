//
//  UIView+PSNormal.m
//  Polaris_Example
//
//  Created by Jekity on 2019/7/18.
//  Copyright © 2019 392071745@qq.com. All rights reserved.
//

#import "UIView+PSNormal.h"

@implementation UIView (PSNormal)

- (void)setWidthPS:(CGFloat)widthPS
{
    CGRect frame = self.frame;
    frame.size.width = widthPS;
    self.frame = frame;
}
- (CGFloat)widthPS{
    return CGRectGetWidth(self.frame);
}
- (void)setHeightPS:(CGFloat)heightPS
{
    CGRect frame = self.frame;
    frame.size.height = heightPS;
    self.frame = frame;
}

- (CGFloat)heightPS
{
     return CGRectGetHeight(self.frame);
}
- (void)setXPS:(CGFloat)xPS{
    CGRect frame = self.frame;
    frame.origin.x = xPS;
    self.frame = frame;
}
-(CGFloat)xPS{
    return self.frame.origin.x;
}
- (void)setYPS:(CGFloat)yPS{
    CGRect frame = self.frame;
    frame.origin.y = yPS;
    self.frame = frame;
}
-(CGFloat)yPS{
    return self.frame.origin.y;
}
- (void)setSizePS:(CGSize)sizePS{
    CGRect frame = self.frame;
    frame.size = sizePS;
    self.frame = frame;
}
-(CGSize)sizePS{
    return self.frame.size;
}
- (void)setOriginPS:(CGPoint)originPS
{
    CGRect frame = self.frame;
    frame.origin = originPS;
    self.frame = frame;
}
-(void)setOrigin_Mu:(CGPoint)origin_Mu{
}
-(CGPoint)originPS{
    return self.frame.origin;
}
- (void)setCenterXPS:(CGFloat)centerXPS{
    CGPoint center = self.center;
    center.x = centerXPS;
    self.center = center;
}
-(CGFloat)centerXPS{
    return self.center.x;
}
- (void)setCenterYPS:(CGFloat)centerYPS{
    CGPoint center = self.center;
    center.y = centerYPS;
    self.center = center;
}
-(CGFloat)centerYPS{
    return self.center.y;
}
@end

@implementation UIScrollView (PSNormal)

- (CGFloat)offsetXPS
{
    return self.contentOffset.x;
}
- (void)setOffsetXPS:(CGFloat)offsetXPS
{
    CGPoint offset = self.contentOffset;
    offset.x = offsetXPS;
    self.contentOffset = offset;
}
- (CGFloat)offsetYPS{
    return self.contentOffset.y;
}
-(void)setOffsetYPS:(CGFloat)offsetYPS{
    CGPoint offset = self.contentOffset;
    offset.y = offsetYPS;
    self.contentOffset = offset;
}
- (CGFloat)insetTopPS{
    return self.realContentInsetPS.top;
}

- (void)setInsetTopPS:(CGFloat)insetTopPS{
    UIEdgeInsets inset = self.contentInset;
    inset.top = insetTopPS;
    if (@available(iOS 11.0, *)) {
        inset.top -= (self.adjustedContentInset.top - self.contentInset.top);
    }
    self.contentInset = inset;
}

- (CGFloat)insetBottomPS{
    return self.realContentInsetPS.bottom;
}

- (void)setInsetBottomPS:(CGFloat)insetBottomPS{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = insetBottomPS;
    if (@available(iOS 11.0, *)) {
        inset.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom);
    }
    self.contentInset = inset;
}
- (CGFloat)contentHeightPS{
    return self.contentSize.height;
}
- (UIEdgeInsets)realContentInsetPS{
    if (@available(iOS 11.0, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

@end
