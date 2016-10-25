//
//  Transitionnimation.m
//  动画
//
//  Created by 杭州移领 on 16/6/27.
//  Copyright © 2016年 DFL. All rights reserved.
//

#import "Transitionnimation.h"
@interface Transitionnimation()
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UINavigationController *modalController;
@property (nonatomic , strong) UIScreenEdgePanGestureRecognizer *gesture;
@property CGFloat panLocationStart;

@property BOOL isDismiss;

@property BOOL isInteractive;

@property CATransform3D tempTransform;

@end

@implementation Transitionnimation
@synthesize isDragable = _isDragable;
- (instancetype)initWithModalViewController:(UINavigationController *)modalViewController
{
    self = [super init];
    if (self) {
        _modalController = modalViewController;
        
        _modalController.modalPresentationStyle = UIModalPresentationFullScreen;
        _modalController.transitioningDelegate = self;
        
    }
    return self;
}

- (void)setIsDragable:(BOOL)isDragable {
    
    _isDragable = isDragable;
    if (_isDragable) {
        self.gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//        self.gesture.delegate =self;
        self.gesture.edges = UIRectEdgeLeft;
        [self.modalController.viewControllers[0].view addGestureRecognizer:self.gesture];
    }
}



- (void)handleSwipe:(UIScreenEdgePanGestureRecognizer *)recognizer {
    
    
    CGPoint location = [recognizer locationInView:self.modalController.viewControllers[0].view.window];
    location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view.transform));
    // Velocity reference
    CGPoint velocity = [recognizer velocityInView:[self.modalController.viewControllers[0].view window]];
    velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view.transform));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isInteractive = YES;
         self.panLocationStart = location.x;
        [self.modalController dismissViewControllerAnimated:YES completion:nil];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat animationRatio = 0;
        animationRatio = (location.x - self.panLocationStart) / (CGRectGetWidth([self.modalController view].bounds));
        [self updateInteractiveTransition:animationRatio];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat velocityForSelectedDirection = velocity.x;
        if (velocityForSelectedDirection > 100) {
                [self finishInteractiveTransition];
        } else {
                [self cancelInteractiveTransition];
            }
        self.isInteractive = NO;

    }
 

}
- (void)animationEnded:(BOOL)transitionCompleted {
    self.isInteractive = NO;
    self.transitionContext = nil;
}

//  动画时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.5;
}

// 不管将要present还是将要dissmiss都会走这个方法
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isInteractive) {
        return;
    }
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    if (!self.isDismiss) {
//        present
        [containerView addSubview:toViewController.view];
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        CGRect startFrame = CGRectMake(CGRectGetWidth(containerView.frame), 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame));
        toViewController.view.frame = startFrame;
        if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [fromViewController beginAppearanceTransition:NO animated:YES];
        }
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toViewController.view.frame = CGRectMake(0,0,
                                                                      CGRectGetWidth(toViewController.view.frame),
                                                                      CGRectGetHeight(toViewController.view.frame));
                         } completion:^(BOOL finished) {
                             if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
                                 [fromViewController endAppearanceTransition];
                             }
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];

    } else {
//        diss
        if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
            [containerView addSubview:toViewController.view];
        }
        
        [containerView bringSubviewToFront:fromViewController.view];
        
        CGRect  endRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds),
                                              0,
                                              CGRectGetWidth(fromViewController.view.frame),
                                              CGRectGetHeight(fromViewController.view.frame));
        if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [toViewController beginAppearanceTransition:YES animated:YES];
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             fromViewController.view.frame = endRect;
                             
                         } completion:^(BOOL finished) {
                             
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                                 [toViewController endAppearanceTransition];
                             }
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];

    }
}


//  将要开始dissmiss
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
     self.tempTransform = toViewController.view.layer.transform;
    if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
        [[transitionContext containerView] addSubview:toViewController.view];
    }
    [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
    
}

// 开始dissmiss
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    
    if ( percentComplete < 0) {
        percentComplete = 0;
    }
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect updateRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds) * percentComplete,
                                   0,
                                   CGRectGetWidth(fromViewController.view.frame),
                                   CGRectGetHeight(fromViewController.view.frame));
    fromViewController.view.frame = updateRect;

}

//  完成dissmiss过程
- (void)finishInteractiveTransition {
    
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect  endRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds),
                         0,
                         CGRectGetWidth(fromViewController.view.frame),
                         CGRectGetHeight(fromViewController.view.frame));
    if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
        [toViewController beginAppearanceTransition:YES animated:YES];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                         fromViewController.view.frame = endRect;
                     } completion:^(BOOL finished) {
                         if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                             [toViewController endAppearanceTransition];
                         }
                         [transitionContext completeTransition:YES];
                     }];

}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    [transitionContext cancelInteractiveTransition];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                         fromViewController.view.frame = CGRectMake(0,0,
                                                                    CGRectGetWidth(fromViewController.view.frame),
                                                                    CGRectGetHeight(fromViewController.view.frame));
                     } completion:^(BOOL finished) {
                         
                         [transitionContext completeTransition:NO];
                         
                         if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
                             [toViewController.view removeFromSuperview];
                         }
                     }];
}


#pragma mark - UIViewControllerTransitioningDelegate Methods


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismiss = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismiss = YES;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{

    if (self.isInteractive && self.isDragable) {
        self.isDismiss = YES;
        return self;
    }
    return nil;

}


- (BOOL)isPriorToIOS8
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
    
}


////解决全局返回的手势和表滑动删除的手势之间的冲突
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        
//        if (self.modalController.viewControllers[0].view && [[self.modalController.viewControllers[0].view gestureRecognizers] containsObject:gestureRecognizer]) {
//            CGPoint tPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
//            if (tPoint.x >= 0) {
//                CGFloat y = fabs(tPoint.y);
//                CGFloat x = fabs(tPoint.x);
//                CGFloat af = 30.0f/180.0f * M_PI;
//                
//                CGFloat tf = tanf(af);
//                if ((y/x) <= tf) {
//                    return YES;
//                }
//                return NO;
//            }else{
//                return NO;
//            }
//        }
//        
//    }
//    
//    return YES;
//}


@end

