//
//  PSRefreshHeaderComponent.m
//  Pods
//
//  Created by Jekity on 2017/8/30.
//
//

#import "PSRefreshHeaderComponent.h"
#import "PSRefreshComponent.h"
#import "UIView+PSNormal.h"


@implementation PSRefreshHeaderComponent



- (void)layoutSubviews{
    [super layoutSubviews];
    self.yPS = -self.heightPS;
}

static inline CGPoint RefreshingPoint(PSRefreshComponent *cSelf){
    UIScrollView * sc = cSelf.scrollView;
    CGFloat x = sc.xPS;
    CGFloat y = -(cSelf.heightPS + cSelf.preSetContentInsets.top);
    return CGPointMake(x,y);
}

- (void)setScrollViewToRefreshLocation{
    [super setScrollViewToRefreshLocation];
    __weak typeof(self) weakSelf = self;
    
    dispatch_block_t animatedBlock = ^(void){
        if (weakSelf.isAutoRefreshing) {
            weakSelf.refreshState = PSRefreshStateScrolling;
            ///////////////////////////////////////////////////////////////////////////////////////////
            /*
             In general, we use UITableView, especially UITableView need to use the drop-down refresh,
             we rarely set SectionHeader. Unfortunately, if you use SectionHeader and integrate with
             UIRefreshControl or other third-party libraries, the refresh effect will be very ugly.
             
             This code has two effects:
             1.  when using SectionHeader refresh effect is still very natural.
             2.  when your scrollView using preloading technology, only in the right place,
             such as pull down a pixel you can see the refresh control case, will show the
             refresh effect. If the pull-down distance exceeds the height of the refresh control,
             then the refresh control has long been unable to appear on the screen,
             indicating that the top of the contentOffset office there is a long distance,
             this time, even if you call the beginRefreshing method, ScrollView position and effect
             are Will not be affected, so the deal is very friendly in the data preloading technology.
             */
            CGFloat min = -weakSelf.preSetContentInsets.top;
            CGFloat max = -(weakSelf.preSetContentInsets.top-weakSelf.heightPS);
            if (weakSelf.scrollView.offsetYPS >= min && weakSelf.scrollView.offsetYPS <= max) {
                [weakSelf.scrollView setContentOffset:RefreshingPoint(weakSelf)];
                [weakSelf PSDidScrollWithProgress:0.5 max:weakSelf.stretchOffsetYAxisThreshold];
                weakSelf.scrollView.insetTopPS = weakSelf.heightPS + weakSelf.preSetContentInsets.top;
            }
            ///////////////////////////////////////////////////////////////////////////////////////////
        }else{
            weakSelf.scrollView.insetTopPS = weakSelf.heightPS + weakSelf.preSetContentInsets.top;
        }
    };
    
    dispatch_block_t completionBlock = ^(void){
        if (weakSelf.isAutoRefreshing) {
            weakSelf.refreshState = PSRefreshStateReady;
            weakSelf.refreshState = PSRefreshStateRefreshing;
            [weakSelf PSDidScrollWithProgress:1. max:weakSelf.stretchOffsetYAxisThreshold];
        }
        if (weakSelf.refreshHandler) weakSelf.refreshHandler(self);
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.preSetContentInsets = weakSelf.scrollView.realContentInsetPS;
        [weakSelf setAnimateBlock:animatedBlock completion:completionBlock];
    });
}

- (void)setScrollViewToOriginalLocation{
    [super setScrollViewToOriginalLocation];
    __weak typeof(self) weakSelf = self;
    dispatch_block_t animationBlock = ^{
        weakSelf.animating = YES;
        weakSelf.scrollView.insetTopPS = weakSelf.preSetContentInsets.top;
    };
    
    dispatch_block_t completion = ^{
        weakSelf.animating = NO;
        weakSelf.autoRefreshing = NO;
        weakSelf.refreshState = PSRefreshStateNone;
    };
    [self setAnimateBlock:animationBlock completion:completion];
}

#pragma mark - contentOffset

static CGFloat MaxYForTriggeringRefresh( PSRefreshComponent* cSelf){
    CGFloat y = -cSelf.preSetContentInsets.top + cSelf.stretchOffsetYAxisThreshold * cSelf.yPS;
    return y;
}

static CGFloat MinYForNone(PSRefreshComponent * cSelf){
    CGFloat y = -cSelf.preSetContentInsets.top;
    return y;
}

- (void)privateContentOffsetOfScrollViewDidChange:(CGPoint)contentOffset{
    [super privateContentOffsetOfScrollViewDidChange:contentOffset];
    CGFloat maxY = MaxYForTriggeringRefresh(self);
    CGFloat minY = MinYForNone(self);
    CGFloat originY = contentOffset.y;
    
    if (self.refreshState == PSRefreshStateRefreshing) {
        //fix hover problem of sectionHeader
        if (originY < 0 && (-originY >= self.preSetContentInsets.top)) {
            CGFloat threshold = self.preSetContentInsets.top + self.heightPS;
            if (-originY > threshold) {
                self.scrollView.insetTopPS = threshold;
            }else{
                self.scrollView.insetTopPS = -originY;
            }
        }else{
            if (self.scrollView.insetTopPS != self.preSetContentInsets.top) {
                self.scrollView.insetTopPS = self.preSetContentInsets.top;
            }
        }
    }else{
        if (self.isAutoRefreshing) return;
        
        self.preSetContentInsets = self.scrollView.realContentInsetPS;
        
        if (self.refreshState == PSRefreshStateScrolling){
            CGFloat progress = (fabs((double)originY) - self.preSetContentInsets.top)/self.heightPS;
            if (progress <= self.stretchOffsetYAxisThreshold) {
                self.progress = progress;
            }
        }
        
        if (!self.scrollView.isDragging && self.refreshState == PSRefreshStateReady){
            self.autoRefreshing = NO;
            self.refreshState = PSRefreshStateRefreshing;
            [self setScrollViewToRefreshLocation];
        }
        else if (originY >= minY && !self.isAnimating){
            self.refreshState = PSRefreshStateNone;
        }
        else if (self.scrollView.isDragging && originY <= minY
                 && originY >= maxY && self.refreshState != PSRefreshStateScrolling){
            self.refreshState = PSRefreshStateScrolling;
        }
        else if (self.scrollView.isDragging && originY < maxY && !self.isAnimating
                 && self.refreshState != PSRefreshStateReady && !self.isShouldNoLongerRefresh){
            self.refreshState = PSRefreshStateReady;
        }
    }
}

@end
