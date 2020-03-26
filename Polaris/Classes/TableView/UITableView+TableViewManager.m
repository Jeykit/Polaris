//
//  UITableView+TableViewManager.m
//  Expecta
//
//  Created by Jekity on 2019/7/15.
//

#import "UITableView+TableViewManager.h"
#import "TableViewManager+Private.h"
#import <objc/runtime.h>

@implementation UITableView (TableViewManager)
- (TableViewManager *)tableViewM{
    TableViewManager *tableViewM = objc_getAssociatedObject(self, @selector(tableViewM));
    if (!tableViewM) {
        tableViewM = [[TableViewManager alloc] initWithTableView:self];
        objc_setAssociatedObject(self, @selector(tableViewM), tableViewM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tableViewM;
}

- (void)configureTableViewWithBlock:(void (^)(TableViewManager * _Nonnull))block
{
    if (block != nil) {
        block(self.tableViewM);
    }
}
@end
