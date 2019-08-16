//
//  UIApplication+PSSignal.m
//  Expecta
//
//  Created by Jekity on 2019/8/2.
//

#import "UIApplication+SignalM.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIApplication (SignalM)
+(void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL safeSelector = @selector(sendEvent:);
        SEL unsafeSelector = @selector(PSSignal_sendEvent:);
        Class myClass = [self class];
        Method safeMethod = class_getInstanceMethod (myClass, safeSelector);
        Method unsafeMethod = class_getInstanceMethod (myClass, unsafeSelector);
        method_exchangeImplementations(unsafeMethod, safeMethod);
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)PSSignal_sendEvent:(UIEvent *)event
{
    NSSet *set = event.allTouches;
    NSArray *array = [set allObjects];
    UITouch *touchEvent = [array lastObject];
    UIView *view = [touchEvent view];
    if ([NSStringFromClass([view.superview class]) containsString:@"UISwitch"]) {//如果是UISwitch的子类
        if (!(view.superview.superview.userInteractionEnabled == NO || view.superview.superview.hidden == YES || view.superview.superview.alpha <= 0.01)){
            void(*action)(id,SEL,id,id) = (void(*)(id,SEL,id,id))objc_msgSend;
            action(view.superview.superview,@selector(PSTouchesEnded: withEvent:),set,event);
        }
    }
    if (touchEvent.phase == UITouchPhaseEnded) {
        CGPoint point = [touchEvent locationInView:view];
        UIView *fitview = [self hitTest:point withEvent:event withView:view];
        
        if(fitview)
        {
            void(*action)(id,SEL,id,id) = (void(*)(id,SEL,id,id))objc_msgSend;
            if ([NSStringFromClass([fitview class]) isEqualToString:@"_UITableViewHeaderFooterContentView"]) {//处理UITableViewHeaderFooterView事件
                action(fitview.superview,@selector(PSTouchesEnded: withEvent:),set,event);
            }else{
                action(fitview,@selector(PSTouchesEnded: withEvent:),set,event);
            }
        }
    }
    [self PSSignal_sendEvent:event];
    
    
}
#pragma clang diagnostic pop
// 因为所有的视图类都是继承BaseView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event withView:(UIView *)view{
    // 1.判断当前控件能否接收事件
    if (view.userInteractionEnabled == NO || view.hidden == YES || view.alpha <= 0.01) return nil;
    // 2. 判断点在不在当前控件
    if ([view pointInside:point withEvent:event] == NO) return nil;
    
    //3. 如果是UIStepper直接返回
    if ([view isKindOfClass:[UIStepper class]]) {
        return view;
    }
    // 4.从后往前遍历自己的子控件
    NSInteger count = view.subviews.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = view.subviews[i];
        // 把当前控件上的坐标系转换成子控件上的坐标系
        CGPoint childP = [view convertPoint:point toView:childView];
        UIView *fitView = [childView hitTest:childP withEvent:event];
        if (fitView && !(fitView.userInteractionEnabled == NO || fitView.hidden == YES || fitView.alpha <= 0.01)) { // 寻找到最合适的view
            return fitView;
        }
    }
    // 循环结束,表示没有比自己更合适的view
    return view;
    
}

@end
