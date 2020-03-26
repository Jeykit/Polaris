//
//  PSSheetView.h
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import <UIKit/UIKit.h>


@protocol PSSheetViewSelectedDelegate <NSObject>

- (void)sheetViewOptionsSelected:(NSUInteger)index;

@end

@class PSPopupItem;
@interface PSSheetView : UIView
@property (nonatomic,weak)id <PSSheetViewSelectedDelegate>delegate ;

- (instancetype)initWithTitle:(NSString *)title
                       detail:(NSString *)detail
                        items:(NSArray *)items
                       cancel:(PSPopupItem *)cancel;

@end

