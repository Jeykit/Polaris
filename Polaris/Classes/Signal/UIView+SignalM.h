//
//  UIView+SignalM.h
//  Expecta
//
//  Created by Jekity on 2019/8/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SignalM)
/**
 viewController UIView所在的控制器
 */
@property(nonatomic ,weak ,readonly)UIViewController* viewController;


/**
 clickSignalName 信号名，如果不设置则会自动赋值为控件的属性名,也可在xib界面找到这个属性直接设置信号名
 */
@property (nonatomic,copy)IBInspectable NSString *clickSignalName;


/**
 如果控件是‘UIControl’的子类，则可以通过这个改变信号的触发事件，UIButton默认为UIControlTouchUpInside，UITxtField默认为UIControlEventEditingChanged，其余默认为UIControlEventValueChanged
 */
@property(nonatomic,assign) UIControlEvents allControlEvents;


/**
 如果控件是‘UITableViewCell’或者‘UIColectionViewCell’，则可以在信号事件中获取它所在‘NSIndexPath’'
 */
@property (nonatomic,readonly)NSIndexPath *indexPath;


/**
 通过链式编程方式设置信号名
 */
@property (nonatomic,assign)UIView *(^signalName)(NSString * signalName);


/**
 指定信号的响应对象，默认顺序为控件属性所在UIView->UITableViewCell||UIColectionViewCell->UIController
 */
@property (nonatomic,assign)UIView *(^enforceTarget)(NSObject *target);


/**
 通过链式编程方式设置控件信号的触发事件
 */
@property (nonatomic,assign)UIView *(^controlEvents)(UIControlEvents event);


@end
/**
 可以通过下面方法手动发送signal
 */
@interface NSObject (SignalM)

/**
 @param signalName 信号名
 @param target     信号执行对象
 @param object     参数
 */
-(void)sendSignal:(NSString *)signalName target:(NSObject *)target object:(id __nullable)object;


/**
 @param signalName 信号名
 @param target     信号执行对象
 */
-(void)sendSignal:(NSString *)signalName target:(NSObject *)target;

@end
NS_ASSUME_NONNULL_END
