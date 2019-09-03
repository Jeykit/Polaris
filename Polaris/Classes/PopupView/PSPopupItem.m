//
//  PSPopupItem.m
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import "PSPopupItem.h"

@implementation PSPopupItem
- (instancetype)init{
    if (self = [super init]) {
        _textColor = [UIColor blackColor];
        _backgroundColor = [UIColor whiteColor];
        _disabled = NO;
        _height = 49.;
    }
    return self;
}
@end
