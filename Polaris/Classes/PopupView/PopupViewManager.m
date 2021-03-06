//
//  PopupViewManager.m
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import "PopupViewManager.h"
#import "PopupView.h"


@implementation PopupViewManager
+ (void)showSheetViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void (^)(NSUInteger))block{
    
    [[PopupView sharedInstance] showSheetViewWithTitile:title
                                                 detail:detail
                                                options:options
                                                 cancel:cancel
                                                  block:block];
    
}
+ (void)showSheetViewWithTitile:(NSString *)title
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void (^)(NSUInteger))block{
    
    [[PopupView sharedInstance] showSheetViewWithTitile:title
                                                  detail:nil
                                                 options:options
                                                  cancel:cancel
                                                   block:block];
    
}
+ (void)showSheetViewWithItems:(NSArray *)options
                        cancel:(PSPopupItem *)cancel
                         block:(void (^)(NSUInteger))block{
    [[PopupView sharedInstance] showSheetViewWithTitile:nil
                                                 detail:nil
                                                options:options
                                                 cancel:cancel
                                                  block:block];
}
+ (void)showAlertViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                          block:(void (^)(NSUInteger))block{
    
    [[PopupView sharedInstance] showAlertViewWithTitile:title
                                                 detail:detail
                                                options:options
                                                  block:block];
}

+ (void)showPopupViewWithView:(UIView *)view
                      options:(NSArray *)options
                        block:(void (^)(NSUInteger))block
{
    [[PopupView sharedInstance] showPopupViewWithView:view
                                              options:options
                                                block:block];
    
}
@end
