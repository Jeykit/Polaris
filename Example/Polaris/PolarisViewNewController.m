//
//  PolarisViewNewController.m
//  Polaris_Example
//
//  Created by Jekity on 2019/8/15.
//  Copyright © 2019 392071745@qq.com. All rights reserved.
//

#import "PolarisViewNewController.h"

@interface PolarisViewNewController ()

@end

@implementation PolarisViewNewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationBarBackgroundColorM = [UIColor purpleColor];
//    self.navigationBarHiddenM = YES;
    // Do any additional setup after loading the view.
     self.view.clickSignalName = @"tpa";
    self.title = @"one more thing";
    self.interactivePopGestureRecognizer = NO;
}
Click_SignalM(tpa){
//    [self.navigationController popToViewController:self.navigationController.viewControllers.firstObject animated:YES];
    [self.navigationController pushViewController:[PolarisViewNewController new] animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
