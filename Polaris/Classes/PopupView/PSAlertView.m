//
//  PSAlertView.m
//  Expecta
//
//  Created by Jekity on 2019/9/3.
//

#import "PSAlertView.h"
#import "PSPopupItem.h"

@interface PSAlertView()
@property (nonatomic, strong) UIView *titleView;
@end
@implementation PSAlertView
{
    CGFloat _margain;
    UIButton *_weakButton;
    CGFloat _calculateHeight;
}

- (instancetype)initWithTitle:(NSString *)title
                       detail:(NSString *)detail
                        items:(NSArray *)items
{
    
    if (self = [super init]) {
        _margain = 12.;
        self.backgroundColor = [UIColor colorWithRed:200./255. green:200./255.  blue:200./255.  alpha:.25];
        [self configuredTitleView:title
                           detail:detail];
        [self configuredItems:items];
        CGRect frame = [self screenFrame];
        self.frame = CGRectMake(0, 0, frame.size.width * 0.62, _calculateHeight);
    }
    return self;
    
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
- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor whiteColor];
    }
    return _titleView;
}
- (void)configuredTitleView:(NSString *)title
                     detail:(NSString *)detail
{
    if (title.length == 0) {
        return;
    }
    CGRect frame = [self screenFrame];
    UILabel *titleLabel = [[UILabel alloc] init];
    CGFloat titleLabelWidth = frame.size.width * .62;
    CGSize contentSize  = [title boundingRectWithSize:CGSizeMake(titleLabelWidth, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.]}
                                              context:nil].size;
    titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.frame = CGRectMake(0, _margain, titleLabelWidth, contentSize.height);
    [self.titleView addSubview:titleLabel];
    if (detail.length == 0) {
        self.titleView.frame = CGRectMake(0, 0, titleLabelWidth, contentSize.height + _margain*2);
        [self addSubview:self.titleView];
        return;
    }
    
    UILabel *detailLabel = [[UILabel alloc] init];
    CGSize contentsSize  = [detail boundingRectWithSize:CGSizeMake(titleLabelWidth, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.]}
                                                context:nil].size;
    detailLabel.text = title;
    detailLabel.backgroundColor = [UIColor whiteColor];
    detailLabel.textColor = [UIColor grayColor];
    detailLabel.font = [UIFont systemFontOfSize:14.];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.numberOfLines = 0;
    detailLabel.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + _margain, titleLabelWidth, contentsSize.height);
    [self.titleView addSubview:detailLabel];
    self.titleView.frame = CGRectMake(0, 0, titleLabelWidth, contentSize.height + detailLabel.frame.size.height + _margain*3);
    [self addSubview:self.titleView];
    _calculateHeight = CGRectGetMaxY(self.titleView.frame);
}
- (void)configuredItems:(NSArray *)items
{
    CGRect frame = self.titleView.frame;
    NSUInteger count = items.count;
     UIButton *previousButton = nil;
    if (count == 2 ) {
        for (NSUInteger i =0; i < count; i++) {
            PSPopupItem *item = items[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:item.title forState:UIControlStateNormal];
            [button setTitleColor:item.textColor forState:UIControlStateNormal];
            button.backgroundColor = item.backgroundColor;
            button.userInteractionEnabled = !item.disabled;
            button.tag = 100 + i;
            if (previousButton == nil) {
                button.frame = CGRectMake(0, frame.size.height+1, frame.size.width/2. - .5, item.height);
            }else{
                button.frame = CGRectMake(frame.size.width/2.+.5, frame.size.height+1, frame.size.width/2. - .5, item.height);
            }
            [button addTarget:self action:@selector(buttonByClicked:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
            previousButton = button;
        }
    }else{
        for (NSUInteger i =0; i < count; i++) {
            PSPopupItem *item = items[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:item.title forState:UIControlStateNormal];
            [button setTitleColor:item.textColor forState:UIControlStateNormal];
            button.backgroundColor = item.backgroundColor;
            button.userInteractionEnabled = !item.disabled;
            button.tag = 100 + i;
            if (previousButton == nil) {
                button.frame = CGRectMake(0, frame.size.height+1., frame.size.width, item.height);
            }else{
                button.frame = CGRectMake(0, CGRectGetMaxY(previousButton.frame) + 1, frame.size.width, item.height);
            }
            [button addTarget:self action:@selector(buttonByClicked:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
            previousButton = button;
        }
        
    }
    _weakButton = previousButton;
    _calculateHeight = CGRectGetMaxY(_weakButton.frame);
}
- (void)buttonByClicked:(UIButton *)button
{
    NSUInteger tag = button.tag - 100;
    if ([self.delegate respondsToSelector:@selector(alertViewOptionsSelected:)]) {
        [self.delegate alertViewOptionsSelected:tag];
    }
}
@end
