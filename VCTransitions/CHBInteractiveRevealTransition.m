//
//  CHBInteractiveModalRevealTransition.m
//  VCTransitions
//
//  Created by Ben Stovold on 02/12/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

#import "CHBInteractiveRevealTransition.h"

#import "CHBAnimatedRevealTransition.h"

static CGFloat kScalePresented = 0.7f;

@interface CHBInteractiveRevealTransition ()

@property (nonatomic, strong) CHBAnimatedRevealTransition *animator;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIView *presentingViewSnapshot;

@end

@implementation CHBInteractiveRevealTransition
@synthesize operation = _operation;

#pragma mark - Accessors

- (void)setOperation:(CHBRevealOperation)operation
{
    self.animator.operation = _operation = operation;
}

- (CHBAnimatedRevealTransition *)animator
{
    if (!_animator) {
        self.animator = [CHBAnimatedRevealTransition new];
        self.animator.operation = self.operation;
    }
    
    return _animator;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return [self.animator transitionDuration:transitionContext];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.interactive) {
        return; // no op
    }
    
    [self.animator animateTransition:transitionContext];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    self.interactive = NO;
    self.transitionContext = nil;
    [self.presentingViewSnapshot removeFromSuperview];
    self.presentingViewSnapshot = nil;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    UIView *transitionContainerView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *presentingView = (self.operation == CHBRevealOperationPresent) ? fromVC.view : toVC.view;
    UIView *presentedView = (self.operation == CHBRevealOperationPresent) ? toVC.view : fromVC.view;
    
    presentingView.frame = presentedView.frame = transitionContainerView.bounds;
    
    self.presentingViewSnapshot = [presentingView snapshotViewAfterScreenUpdates:NO];
    
    switch (self.operation) {
        case CHBRevealOperationPresent: {
            [transitionContainerView addSubview:self.presentingViewSnapshot];
            self.presentingViewSnapshot.layer.transform = CATransform3DIdentity;
            presentingView.alpha = 0.f;
            
            [transitionContainerView addSubview:presentedView];
            
            presentedView.alpha = 0.f;
            presentedView.transform = CGAffineTransformMakeScale(kScalePresented, kScalePresented);
        } break;
        case CHBRevealOperationDismiss: {
            [transitionContainerView addSubview:self.presentingViewSnapshot];
            self.presentingViewSnapshot.layer.transform = [self transformPresentingView:presentingView percentComplete:1.f];
            presentingView.alpha = 0.f;
            
            [transitionContainerView addSubview:presentingView];
            
            presentedView.alpha = 1.f;
            presentedView.transform = CGAffineTransformIdentity;
        } break;
    }
}

#pragma mark - UIPercentDrivenInteractiveTransition

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *presentedView = (self.operation == CHBRevealOperationPresent) ? toVC.view : fromVC.view;
    
    switch (self.operation) {
        case CHBRevealOperationPresent: {
            if (percentComplete < 0.7) {
                self.presentingViewSnapshot.layer.transform = [self transformPresentingView:self.presentingViewSnapshot percentComplete:percentComplete / 0.7];
            }
            if (percentComplete > 0.3) {
                CGFloat scalePresented = kScalePresented + ((1.f - kScalePresented) * percentComplete);
                presentedView.transform = CGAffineTransformMakeScale(scalePresented, scalePresented);
                presentedView.alpha = percentComplete - (0.3 * (1.f - percentComplete));
            } else {
                presentedView.transform = CGAffineTransformMakeScale(kScalePresented, kScalePresented);
                presentedView.alpha = 0.f;
            }
        } break;
        case CHBRevealOperationDismiss: {
            if (percentComplete > 0.3) {
                self.presentingViewSnapshot.layer.transform = [self transformPresentingView:self.presentingViewSnapshot percentComplete:(percentComplete - 0.3) / 0.7];
            }
            if (percentComplete < 0.7) {
                CGFloat scalePresented = kScalePresented + ((1.f - kScalePresented) * percentComplete);
                presentedView.transform = CGAffineTransformMakeScale(scalePresented, scalePresented);
                presentedView.alpha = percentComplete - (0.3 * (1.f - percentComplete));
            } else {
                presentedView.transform = CGAffineTransformMakeScale(kScalePresented, kScalePresented);
                presentedView.alpha = 0.f;
            }
            
        } break;
    }
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *presentingView = (self.operation == CHBRevealOperationPresent) ? fromVC.view : toVC.view;
    UIView *presentedView = (self.operation == CHBRevealOperationPresent) ? toVC.view : fromVC.view;
    
    __weak CHBInteractiveRevealTransition *weakself = self;
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        switch (weakself.operation) {
            case CHBRevealOperationPresent: {
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    weakself.presentingViewSnapshot.layer.transform = [self transformPresentingView:presentingView percentComplete:1.f];
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
                    weakself.presentingViewSnapshot.layer.transform = CATransform3DIdentity;
                }];
            } break;
        }
        
    } completion:^(BOOL finished) {
    
        presentingView.alpha = 1.f;
        
        [weakself.presentingViewSnapshot removeFromSuperview];
        weakself.presentingViewSnapshot = nil;
        
        (weakself.operation == CHBRevealOperationPresent) ? [presentingView removeFromSuperview] : [presentedView removeFromSuperview];
        
        [transitionContext completeTransition:YES]; // required by UIViewControllerContextTransitioning
    }];
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *presentingView = (self.operation == CHBRevealOperationPresent) ? fromVC.view : toVC.view;
    UIView *presentedView = (self.operation == CHBRevealOperationPresent) ? toVC.view : fromVC.view;
    
    __weak CHBInteractiveRevealTransition *weakself = self;
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        switch (weakself.operation) {
            case CHBRevealOperationPresent: {
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    presentedView.transform = CGAffineTransformMakeScale(kScalePresented, kScalePresented);
                    presentedView.alpha = 0.f;
                }];
                [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:^{
                    weakself.presentingViewSnapshot.layer.transform = CATransform3DIdentity;
                }];
            } break;
            case CHBRevealOperationDismiss: {
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    weakself.presentingViewSnapshot.layer.transform = [self transformPresentingView:presentingView percentComplete:1.f];
                }];
                [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:^{
                    presentedView.transform = CGAffineTransformIdentity;
                    presentedView.alpha = 1.f;
                }];
            } break;
        }
        
    } completion:^(BOOL finished) {
        
        presentingView.alpha = 1.f;
        
        [weakself.presentingViewSnapshot removeFromSuperview];
        weakself.presentingViewSnapshot = nil;
        
        (weakself.operation == CHBRevealOperationPresent) ? [presentedView removeFromSuperview] : [presentingView removeFromSuperview];
        
        [transitionContext completeTransition:NO]; // required by UIViewControllerContextTransitioning
    }];
}

#pragma mark - Private methods

- (CATransform3D)transformPresentingView:(UIView *)view percentComplete:(CGFloat)percentComplete
{
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D = CATransform3DTranslate(transform3D, -(CGRectGetWidth(view.bounds) / 2), 0, 0);
    transform3D = CATransform3DRotate(transform3D, M_PI * percentComplete / 2, 0.0, 1.f, 0.0);
    transform3D = CATransform3DTranslate(transform3D, (CGRectGetWidth(view.bounds) / 2), 0, 0);
    
    // TODO
    // http://milen.me/technical/core-animation-3d-model/
//    transform3D.m34 = 1.f / -500.f;
    
    return transform3D;
}

@end
