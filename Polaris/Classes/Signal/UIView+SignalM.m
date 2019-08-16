//
//  UIView+SignalM.m
//  Expecta
//
//  Created by Jekity on 2019/8/2.
//

#import "UIView+SignalM.h"
#import <objc/message.h>

@interface SignalManager : NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) NSObject *targetObject;
@property (nonatomic, copy)NSString *repeatedSignalName;
@property (nonatomic, assign, getter=isAchieve) BOOL achieve;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, copy) NSString *clickSignalName;
@property (nonatomic, assign) UIControlEvents allEventControls;
@end
@implementation SignalManager
@end
@interface UIView ()
@property (nonatomic,strong) SignalManager *signalM;
@end

static NSString const * havedSignal = @"SignalM_";

@implementation UIView (SignalM)
- (SignalManager *)signalM{
    SignalManager *signalM = objc_getAssociatedObject(self, @selector(signalM));
    if (signalM == nil) {
        signalM = [[SignalManager alloc] init];
        objc_setAssociatedObject(self, @selector(signalM), signalM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return signalM;
}
-(void)setAllControlEvents:(UIControlEvents)allControlEvents{
    if ([self isKindOfClass:[UIControl class]]) {
        UIControl *control = (UIControl *)self;
        if (self.signalM.isAchieve) {
            if (allControlEvents != self.signalM.allEventControls) {
                [control removeTarget:self action:@selector(didEvent:) forControlEvents:self.signalM.allEventControls];
                self.signalM.allEventControls = allControlEvents;
                [control addTarget:self action:@selector(didEvent:) forControlEvents:allControlEvents];
            }
        }else{
            self.signalM.achieve = YES;
            [control addTarget:self action:@selector(didEvent:) forControlEvents:allControlEvents];
        }
    }
    objc_setAssociatedObject(self, @selector(allControlEvents), @(allControlEvents), OBJC_ASSOCIATION_ASSIGN);
}
-(UIControlEvents)allControlEvents{
    return self.signalM.allEventControls;
}

-(void)setClickSignalName:(NSString *)clickSignalName{
    self.signalM.clickSignalName = clickSignalName;
    self.userInteractionEnabled = YES;
    if ([self isKindOfClass:[UIControl class]]) {
        if (!self.signalM.isAchieve) {
            UIControl *control = (UIControl *)self;
            self.signalM.achieve = YES;
            self.signalM.allEventControls = [self eventControlWithInstance:self];
            [control addTarget:self action:@selector(didEvent:) forControlEvents:self.signalM.allEventControls];
        }
    }
}
- (NSString *)clickSignalName{
    return self.signalM.clickSignalName;
}
-(UIViewController *)viewController{
    if (self.signalM.viewController == nil) {
        [self getViewControllerFromCurrentView];
    }
    return self.signalM.viewController;
}
- (NSIndexPath *)indexPath{
    return self.signalM.indexPath;
}
#pragma mark -signal name
- (UIView * _Nonnull (^)(NSString * _Nonnull))signalName{
    __weak typeof(self)weakSelf = self;
    return ^(NSString *signalName){
        weakSelf.clickSignalName = signalName;
        return weakSelf;
    };
}
- (void)setSignalName:(UIView * _Nonnull (^)(NSString * _Nonnull))signalName
{
    objc_setAssociatedObject(self, @selector(signalName), signalName, OBJC_ASSOCIATION_ASSIGN);
}
#pragma mark enforce -target
-(UIView *(^)(NSObject *))enforceTarget{
    
    __weak typeof(self)weakSelf = self;
    return ^(NSObject * target){
        __weak typeof(target)weakTarget = target;
        weakSelf.signalM.targetObject = weakTarget;
        return weakSelf;
    };
}

-(void)setEnforceTarget:(UIView *(^)(NSObject *))enforceTarget{
    objc_setAssociatedObject(self, @selector(enforceTarget), enforceTarget, OBJC_ASSOCIATION_ASSIGN);
}
#pragma mark -events
-(void)setControlEvents:(UIView *(^)(UIControlEvents))controlEvents{
    objc_setAssociatedObject(self, @selector(controlEvents), controlEvents, OBJC_ASSOCIATION_ASSIGN);
}
-(UIView *(^)(UIControlEvents))controlEvents{
    __weak typeof(self)weakSelf = self;
    return ^(UIControlEvents  event){
        weakSelf.signalM.allEventControls = event;
        return weakSelf;
    };
    
}
#pragma clang diagnostic pop
-(void)didEvent:(UIControl *)control{
    if (self.clickSignalName == nil) {
        self.clickSignalName = [self dymaicSignalName];
    }
    if (self.clickSignalName.length > 0) {
        [self sendSignal];
    }
}
#pragma mark- touch events handler
- (void)PSTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.clickSignalName.length <= 0) {
        self.clickSignalName = [self dymaicSignalName];
    }
    if (self.clickSignalName.length > 0) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        BOOL trigger = [self pointInside:point withEvent:event];
        if (trigger && ![self isKindOfClass:[UIControl class]]) {
            [self sendSignal];
        }
    }
}
-(NSString *)nameWithInstance:(id)instance responder:(UIResponder *)responder{
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar * ivars = class_copyIvarList([responder class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"] || ![object_getIvar(responder, thisIvar) isKindOfClass:[UIView class]]) {
            continue;
        }
        if (object_getIvar(responder, thisIvar) == instance) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }else{
            key = @"";
        }
    }
    free(ivars);
    return key;
    
}
-(NSString *)dymaicSignalName{
    NSString *name = @"";
    if ([self isKindOfClass:[UITableViewCell class]] || [self isKindOfClass:[UICollectionViewCell class]]||[self isKindOfClass:NSClassFromString(@"UITableViewWrapperView")]||[NSStringFromClass([self class]) isEqualToString:@"UITableViewCellContentView"]||[NSStringFromClass([self class]) isEqualToString:@"UICollectionViewCellContentView"]) {
        return name;
    }
    UIResponder *nextResponder = self.nextResponder;
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            self.signalM.viewController = nil;
            break;
        }
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            
            self.signalM.viewController = (UIViewController*)nextResponder;
            name = [self nameWithInstance:self responder:nextResponder];
            if (name.length > 0) {
                name = [name substringFromIndex:1];//防止命名有_的属性名被过滤掉
                return name;
            }
            break;
        }
        if([nextResponder isKindOfClass:NSClassFromString(@"UIKeyboardCandidateBarCell")] || [self isKindOfClass:NSClassFromString(@"PUPhotosGridCell")]){//清除键盘上的信号设置
            return name;
        }
        name = [self nameWithInstance:self responder:nextResponder];
        if (name.length > 0) {
            name = [name substringFromIndex:1];//防止命名有_的属性名被过滤掉
            NSString *selectorString = [havedSignal stringByAppendingString:name];
            selectorString = [NSString stringWithFormat:@"%@:",selectorString];
            if ([nextResponder respondsToSelector:NSSelectorFromString(selectorString)]) {
                self.enforceTarget(nextResponder);
            }
            return name;
        }
        nextResponder = nextResponder.nextResponder;
    }
    return name;
}
#pragma -mark indexPath
-(NSIndexPath *)indexPathForCellWithId:(id)subViews{
    
    NSIndexPath *indexPath = nil;
    if ([subViews isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)subViews;
        if (@available(iOS 11.0, *)) {
            UITableView *tableView = (UITableView *)cell.superview;
            indexPath = [tableView indexPathForCell:cell];
            self.signalM.tableView = tableView;
        }else{
            UITableView *tableView = (UITableView *)cell.superview.superview;
            indexPath = [tableView indexPathForCell:cell];
            self.signalM.tableView = tableView;
        }
        
    }else{
        
        UICollectionViewCell *cell = (UICollectionViewCell *)subViews;
        UICollectionView *collectionView = (UICollectionView *)cell.superview;
        indexPath = [collectionView indexPathForCell:cell];
        self.signalM.collectionView = collectionView;
    }
    return indexPath;
}
static BOOL forceRefrshMU = NO;//强制刷新标志
-(void)sendSignal{
    
    if (self.signalM.repeatedSignalName.length <= 0) {
        self.signalM.clickSignalName = [havedSignal stringByAppendingString:self.signalM.clickSignalName];
        self.signalM.clickSignalName = [NSString stringWithFormat:@"%@:",self.signalM.clickSignalName];
        self.signalM.repeatedSignalName = self.signalM.clickSignalName;
    }
    
    if (self.signalM.repeatedSignalName.length <= 0) {
        return;
    }
    void(*action)(id,SEL,id) = (void(*)(id,SEL,id))objc_msgSend;
    //防止子控件获取控制器时失败
    if(forceRefrshMU){
        self.signalM.viewController = nil;
        forceRefrshMU = NO;//执行后复原
    }
    if (self.signalM.viewController == nil) {
        [self getViewControllerFromCurrentView];
    }
    SEL selctor = NSSelectorFromString(self.signalM.repeatedSignalName);
    if ([self.signalM.targetObject respondsToSelector:selctor]) {
        action(self.signalM.targetObject,selctor,self);
        return;
        
    }
    //指定在cell里执行
    if (self.signalM.tableView && self.signalM.indexPath) {
        
        UITableViewCell *cell = [self.signalM.tableView cellForRowAtIndexPath:self.signalM.indexPath];
        if (cell&&[cell respondsToSelector:selctor]) {
            action(cell,selctor,self);
            return;
        }
    }
    if (self.signalM.collectionView && self.signalM.indexPath) {
        UICollectionViewCell *cell = [self.signalM.collectionView cellForItemAtIndexPath:self.signalM.indexPath];
        if (cell&&[cell respondsToSelector:selctor]) {
            action(cell,selctor,self);
            return;
        }
    }
    if ([self.signalM.viewController respondsToSelector:selctor]) {
        action(self.signalM.viewController,selctor,self);
    }
    
}
-(void)getViewControllerFromCurrentView{
    UIResponder *nextResponder = self.nextResponder;
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            self.signalM.viewController = nil;
            break;
        }
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            self.signalM.viewController = (UIViewController*)nextResponder;
            break;
        }else if ([nextResponder isKindOfClass:[UITableViewCell class]] || [nextResponder isKindOfClass:[UICollectionViewCell class]]){
            self.signalM.indexPath = [self indexPathForCellWithId:nextResponder];
        }
        nextResponder = nextResponder.nextResponder;
    }
}
#pragma mark -configured allEventControls
-(UIControlEvents)eventControlWithInstance:(UIView *)instance{
    if (![instance isKindOfClass:[UIButton class]]) {
        if ([instance isKindOfClass:[UITextField class]]) {
            return UIControlEventEditingChanged;
        }else{
            return UIControlEventValueChanged;
        }
    }
    return UIControlEventTouchUpInside;
}

