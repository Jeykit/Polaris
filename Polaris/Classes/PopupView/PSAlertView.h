//
//  PSAlertView.h
//  Expecta
//
//  Created by Jekity on 2019/9/3.
//

#import <UIKit/UIKit.h>

@protocol PSAlertViewSelectedDelegate <NSObject>

- (void)alertViewOptionsSelected:(NSUInteger)index;

@end
@class PSPopupItem;
@interface PSAlertView : UIView
@property (nonatomic,weak)id <PSAlertViewSelectedDelegate>delegate ;
- (instancetype)initWithTitle:(NSString *)title
                       detail:(NSString *)detail
                        items:(NSArray *)items;
@end

