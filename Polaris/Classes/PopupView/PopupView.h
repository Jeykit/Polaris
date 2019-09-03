//
//  PopupView.h
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import <UIKit/UIKit.h>

@class PSPopupItem;
NS_ASSUME_NONNULL_BEGIN

@interface PopupView : UIView
+ (instancetype)sharedInstance;
- (void)showSheetViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void(^)(NSUInteger index))block;

- (void)showAlertViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                          block:(void(^)(NSUInteger index))block;
@end

NS_ASSUME_NONNULL_END