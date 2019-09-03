//
//  PopupViewManager.h
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import <Foundation/Foundation.h>
#import "PSPopupItem.h"

@interface PopupViewManager : NSObject

+ (void)showSheetViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                         cancel:(PSPopupItem *)cancel
                          block:(void(^)(NSUInteger index))block;

+ (void)showAlertViewWithTitile:(NSString *)title
                         detail:(NSString *)detail
                        options:(NSArray *)options
                          block:(void(^)(NSUInteger index))block;

@end
