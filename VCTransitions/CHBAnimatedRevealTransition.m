//
//  CHBModalRevealTransitionController.m
//  VCTransitions
//
//  Created by Ben Stovold on 30/11/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

#import "CHBAnimatedRevealTransition.h"
#import "UIImage+ImageEffects.h"

static CGFloat kScalePresented = 0.7f;

@implementation CHBAnimatedRevealTransition
@synthesize operation = _operation;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *transitionContainerView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *presentingView = (self.operation == CHBRevealOperationPresent) ? fromVC.view : toVC.view;
    UIView *presentedView = (self.operation == CHBRevealOperationPresent) ? toVC.view : fromVC.view;

    presentingView.frame = presentedView.frame = transitionContainerView.bounds;

    switch (self.operation) {
        case CHBRevealOperationPresent: {
            [transitionContainerView addSubview:presentedView];
            presentingView.layer.transform = CATransform3DIdentity;
            presentedView.alpha = 0.f;
            presentedView.transform = CGAffineTransformMakeScale(kScalePresented, kScalePresented);
        } break;
        case CHBRevealOperationDismiss: {
            [transitionContainerView addSubview:presentingView];
            presentingView.layer.transform = [self transformPresentingView:presentingView];
            presentedView.alpha = 1.f;
            presentedView.transform = CGAffineTransformIdentity;
        } break;
    }
    
    __weak CHBAnimatedRevealTransition *weakself = self;
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        switch (weakself.operation) {
            case CHBRevealOperationPresent: {
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    presentingView.layer.transform = [self transformPresentingView:presentingView];
                }];
                [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:^{
                    presentedView.transform = CGAffineTransformIdentity;
                    presentedView.alpha = 1.f;
                }];
            } break;
            case CHBRevealOperationDismiss: {
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    presentedView.transform = CGAffineTransformMakeScale(kScalePresented, kScalePresented);
                    presentedView.alpha = 0.f;
                }];
                [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:^{
                    presentingView.layer.transform = CATransform3DIdentity;
                }];
            } break;
        }

    } completion:^(BOOL finished) {
        
        (weakself.operation == CHBRevealOperationPresent) ? [presentingView removeFromSuperview] : [presentedView removeFromSuperview];
        
        [transitionContext completeTransition:YES]; // required by UIViewControllerContextTransitioning
    }];
}

- (CATransform3D)transformPresentingView:(UIView *)view
{
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D = CATransform3DTranslate(transform3D, -CGRectGetWidth(view.bounds) / 2, 0, 0);
    transform3D = CATransform3DRotate(transform3D, M_PI * 1.5f, 0.0, 1.f, 0.0);
    transform3D = CATransform3DTranslate(transform3D, CGRectGetWidth(view.bounds) / 2, 0, 0);
    
    // http://milen.me/technical/core-animation-3d-model/
    transform3D.m34 = 1.f / -500.f;
    
    return transform3D;
}

@end
