//
//  MUCarouselView.m
//  MUKit_Example
//
//  Created by Jekity on 2017/11/9.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import "PSCarouselView.h"

#define  kWidth  self.bounds.size.width
#define  kHeight self.bounds.size.height
#define kPageControlMargin 10.0f

@interface PSCarouselView()<UIScrollViewDelegate>
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIImageView *lastImgView;
@property(strong, nonatomic) UIImageView *currentImgView;
@property(strong, nonatomic) UIImageView *nextImgView;
@property(strong, nonatomic) NSTimer *timer;
@property (nonatomic,strong) NSArray *innerArray;
@end

@implementation PSCarouselView{
    NSInteger _kImageCount;
    NSInteger _nextPhotoIndex;
    NSInteger _lastPhotoIndex;
    CGSize _pageImageSize;
    CGFloat _currentImageHeight;
}
- (instancetype)init{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}
- (void)initialize {
    _duration = 2;
    _autoScroll = YES;
    _currentIndex = 0;
}
#pragma mark - lazy loading
-(UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
        _scrollView.layer.masksToBounds = YES;
    }
    return _scrollView;
}
-(PSPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[PSPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}
-(UIImageView *)lastImgView{
    if (_lastImgView == nil) {
        _lastImgView = [[UIImageView alloc] init];
    }
    return _lastImgView;
}
-(UIImageView *)currentImgView{
    if (_currentImgView == nil) {
        _currentImgView = [[UIImageView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapActionInImageView:)];
        [_currentImgView addGestureRecognizer:tap];
        _currentImgView.userInteractionEnabled = YES;
    }
    return _currentImgView;
}
-(UIImageView *)nextImgView{
    if (_nextImgView == nil) {
        _nextImgView = [[UIImageView alloc] init];
    }
    return _nextImgView;
}
-(void)configure{
    
    self.scrollView.frame = CGRectMake(0, 0, kWidth, kHeight);
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.lastImgView];
    [self.scrollView addSubview:self.currentImgView];
    [self.scrollView addSubview:self.nextImgView];
    [self addSubview:self.pageControl];
    if (self.currentIndex > _kImageCount - 1 || self.currentIndex == 0) {
        [self setImageView:_lastImgView withSubscript:(_kImageCount -1)];
        [self setImageView:_currentImgView  withSubscript:0];
        [self setImageView:_nextImgView  withSubscript:_kImageCount == 1 ? 0 : 1];
        _nextPhotoIndex = 1;
        _lastPhotoIndex = _kImageCount - 1;
    }else if(self.currentIndex == _kImageCount - 1){
        [self setImageView:_lastImgView withSubscript:_currentIndex - 1];
        [self setImageView:_currentImgView withSubscript:_currentIndex];
        [self setImageView:_nextImgView  withSubscript:0];
        _nextPhotoIndex = 0;
        _lastPhotoIndex = _currentIndex - 1;
    }else{
        [self setImageView:_lastImgView withSubscript:_currentIndex - 1];
        [self setImageView:_currentImgView withSubscript:_currentIndex];
        [self setImageView:_nextImgView   withSubscript:_currentIndex + 1];
        _nextPhotoIndex = _currentIndex + 1;
        _lastPhotoIndex = _currentIndex - 1;
    }
    _scrollView.contentSize = CGSizeMake(kWidth * 3, kHeight);
    _scrollView.contentOffset = CGPointMake(kWidth, 0);
    _pageControl.numberOfPages = _kImageCount;
    _pageControl.currentPage = 0;
    self.pageControl.center = CGPointMake(kWidth/2., kHeight - 24.);
    
    [self layoutIfNeeded];
}
#pragma mark - scrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (ceil(scrollView.contentOffset.x) <= 0) {
        _nextImgView.image = _currentImgView.image;
        _currentImgView.image = _lastImgView.image;
        _lastImgView.image = _kImageCount>1?nil:_lastImgView.image;
        scrollView.contentOffset = CGPointMake(kWidth, 0);
        if (_lastPhotoIndex <= 0) {
            _lastPhotoIndex = _kImageCount - 1;
            _nextPhotoIndex = _lastPhotoIndex - (_kImageCount - 2);
        } else {
            _lastPhotoIndex--;
            if (_nextPhotoIndex == 0) {
                _nextPhotoIndex = _kImageCount - 1;
            } else {
                _nextPhotoIndex--;
            }
        }
        [self setImageView:_lastImgView  withSubscript:_lastPhotoIndex];
    }
    if ((ceil(scrollView.contentOffset.x)  >= ceil(kWidth)*2.)) {
        _lastImgView.image = _currentImgView.image;
        _currentImgView.image = _nextImgView.image;
        scrollView.contentOffset = CGPointMake(kWidth, 0);
        _nextImgView.image = _kImageCount>1?nil:_nextImgView.image;
        if (_nextPhotoIndex >= _kImageCount - 1 ) {
            _nextPhotoIndex = 0;
            _lastPhotoIndex = _nextPhotoIndex + (_kImageCount - 2);
        } else{
            _nextPhotoIndex++;
            if (_lastPhotoIndex == _kImageCount - 1) {
                _lastPhotoIndex = 0;
            } else {
                _lastPhotoIndex++;
            }
        }
        [self setImageView:_nextImgView  withSubscript:_nextPhotoIndex];
        
    }
    if (self.doneUpdateCurrentIndex) {
        NSUInteger index = _nextPhotoIndex==0?_kImageCount:_nextPhotoIndex;
        self.doneUpdateCurrentIndex(index - 1 ,self.innerArray[index - 1]);
    }
    if (_nextPhotoIndex - 1 < 0) {
        self.pageControl.currentPage = _kImageCount - 1;
    } else {
        self.pageControl.currentPage = _nextPhotoIndex - 1;
    }
    
    
}
- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
    if (imageArray.count == 0) {
        return;
    }
    _kImageCount = imageArray.count;
    _innerArray = [imageArray mutableCopy];
    [self configure];
}
-(void)setImageView:(UIImageView *)imgView withSubscript:(NSInteger)subcript{
    if (self.configuredImageBlock) {
        self.configuredImageBlock (imgView ,subcript ,self.innerArray[subcript]);
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self invalidateTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self addTimer];
    }
}
#pragma mark - 系统方法
-(void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self invalidateTimer];
    }
}
-(void)didMoveToSuperview{
    
    [self invalidateTimer];
    [self addTimer];
}
#pragma mark - 手势点击事件
-(void)handleTapActionInImageView:(UITapGestureRecognizer *)tap {
    
    if (self.clickedImageBlock) {
        if (_nextPhotoIndex == 0) {
            NSUInteger index = _kImageCount-1;
            self.clickedImageBlock((UIImageView *)tap.view , index,self.innerArray[index]);
        }else{
            NSUInteger index = _nextPhotoIndex-1;
            self.clickedImageBlock((UIImageView *)tap.view , index,self.innerArray[index]);
        }
    }
}
-(void)dealloc {
    _scrollView.delegate = nil;
}

- (void)addTimer {
    [self invalidateTimer];
    if (_autoScroll) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(timerAction) userInfo:self repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
- (void)invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}
#pragma maek - Private Method
-(void)timerAction{
    [_scrollView setContentOffset:CGPointMake(kWidth*2, 0) animated:YES];
    
}
- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (autoScroll) {
        [self addTimer];
    } else {
        [self invalidateTimer];
    }
}
-(void)setDuration:(NSTimeInterval)duration{
    _duration = duration;
    if (duration < 1.0f) {
        _duration = 2.0f;
    }
    [self addTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageWidth = kWidth - 2*self.contentMargain;
    self.scrollView.contentSize = CGSizeMake(kWidth * 3, kHeight);
    self.scrollView.contentOffset = CGPointMake(kWidth, 0);
    
    self.lastImgView.frame = CGRectMake(self.contentMargain, 0, imageWidth, kHeight);
    self.currentImgView.frame = CGRectMake(kWidth+self.contentMargain, 0, imageWidth, kHeight);
    self.nextImgView.frame = CGRectMake(kWidth * 2+self.contentMargain, 0, imageWidth , kHeight);
    
}

@end
