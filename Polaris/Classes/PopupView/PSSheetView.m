//
//  PSSheetView.m
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import "PSSheetView.h"
#import "PSPopupItem.h"

@interface PSSheetView()
@property (nonatomic, strong) UIView *titleView;
@end
@implementation PSSheetView
{
    CGFloat _margain;
    UIButton *_weakButton;
    CGFloat _calculateHeight;
}

- (instancetype)initWithTitle:(NSString *)title
                       detail:(NSString *)detail
                        items:(NSArray *)items
                       cancel:(PSPopupItem *)cancel
{
    
    if (self = [super init]) {
        _margain = 12.;
        self.backgroundColor = [UIColor colorWithRed:200./255. green:200./255.  blue:200./255.  alpha:.25];
        if (title.length > 0) {
            [self configuredTitleView:title
                               detail:detail];
        }
        [self configuredItems:items];
        [self configuredCancel:cancel];
        CGRect frame = [self screenFrame];
        self.frame = CGRectMake(0, 0, frame.size.width, _calculateHeight);
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
    CGFloat titleLabelWidth = frame.size.width - 48.;
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
    titleLabel.frame = CGRectMake(0, _margain, frame.size.width, contentSize.height);
    [self.titleView addSubview:titleLabel];
    if (detail.length == 0) {
        self.titleView.frame = CGRectMake(0, 0, frame.size.width, contentSize.height + _margain*2);
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
    detailLabel.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + _margain, frame.size.width, contentsSize.height);
    [self.titleView addSubview:detailLabel];
    self.titleView.frame = CGRectMake(0, 0, frame.size.width, contentSize.height + detailLabel.frame.size.height + _margain*3);
    [self addSubview:self.titleView];
    _calculateHeight = CGRectGetMaxY(self.titleView.frame);
}
- (void)configuredItems:(NSArray *)items
{
    CGRect frame =CGRectZero;
    if (_titleView) {
        frame = _titleView.frame;
    }else{
        frame = [self screenFrame];
        frame.size.height = 0;
    }
    UIButton *previousButton = nil;
    for (NSUInteger i =0; i < items.count; i++) {
        PSPopupItem *item = items[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setTitleColor:item.textColor forState:UIControlStateNormal];
        button.backgroundColor = item.backgroundColor;
        button.userInteractionEnabled = !item.disabled;
        button.tag = 100 + i;
        if (previousButton == nil) {
            button.frame = CGRectMake(0, frame.size.height + 1, frame.size.width, item.height);
        }else{
            button.frame = CGRectMake(0, CGRectGetMaxY(previousButton.frame) + 1, frame.size.width, item.height);
        }
        [button addTarget:self action:@selector(buttonByClicked:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:button];
        previousButton = button;
    }
    _weakButton = previousButton;
    _calculateHeight = CGRectGetMaxY(_weakButton.frame);
}
- (void)configuredCancel:(PSPopupItem *)item
{
    if (item == nil) {
        return;
    }
    CGFloat maxY = 0;
    if (_weakButton == nil) {
        CGRect frame = self.titleView.frame;
        maxY = CGRectGetMaxY(frame) + _margain;
    }else{
        maxY = CGRectGetMaxY(_weakButton.frame) + _margain;
    }
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:item.title forState:UIControlStateNormal];
    [cancelButton setTitleColor:item.textColor forState:UIControlStateNormal];
    cancelButton.backgroundColor = item.backgroundColor;
    cancelButton.userInteractionEnabled = !item.disabled;
    cancelButton.tag = 100100;
    cancelButton.frame = CGRectMake(0, maxY, _weakButton.frame.size.width, item.height);
    [cancelButton addTarget:self action:@selector(buttonByClicked:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:cancelButton];
    _calculateHeight = CGRectGetMaxY(cancelButton.frame);
}
- (void)buttonByClicked:(UIButton *)button
{
    NSUInteger tag = button.tag - 100;
    if ([self.delegate respondsToSelector:@selector(sheetViewOptionsSelected:)]) {
        [self.delegate sheetViewOptionsSelected:tag];
    }
}
@end
