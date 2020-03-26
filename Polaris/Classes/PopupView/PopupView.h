//
//  PopupView.h
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import <UIKit/UIKit.h>

@class PSPopupItem;
@interface PopupView : UIView
+ (instancetype)sharedInstance;
- (void)showSheetViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void(^)(NSUInteger index))block;

- (void)showSheetViewWithTitile:(NSString *)title
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void(^)(NSUInteger index))block;

- (void)showSheetViewWithItems:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void(^)(NSUInteger index))block;

- (void)showAlertViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                          block:(void(^)(NSUInteger index))block;

- (void)showPopupViewWithView:(UIView *)view
                      options:(NSArray *)options
                        block:(void(^)(NSUInteger index))block;
@end

