//
//  Transitionnimation.h
//  动画
//
//  Created by 杭州移领 on 16/6/27.
//  Copyright © 2016年 DFL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface Transitionnimation : UIPercentDrivenInteractiveTransition
<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>
@property (nonatomic , assign , getter=isDragable) BOOL isDragable;
- (instancetype)initWithModalViewController:(UINavigationController *)modalViewController;
@end
