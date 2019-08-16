//
//  MUTipsView.m
//  Pods
//
//  Created by Jekity on 2017/10/17.
//
//

#import "PSTipsView.h"

@interface PSTipsView()
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIButton *innerButton;
@property(nonatomic, assign)CGFloat centerY;
@end
@implementation PSTipsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:_imageView];
        
        //        self.userInteractionEnabled = NO;
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font          = [UIFont systemFontOfSize:18.];
        _titleLabel.textColor     = [UIColor grayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
    }
    return self;
}
- (UILabel *)textLbael{
    return _titleLabel;
}
- (UIImageView *)placeholderImageView
{
    return _imageView;
}
-(UIButton *)button{
    if (!_innerButton) {
        _innerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.userInteractionEnabled = YES;
        
        [self addSubview:_innerButton];
    }
    return _innerButton;
}
- (void)layoutSubviews{
    _titleLabel.frame         = CGRectMake(12., 0, CGRectGetWidth(self.frame) - 24., 0);
    [_titleLabel sizeToFit];
    UIImage * tipsImage = _imageView.image;
    _imageView.frame = CGRectMake(0, 0, CGImageGetWidth(tipsImage.CGImage)/2., CGImageGetHeight(tipsImage.CGImage)/2.);
    _imageView.center = CGPointMake(self.center.x, CGRectGetHeight(self.frame) * 0.38);
    if (!CGRectEqualToRect(_imageView.frame, CGRectZero)) {
        _titleLabel.center = CGPointMake(_imageView.center.x, CGRectGetMaxY(_imageView.frame) + 12.);
    }else{
        _titleLabel.center = CGPointMake(self.center.x, CGRectGetHeight(self.frame) * 0.38);
        
    }
    _innerButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) * .62, 44.);
    CGPoint center = CGPointZero;
    if (!CGRectEqualToRect(_titleLabel.frame, CGRectZero)) {
        CGSize fontSize = [_titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - 24., MAXFLOAT)];
        center = CGPointMake(_titleLabel.center.x, _titleLabel.center.y + fontSize.height + 44.);
    }else if (!CGRectEqualToRect(_imageView.frame, CGRectZero)){
        center = CGPointMake(_imageView.center.x, CGRectGetMaxY(_imageView.frame) + 44.);
    }else{
        center = CGPointMake(self.center.x, CGRectGetHeight(self.frame) * 0.38);
    }
    _innerButton.center = center;
}
@end
