//
//  MUAssetsFooterView.m
//  MUKit_Example
//
//  Created by Jekity on 2017/11/8.
//  Copyright © 2017年 Jeykit. All rights reserved.
//

#import "PSAssetsFooterView.h"

@implementation PSAssetsFooterView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc]init];
        [self addSubview:_textLabel];
        _textLabel.textColor = [UIColor grayColor];
        _textLabel.font  = [UIFont systemFontOfSize:17.];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
@end
