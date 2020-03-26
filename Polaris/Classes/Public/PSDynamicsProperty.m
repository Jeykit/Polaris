//
//  PSDynamicsProperty.m
//  Polaris_Example
//
//  Created by Jekity on 2019/7/18.
//  Copyright © 2019 392071745@qq.com. All rights reserved.
//

#import "PSDynamicsProperty.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation PSDynamicsProperty
-(Ivar)getInstanceVariable:(id)object variableName:(NSString *)name{
    const char *variableName = [self realVaribleName:name];
    Ivar ivar = class_getInstanceVariable([object class], variableName);
    return ivar;
}

-(const char *)realVaribleName:(NSString *)name{
    return [[NSString stringWithFormat:@"_%@",name] UTF8String];
}

-(const char *)variableName:(NSString *)name{
    
    return [name UTF8String];
}

-(NSString *)assemblySetterName:(NSString *)name{
    
    NSString *first = [name substringToIndex:1];
    NSString *temp  = [name substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",[first capitalizedString],temp];
}

static const char *propertyName;
- (BOOL)addDynamicPropertyToObject:(id)object
                      propertyName:(NSString *)name
                              type:(PSDynamicPropertyType)type
{
    BOOL success = NO;
    if (type == PSDynamicPropertyTypeAssign) {
        success = [self addAssignProperty:object propertyName:name];
    }else if (type == PSDynamicPropertyTypeRetain){
        success = [self addRetainProperty:object propertyName:name];
    }
    return success;
}
-(BOOL)addAssignProperty:(id)object propertyName:(NSString *)name{
    
    objc_property_attribute_t type1 = { "T", "d" };
    objc_property_attribute_t ownership = { "&", "" }; // & = retain||assign
    
    const char *realVariableName = [self realVaribleName:name];
    const char *variableName     = [self variableName:name];
    
    propertyName = realVariableName;
    
    objc_property_attribute_t backingivar  = { "V", realVariableName};
    objc_property_attribute_t attrs[] = {type1,ownership, backingivar};
    
    BOOL success = class_addProperty([object class], variableName, attrs, 3);
    if (success) {
        NSString *setterName = [self assemblySetterName:name];
        class_addMethod([object class], NSSelectorFromString(name), (IMP)assignGetterPS, "d@:");
        class_addMethod([object class], NSSelectorFromString(setterName), (IMP)assignSetterPS, "v@:d");
        return success;
    }
    return success;
}

-(BOOL)addRetainProperty:(id)object propertyName:(NSString *)name{
    
    objc_property_attribute_t type1 = { "T", "@" };
    objc_property_attribute_t ownership = { "&", "" }; // & = retain||assign
    
    const char *realVariableName = [self realVaribleName:name];
    const char *variableName     = [self variableName:name];
    
    propertyName = realVariableName;
    
    objc_property_attribute_t backingivar  = { "V", realVariableName};
    objc_property_attribute_t attrs[] = {type1,ownership, backingivar};
    
    BOOL success = class_addProperty([object class], variableName, attrs, 3);
    if (success) {
        NSString *setterName = [self assemblySetterName:name];
        class_addMethod([object class], NSSelectorFromString(name), (IMP)retainGetterPS, "@@:");
        class_addMethod([object class], NSSelectorFromString(setterName), (IMP)retainSetterPS, "v@:@");
        return success;
    }
    return success;
}

#pragma mark -retain
NSObject *retainGetterPS(id self, SEL _cmd) {
    return objc_getAssociatedObject(self,propertyName);
    //      Ivar ivar = class_getInstanceVariable([self1 class], "_cellHeight");//This is not working
    //     return [object_getIvar(self1, ivar) floatValue];
}

void retainSetterPS(id self, SEL _cmd, NSObject *newValue) {
    //    Ivar ivar = class_getInstanceVariable([self1 class], "_cellHeight");//This is not working
    //
    //    object_setIvar(self1, ivar, @(newName));
    objc_setAssociatedObject(self, propertyName,newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
#pragma mark - assign
CGFloat assignGetterPS(id self, SEL _cmd) {
    return [objc_getAssociatedObject(self,propertyName) floatValue];
    //      Ivar ivar = class_getInstanceVariable([self1 class], "_cellHeight");//This is not working
    //     return [object_getIvar(self1, ivar) floatValue];
}

void assignSetterPS(id self, SEL _cmd, CGFloat newValue) {
    //    Ivar ivar = class_getInstanceVariable([self1 class], "_cellHeight");//This is not working
    //
    //    object_setIvar(self1, ivar, @(newName));
    CGFloat value = [objc_getAssociatedObject(self,propertyName) floatValue];
    if (value != newValue) {
        objc_setAssociatedObject(self, propertyName,@(newValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (CGFloat)getFloatValueFromObject:(id)object
                              name:(NSString *)name
{
    propertyName = [self variableName:name];
    CGFloat (*action)(id, SEL) = (CGFloat (*)(id, SEL)) objc_msgSend;
    CGFloat value = action(object,NSSelectorFromString(name));
    return value;
}
- (void)setFloatValueToObject:(id)object
                         name:(NSString *)name
                        value:(CGFloat)value
{
    propertyName = [self variableName:name];
    NSString *setterName = [self assemblySetterName:name];
    ((void(*)(id,SEL,CGFloat))objc_msgSend)(object, NSSelectorFromString(setterName),value);
}
-(void)setObjectToObject:(id)object name:(NSString *)name value:(NSObject *)value{
    propertyName = [self variableName:name];
    NSString *setterName = [self assemblySetterName:name];
    ((void(*)(id,SEL,NSObject *))objc_msgSend)(object, NSSelectorFromString(setterName),value);
}

-(NSObject *)getObjectFromObject:(id)object name:(NSString *)name{
    propertyName = [self variableName:name];
    NSObject* (*action)(id, SEL) = (NSObject *(*)(id, SEL)) objc_msgSend;
    NSObject* num = action(object,NSSelectorFromString(name));
    return num;
}
-(void)setSizeToObject:(id)object name:(NSString *)name value:(CGSize)newValue{
    CGSize oldSize = [self getSizeFromObject:object name:name];
    if (!CGSizeEqualToSize(oldSize, newValue)) {
        propertyName = [self variableName:name];
        NSString *setterName = [self assemblySetterName:name];
        NSValue *num = [NSValue valueWithCGSize:newValue];
        ((void(*)(id,SEL,NSObject *))objc_msgSend)(object, NSSelectorFromString(setterName),num);
    }
    
}
-(CGSize)getSizeFromObject:(id)object name:(NSString *)name{
    propertyName = [self variableName:name];
    NSObject* (*action)(id, SEL) = (NSObject *(*)(id, SEL)) objc_msgSend;
    NSObject* num = action(object,NSSelectorFromString(name));
    NSValue *newValue = (NSValue *)num;
    CGSize size = [newValue CGSizeValue];
    return size;
    
}
@end
