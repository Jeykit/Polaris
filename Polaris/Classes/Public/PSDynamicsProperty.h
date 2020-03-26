//
//  PSDynamicsProperty.h
//  Polaris_Example
//
//  Created by Jekity on 2019/7/18.
//  Copyright © 2019 392071745@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,PSDynamicPropertyType){
    
    PSDynamicPropertyTypeAssign = 1 << 0,
    PSDynamicPropertyTypeRetain = 1 << 1,
};
@interface PSDynamicsProperty : NSObject

-(BOOL)addDynamicPropertyToObject:(id)object propertyName:(NSString *)name type:(PSDynamicPropertyType)type;

-(CGFloat)getFloatValueFromObject:(id)object name:(NSString *)name;
-(void)setFloatValueToObject:(id)object name:(NSString *)name value:(CGFloat)value;

-(NSObject *)getObjectFromObject:(id)object name:(NSString *)name;
-(void)setObjectToObject:(id)object name:(NSString *)name value:(NSObject *)value;

-(CGSize)getSizeFromObject:(id)object name:(NSString *)name;
-(void)setSizeToObject:(id)object name:(NSString *)name value:(CGSize)newValue;
@end

NS_ASSUME_NONNULL_END
