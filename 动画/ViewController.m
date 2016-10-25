//
//  ViewController.m
//  动画
//
//  Created by 杭州移领 on 16/6/27.
//  Copyright © 2016年 DFL. All rights reserved.
//

#import "ViewController.h"
#import "Transitionnimation.h"
#import "ModalViewController.h"
@interface ViewController ()
@property (nonatomic , strong) Transitionnimation *animator;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    UIButton *button = ({
        button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(present:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });

}
- (void)present:(UIButton *)button {
   
    ModalViewController *modalVC = [[ModalViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:modalVC];
    self.animator = [[Transitionnimation alloc] initWithModalViewController:nav];
    self.animator.isDragable = YES;
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