@end
@implementation NSObject (SignalM)
-(void)sendSignal:(NSString *)signalName target:(NSObject *)target object:(id)object{
    if (!signalName || !target) {
        NSLog(@"%@-%@ The method can not be perform if the signalName or target is nil.",NSStringFromClass([target class]),signalName);
        return;
    }
    signalName = [havedSignal stringByAppendingString:signalName];
    signalName = [NSString stringWithFormat:@"%@:",signalName];
    SEL selector = NSSelectorFromString(signalName);
    /**end*/
    if ([target respondsToSelector:selector]) {
        void(*action)(id,SEL,id) = (void(*)(id,SEL,id))objc_msgSend;
        action(target,selector,object);
    }else{
        NSLog(@"%@-%@ The method can not be perform if the signalName or target is nil.",NSStringFromClass([target class]),signalName);
    }
}
-(void)sendSignal:(NSString *)signalName target:(NSObject *)target{
    [self sendSignal:signalName target:target object:nil];
}
@end
@implementation UITableViewCell (SignalM)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL safeSelector = @selector(prepareForReuse);
        SEL unsafeSelector = @selector(ps_prepareForReuse_tableviewcell);
        Class myClass = [self class];
        Method safeMethod = class_getInstanceMethod (myClass, safeSelector);
        Method unsafeMethod = class_getInstanceMethod (myClass, unsafeSelector);
        method_exchangeImplementations(unsafeMethod, safeMethod);
    });
}
-(void)ps_prepareForReuse_tableviewcell{
    forceRefrshMU = YES;
    [self ps_prepareForReuse_tableviewcell];
}
@end

@implementation UICollectionViewCell (SignalM)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL safeSelector = @selector(prepareForReuse);
        SEL unsafeSelector = @selector(ps_prepareForReuse_collectionViewcell);
        Class myClass = [self class];
        Method safeMethod = class_getInstanceMethod (myClass, safeSelector);
        Method unsafeMethod = class_getInstanceMethod (myClass, unsafeSelector);
        method_exchangeImplementations(unsafeMethod, safeMethod);
    });
}
-(void)ps_prepareForReuse_collectionViewcell{
    forceRefrshMU = YES;
    [self ps_prepareForReuse_collectionViewcell];
}
@end
