//
//  ZPHomePageView.m
//  ZPApp
//
//  Created by Jekity on 2019/7/10.
//  Copyright © 2019 Jekity. All rights reserved.
//

#import "PSPageControl.h"

@interface PSPageControl ()
@end

@implementation PSPageControl

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIImage *currentPageImage = [self valueForKey:@"currentPageImage"];
    UIImage *pageImage = [self valueForKey:@"pageImage"];
    CGSize size = pageImage.size;
    //计算圆点间距
    CGFloat marginX = size.width + self.margin ;
    //计算整个pageControll的宽度
    CGFloat newW = (self.subviews.count - 1 ) * marginX + currentPageImage.size.width - size.width;
    //设置新frame
    self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-(newW + size.width)/2, self.frame.origin.y, newW + size.width, self.frame.size.height);

    //遍历subview,设置圆点frame
    UIImageView *previousView = nil;
    for (int i=0; i<[self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(previousView?(CGRectGetMaxX(previousView.frame)+self.margin):0, dot.frame.origin.y, currentPageImage.size.width, currentPageImage.size.height)];
        }else {
            [dot setFrame:CGRectMake(previousView?(CGRectGetMaxX(previousView.frame)+self.margin):0, dot.frame.origin.y, size.width, size.height)];
        }
         previousView = dot;
    }
}
-(void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    [self layoutSubviews];
}
@end
