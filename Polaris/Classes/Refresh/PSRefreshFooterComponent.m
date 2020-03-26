//
//  PSRefreshFooterComponent.m
//  Pods
//
//  Created by Jekity on 2017/9/1.
//
//

#import "PSRefreshFooterComponent.h"
#import "UIView+PSNormal.h"


@implementation PSRefreshFooterComponent

- (void)layoutSubviews{
    [super layoutSubviews];
    self.yPS = self.scrollView.contentHeightPS;
}

static inline CGPoint RefreshingPoint(PSRefreshComponent *cSelf){
    UIScrollView * sc = cSelf.scrollView;
    CGFloat x = sc.xPS;
    CGFloat y = sc.contentHeightPS - sc.heightPS - cSelf.heightPS;
    return CGPointMake(x,y);
}

- (void)setScrollViewToRefreshLocation{
    [super setScrollViewToRefreshLocation];
    __weak typeof(self) weakSelf = self;
    
    dispatch_block_t animatedBlock = ^(void){
        if (weakSelf.isAutoRefreshing) {
            weakSelf.refreshState = PSRefreshStateScrolling;
            if (weakSelf.scrollView.contentHeightPS >= weakSelf.scrollView.heightPS &&
                weakSelf.scrollView.offsetYPS >= weakSelf.scrollView.contentHeightPS - weakSelf.scrollView.heightPS) {
                ///////////////////////////////////////////////////////////////////////////////////////////
                ///This condition can be pre-execute refreshHandler, and will not feel scrollview scroll
                ///////////////////////////////////////////////////////////////////////////////////////////
                [weakSelf.scrollView setContentOffset:RefreshingPoint(weakSelf)];
                [weakSelf PSDidScrollWithProgress:0.5 max:weakSelf.stretchOffsetYAxisThreshold];
            }
        }
        weakSelf.scrollView.insetBottomPS = weakSelf.preSetContentInsets.bottom + weakSelf.heightPS;
    };
    
    dispatch_block_t completionBlock = ^(void){
        if (weakSelf.refreshHandler) weakSelf.refreshHandler(self);
        if (weakSelf.isAutoRefreshing) {
            weakSelf.refreshState = PSRefreshStateReady;
            weakSelf.refreshState = PSRefreshStateRefreshing;
            [weakSelf PSDidScrollWithProgress:1. max:weakSelf.stretchOffsetYAxisThreshold];
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.preSetContentInsets = weakSelf.scrollView.realContentInsetPS;
        [weakSelf setAnimateBlock:animatedBlock completion:completionBlock];
    });
}

- (void)setScrollViewToOriginalLocation{
    [super setScrollViewToOriginalLocation];
    __weak typeof(self) weakSelf = self;
    [self setAnimateBlock:^{
        weakSelf.animating = YES;
        weakSelf.scrollView.insetBottomPS = weakSelf.preSetContentInsets.bottom;
    } completion:^{
        weakSelf.animating = NO;
        weakSelf.autoRefreshing = NO;
        weakSelf.refreshState = PSRefreshStateNone;
    }];
}

#pragma mark - contentOffset

static CGFloat MaxYForTriggeringRefresh(PSRefreshComponent * cSelf){
    UIScrollView * sc = cSelf.scrollView;
    CGFloat y = sc.contentHeightPS - sc.heightPS + cSelf.stretchOffsetYAxisThreshold*cSelf.heightPS + cSelf.preSetContentInsets.bottom;
    return y;
}

static CGFloat MinYForNone(PSRefreshComponent * cSelf){
    UIScrollView * sc = cSelf.scrollView;
    CGFloat y = sc.contentHeightPS - sc.heightPS + cSelf.preSetContentInsets.bottom;
    return y;
}

- (void)privateContentOffsetOfScrollViewDidChange:(CGPoint)contentOffset{
    [super privateContentOffsetOfScrollViewDidChange:contentOffset];
    if (self.refreshState != PSRefreshStateRefreshing) {
        if (self.isAutoRefreshing) return;
        
        self.preSetContentInsets = self.scrollView.realContentInsetPS;
        
        CGFloat originY = 0.0, maxY = 0.0, minY = 0.0;
        if (self.scrollView.contentHeightPS + self.preSetContentInsets.top <= self.scrollView.heightPS){
            maxY = self.stretchOffsetYAxisThreshold*self.heightPS;
            minY = 0;
            originY = contentOffset.y + self.preSetContentInsets.top;
            if (self.refreshState == PSRefreshStateScrolling){
                CGFloat progress = fabs(originY)/self.heightPS;
                if (progress <= self.stretchOffsetYAxisThreshold) {
                    self.progress = progress;
                }
            }
        }else{
            maxY = MaxYForTriggeringRefresh(self);
            minY = MinYForNone(self);
            originY = contentOffset.y;
            /////////////////////////
            ///uncontinuous callback
            /////////////////////////
            if (originY < minY - 50.0) return;
            CGFloat contentOffsetBottom = self.scrollView.contentHeightPS - self.scrollView.heightPS;
            if (self.refreshState == PSRefreshStateScrolling){
                CGFloat progress = fabs((originY - contentOffsetBottom - self.preSetContentInsets.bottom))/self.heightPS;
                if (progress <= self.stretchOffsetYAxisThreshold) {
                    self.progress = progress;
                }
            }
        }
        
        if (!self.scrollView.isDragging && self.refreshState == PSRefreshStateReady){
            self.autoRefreshing = NO;
            self.refreshState = PSRefreshStateRefreshing;
            [self setScrollViewToRefreshLocation];
        }
        else if (originY <= minY && !self.isAnimating){
            self.refreshState = PSRefreshStateNone;
        }
        else if (self.scrollView.isDragging && originY >= minY
                 && originY <= maxY && self.refreshState != PSRefreshStateScrolling){
            self.refreshState = PSRefreshStateScrolling;
        }
        else if (self.scrollView.isDragging && originY > maxY && !self.isAnimating
                 && self.refreshState != PSRefreshStateReady && !self.isShouldNoLongerRefresh){
            self.refreshState = PSRefreshStateReady;
        }
    }
}
@end
