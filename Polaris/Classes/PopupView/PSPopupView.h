//
//  PSPopupView.h
//  Expecta
//
//  Created by Jekity on 2019/9/3.
//

#import <UIKit/UIKit.h>

@protocol PSPopupViewSelectedDelegate <NSObject>

- (void)popupViewOptionsSelected:(NSUInteger)index;

@end
@interface PSPopupView : UIView

@property (nonatomic,weak)id <PSPopupViewSelectedDelegate>delegate ;
- (instancetype)initPopupViewWithView:(UIView *)view
                                items:(NSArray *)items;
@property (nonatomic, assign, readonly) CGFloat XPosition;
@property (nonatomic, assign, readonly) CGFloat YPosition;
@end

