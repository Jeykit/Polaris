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
+ (void)showAlertViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                          block:(void (^)(NSUInteger))block{
    
    [[PopupView sharedInstance] showAlertViewWithTitile:title
                                                 detail:detail
                                                options:options
                                                  block:block];
}
@end
