//
//  PSPopupView.m
//  Expecta
//
//  Created by Jekity on 2019/9/3.
//

#import "PSPopupView.h"
#import "PSPopupItem.h"

@interface PSPopupView ()
@property (nonatomic,strong) UIView *contentView;
@end
@implementation PSPopupView
{
    CGFloat _margain;
    UIButton *_weakButton;
    CGFloat _calculateHeight;
    CGRect _viewFrame;
}
- (instancetype)initPopupViewWithView:(UIView *)view
                                items:(NSArray *)items
{
    if (self = [super init]) {
         [self addSubview:self.contentView];
        _margain = 12.;
        self.backgroundColor = [UIColor clearColor];
        _viewFrame = [self converViewRectToWindow:view];
        [self configuredItems:items];
        CGRect frame = [self screenFrame];
        CGFloat contentWidth = frame.size.width * 0.38;
        self.frame = CGRectMake(0, 0,contentWidth , _calculateHeight);
        if (CGRectGetMinX(_viewFrame) < contentWidth/2.) {
           _XPosition = CGRectGetMinX(_viewFrame);
        }else{
          _XPosition = CGRectGetMaxX(_viewFrame) - CGRectGetWidth(self.frame);
            CGFloat measureWidth = frame.size.width - CGRectGetMaxX(_viewFrame);
            if (measureWidth >= contentWidth/2.) {
                if (_viewFrame.size.width >= contentWidth) {
                    _XPosition += (_viewFrame.size.width - contentWidth)/2.;
                }else{
                    _XPosition -= (_viewFrame.size.width - contentWidth)/2.;
                }
            }
        }
        if (CGRectGetMinY(_viewFrame) < _calculateHeight) {
            _YPosition = CGRectGetMaxY(_viewFrame);
        }else{
            _YPosition = CGRectGetMinY(_viewFrame) - CGRectGetHeight(self.frame);
            CGRect rect = self.contentView.frame;
            rect.origin.y = 0;
            self.contentView.frame = rect;
        }
        
        if (_viewFrame.origin.y > _YPosition) {
            [self adjustButtonFrame];
            _YPosition -= 6.;
        }else{
            _YPosition += 6.;
        }

    }
    return self;
    
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithRed:200./255. green:200./255.  blue:200./255.  alpha:.25];
        _contentView.layer.cornerRadius = 5.;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}
- (CGRect)converViewRectToWindow:(UIView *)view{
    CGRect frame = [view convertRect:view.bounds toView:[UIApplication sharedApplication].keyWindow];
    return frame;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* _bezierPath = [UIBezierPath bezierPath];
    [[UIColor whiteColor] setFill];
    CGFloat startX = 0;
    if (CGRectGetMinX(_viewFrame) < rect.size.width/2.){
        startX = 24.;
    }else{
        CGRect frame = [self screenFrame];
        CGFloat measureWidth = frame.size.width - CGRectGetMaxX(_viewFrame);
        if (measureWidth >= rect.size.width/2.) {
            startX = rect.size.width/2.;
        }else{
            startX = rect.size.width -24.;
        }
    }
    CGFloat startY = 0;
    if (_viewFrame.origin.y > _YPosition) {
        startY = _calculateHeight - 1;
        [_bezierPath moveToPoint:CGPointMake(startX , startY)];
        [_bezierPath addLineToPoint:CGPointMake(startX + 9., startY - 13.)];
        [_bezierPath addLineToPoint:CGPointMake(startX - 9. , startY - 13.)];
    }else{
        [_bezierPath moveToPoint:CGPointMake(startX , startY)];
        [_bezierPath addLineToPoint:CGPointMake(startX + 9., startY + 13.)];
        [_bezierPath addLineToPoint:CGPointMake(startX - 9. , startY + 13.)];
    }
   
    [_bezierPath closePath];
    [_bezierPath fill];
    
}
- (CGRect)screenFrame
{
    static CGRect frame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frame = [UIScreen mainScreen].bounds;
    });
    return frame;
}
- (void)adjustButtonFrame
{
    CGRect frame = [self screenFrame];
    frame.size.width *= .38;
    frame.size.height = 0;
    NSUInteger count = self.contentView.subviews.count;
    UIButton *previousButton = nil;
    for (NSUInteger i = count; i > 0; i--) {
        UIButton *button = self.contentView.subviews[i - 1];
        CGRect rect = button.frame;
        if (previousButton == nil) {
            button.frame = CGRectMake(0, frame.size.height, frame.size.width, rect.size.height);
        }else{
            button.frame = CGRectMake(0, CGRectGetMaxY(previousButton.frame) + .5, frame.size.width, rect.size.height);
        }
        [button addTarget:self action:@selector(buttonByClicked:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:button];
        previousButton = button;
    }
}
- (void)configuredItems:(NSArray *)items
{
    CGRect frame = [self screenFrame];
    frame.size.width *= .38;
    frame.size.height = 0;
    NSUInteger count = items.count;
    UIButton *previousButton = nil;
    for (NSUInteger i =0; i < count; i++) {
        PSPopupItem *item = items[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setTitleColor:item.textColor forState:UIControlStateNormal];
        button.backgroundColor = item.backgroundColor;
        button.userInteractionEnabled = !item.disabled;
        button.tag = 100 + i;
        if (previousButton == nil) {
            button.frame = CGRectMake(0, frame.size.height, frame.size.width, item.height);
        }else{
            button.frame = CGRectMake(0, CGRectGetMaxY(previousButton.frame) + .5, frame.size.width, item.height);
        }
        [button addTarget:self action:@selector(buttonByClicked:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:button];
        previousButton = button;
    }
    _weakButton = previousButton;
    _contentView.frame = CGRectMake(0, 13., frame.size.width,  CGRectGetMaxY(_weakButton.frame));
    _calculateHeight = CGRectGetMaxY(_weakButton.frame) + 14.;
}
- (void)buttonByClicked:(UIButton *)button
{
    NSUInteger tag = button.tag - 100;
    if ([self.delegate respondsToSelector:@selector(popupViewOptionsSelected:)]) {
        [self.delegate popupViewOptionsSelected:tag];
    }
}
@end
