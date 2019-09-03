//
//  PSPopupItem.h
//  Expecta
//
//  Created by Jekity on 2019/8/30.
//

#import <Foundation/Foundation.h>

@interface PSPopupItem : NSObject
@property (nonatomic, copy) NSString     *title;
@property (nonatomic, strong) UIColor    *textColor;// defalut is blackColor
@property (nonatomic, strong) UIColor    *backgroundColor;// defalut is whiteColor
@property (nonatomic, assign) BOOL       disabled; //defalut is NO
@property (nonatomic, assign) NSUInteger height;// defalut is 49.;
@end

