//
//  UITableView+TableViewManager.h
//  Expecta
//
//  Created by Jekity on 2019/7/15.
//

#import <UIKit/UIKit.h>
#import "TableViewManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (TableViewManager)

@property (nonatomic, strong ,readonly) TableViewManager *tableViewM;
- (void)configureTableViewWithBlock:(void (^)(TableViewManager *tableViewM))block;

@end

NS_ASSUME_NONNULL_END
