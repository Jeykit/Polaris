//
//  PolarisViewController.m
//  Polaris
//
//  Created by 392071745@qq.com on 07/09/2019.
//  Copyright (c) 2019 392071745@qq.com. All rights reserved.
//

#import "PolarisViewController.h"
#import "PolarisViewNewController.h"

@interface PolarisViewController ()

@end

@implementation PolarisViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"你好";
    self.view.clickSignalName = @"tpa";
	// Do any additional setup after loading the view, typically from a nib.
//    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view configureLayoutWithBlock:^(LayoutManager * _Nonnull layoutM) {
//        layoutM.isEnabled = YES;
//        layoutM.width = [UIScreen mainScreen].bounds.size.width;
//        layoutM.height = [UIScreen mainScreen].bounds.size.height -  83.;
//        layoutM.paddingLeft = 12.;
//        layoutM.paddingRight = 12.;
//    }];
//    UIView *view1 = [self bulidView];
//    [self.view addSubview:view1];
//    view1.backgroundColor = [UIColor redColor];
//
//    UIView *view2 = [self bulidView];
//    [view1 addSubview:view2];
//    view2.backgroundColor = [UIColor blueColor];
//    UIView *view3 = [self bulidWrapView];
//    [self.view addSubview:view3];
//    view3.backgroundColor = [UIColor redColor];
    
//    UIView *view4 = [self bulidWrapView];
//    [view3 addSubview:view4];
//    view4.layoutM.marginTop = 0;
//    view4.backgroundColor = [UIColor blueColor];
    
//    [self.view.layoutM applyLayoutPreservingOrigin:YES];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.setSignalName(@"moreButton").enforceTarget(self);
//    button.titleStringPS = @"更多看房团";
//    button.backgroundColor =  [UIColor colorWithHexString:@"#F8F8F9"];
//    button.titleColorPS = [UIColor colorWithHexString:@"#5680A6"];
//    [self addSubview:button];
//    [button configureLayoutWithBlock:^(PSLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.height = 44.;
//        layout.marginBottom = 12.;
//        layout.width = kScreenWidth - 24.;
//    }];
}
Click_SignalM(tpa){
    [self.navigationController pushViewController:[PolarisViewNewController new] animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView *)bulidWrapView
{
    UIView *titleView = [[UIView alloc]init];
    titleView.backgroundColor = [UIColor redColor];
    [titleView configureLayoutWithBlock:^(LayoutManager * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = -1;
        layout.width = 300;
//        layout.flexCount = 1;
        layout.justifyContent = PSFlexJustifyEndAround;
        layout.align_items = PSFlexAlignCenter;
//        layout.width = [UIScreen mainScreen].bounds.size.width;
        layout.margin = 5.;
        layout.marginTop = 100;
        layout.flexDirection = PSFlexDirectionColumn;
//        layout.flexWrap = PSFlexWrapWrap;
    }];
    for (NSUInteger i = 0; i<4; i++) {
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.];
        titleLabel.text = @"看房团";
        [titleView addSubview:titleLabel];
        [titleLabel configureLayoutWithBlock:^(LayoutManager * _Nonnull layout) {
            layout.isEnabled = YES;
            layout.marginRight = 10;
            layout.marginLeft = 10;
//            layout.flexShrik = 1;
            
        }];
    }
    return titleView;
}
- (UIView *)bulidView
{
    UIView *titleView = [[UIView alloc]init];
    titleView.backgroundColor = [UIColor redColor];
    [titleView configureLayoutWithBlock:^(LayoutManager * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = -1;
//        layout.width = -1;
                layout.width = [UIScreen mainScreen].bounds.size.width;
        layout.margin = 5.;
        layout.marginTop = 100;
        layout.flexDirection = PSFlexDirectionColumn;
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.];
    titleLabel.text = @"看房团";
    [titleView addSubview:titleLabel];
    [titleLabel configureLayoutWithBlock:^(LayoutManager * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginRight = 10;
        layout.marginLeft = 10;
        
    }];
    
    UILabel *detailLabel = [[UILabel alloc]init];
    detailLabel.font = [UIFont boldSystemFontOfSize:12.];
    detailLabel.textColor = [UIColor lightGrayColor];
    detailLabel.text = @"专车免费接送";
    [titleView addSubview:detailLabel];
    [detailLabel configureLayoutWithBlock:^(LayoutManager * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginRight = 10;
//        layout.flexGrow = 1;
        
    }];
    return titleView;
}
@end