//
//  PSNavigationController.m
//  Expecta
//
//  Created by Jekity on 2019/8/15.
//

#import "PSNavigationController.h"
#import <objc/runtime.h>


@interface PSNavigationController ()<UIGestureRecognizerDelegate>
{
    CGPoint startTouch;
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    UIPanGestureRecognizer* pan;
}
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) NSMutableArray *screenShotsList;
@property (nonatomic,assign) BOOL isMoving;
@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) BOOL isFromBackButton;
@end

@implementation PSNavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:rootViewController]) {
        _isFromBackButton = YES;
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.duration = .25;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
}
- (void)viewDidLayoutSubviews{
    pan.enabled = self.interactivePopGestureRecognizer.isEnabled;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self capture]];
    [self configBackgroundView];
    
    //设置view的frame的x轴坐标为320
    CGRect frameBeforePush = self.view.frame;
    frameBeforePush.origin.x = [UIScreen mainScreen].bounds.size.width;
    self.view.frame = frameBeforePush;
    
    CGRect frameAfterPush = frameBeforePush;
    frameAfterPush.origin.x = 0;
    [UIView animateWithDuration:self.duration animations:^{
        self.view.frame = frameAfterPush;
    }completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }];
    if (self.viewControllers.count == 1) {
        [self.view addGestureRecognizer:pan];
    }
    [super pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (_isFromBackButton) {
        [self configBackgroundView];
        
        __block CGRect frame = self.view.frame;
        frame.origin.x = 320;
        blackMask.alpha = 0.4;
        [UIView animateWithDuration:0.175 animations:^{
            self.view.frame = frame;
        }completion:^(BOOL finished) {
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            self.view.frame = frame;
            
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
            [self cleanLastData];
            [super popViewControllerAnimated:NO];
        }];
    }else{
        _isFromBackButton = YES;
        return [super popViewControllerAnimated:NO];
    }
    return nil;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (_isFromBackButton) {
        [self configBackgroundViewWithIndex:index];
        
        __block CGRect frame = self.view.frame;
        frame.origin.x = 320;
        blackMask.alpha = 0.4;
        [UIView animateWithDuration:0.175 animations:^{
            self.view.frame = frame;
        }completion:^(BOOL finished) {
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            self.view.frame = frame;
            
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
            [self cleanLastDataWithIndex:index];
            [super popToViewController:viewController animated:NO];
        }];
    }else{
        _isFromBackButton = YES;
        return  [super popToViewController:viewController animated:NO];
    }
    return nil;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSInteger index = 0;
    if (_isFromBackButton) {
        [self configBackgroundViewWithIndex:index];
        
        __block CGRect frame = self.view.frame;
        frame.origin.x = 320;
        blackMask.alpha = 0.4;
        [UIView animateWithDuration:0.175 animations:^{
            self.view.frame = frame;
        }completion:^(BOOL finished) {
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            self.view.frame = frame;
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
            [self.screenShotsList removeAllObjects];
            [self removePan];
            [super popToRootViewControllerAnimated:NO];
        }];
    }else{
        _isFromBackButton = YES;
        return  [super popToRootViewControllerAnimated:NO];
    }
    return nil;
}

-(void)cleanLastData
{
    [self.screenShotsList removeLastObject];
    if (self.viewControllers.count == 2) {
        [self removePan];
    }
}
-(void)cleanLastDataWithIndex:(NSUInteger)index
{
    for (NSUInteger i = index; i < self.screenShotsList.count; i ++) {
        [self.screenShotsList removeObjectAtIndex:i];
    }
    if (self.viewControllers.count == 2) {
        [self removePan];
    }
}
-(void)addPan
{
    [self.view addGestureRecognizer:pan];
}
-(void)removePan
{
    for (UIGestureRecognizer* g in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:g];
    }
}

#pragma mark - Utility Methods
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    img = [UIImage imageWithData:UIImageJPEGRepresentation(img, 0.9)];
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)moveViewWithX:(CGFloat)x
{
    CGFloat alpha = 0.4 - (x/800);
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    blackMask.alpha = alpha;
}

- (void)configBackgroundView
{
    CGRect frame = self.view.frame;
    self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
    [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
    //blackMask可以设定alpha,滑动时效果
    UIImage *lastScreenShot = [self.screenShotsList lastObject];
    lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
    lastScreenShotView.frame = self.view.bounds;
    lastScreenShotView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backgroundView addSubview:lastScreenShotView];
}
- (void)configBackgroundViewWithIndex:(NSUInteger)index
{
    CGRect frame = self.view.frame;
    self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
    [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
    //blackMask可以设定alpha,滑动时效果
    UIImage *lastScreenShot = self.screenShotsList[index];
    lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
    lastScreenShotView.frame = self.view.bounds;
    lastScreenShotView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backgroundView addSubview:lastScreenShotView];
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (self.viewControllers.count <= 1) return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = NO;
        startTouch = [recognizer translationInView:self.view];
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint moveTouch = [recognizer translationInView:self.view];
        if (!_isMoving) {
            if(moveTouch.x - startTouch.x > 10)
            {
                _isMoving = YES;
                
                if (self.backgroundView == nil)
                {
                    CGRect frame = self.view.frame;
                    self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
                    
                    [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
                    //blackMask可以设定alpha,滑动时效果
                    blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
                    blackMask.backgroundColor = [UIColor blackColor];
                    [self.backgroundView addSubview:blackMask];
                }
                
                if (lastScreenShotView != nil)
                {
                    [lastScreenShotView removeFromSuperview];
                    lastScreenShotView = nil;
                }
                
                UIImage *lastScreenShot = [self.screenShotsList lastObject];
                lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
                lastScreenShotView.frame = self.view.bounds;
                lastScreenShotView.contentMode = UIViewContentModeScaleAspectFit;
                [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
                
            }
        } else if (_isMoving) {
            [self moveViewWithX:moveTouch.x - startTouch.x];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        
        CGPoint endTouch = [recognizer translationInView:self.view];
        
        if (endTouch.x - startTouch.x > 100)
        {
            [UIView animateWithDuration:self.duration animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                self.isFromBackButton = NO;
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                self.isMoving = NO;
                [self.backgroundView removeFromSuperview];
                self.backgroundView = nil;
            }];
        }
        else
        {
            [UIView animateWithDuration:self.duration animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                self.isMoving = NO;
                [self.backgroundView removeFromSuperview];
                self.backgroundView = nil;
            }];
            
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed)
    {
        [UIView animateWithDuration:self.duration animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            self.isMoving = NO;
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
        }];
    }
}

@end
