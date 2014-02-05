//
//  CHBGreenViewController.m
//  VCTransitions
//
//  Created by Ben Stovold on 02/12/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

#import "CHBGreenViewController.h"

#import "CHBAnimatedRevealTransition.h"
#import "CHBInteractiveRevealTransition.h"

@interface CHBGreenViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) CHBInteractiveRevealTransition *revealTransition;

@end

@implementation CHBGreenViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScreenEdgePanGestureRecognizer *gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    gestureRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RevealRedFromGreen"]) {
        UIViewController *dvc = segue.destinationViewController;
        
        dvc.transitioningDelegate = self;
        dvc.modalPresentationStyle = UIModalPresentationFullScreen; // should really be UIModalPresentationCustom
        dvc.modalPresentationCapturesStatusBarAppearance = YES;
    }
}

#pragma mark - Accessors

- (CHBInteractiveRevealTransition *)revealTransition
{
    if (!_revealTransition) {
        _revealTransition = [CHBInteractiveRevealTransition new];
    }
    
    return _revealTransition;
}

#pragma mark - UIScreenEdgePanGestureRecognizer

- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.revealTransition.interactive = YES;
        self.revealTransition.operation = CHBRevealOperationPresent;
        [self performSegueWithIdentifier:@"RevealRedFromGreen" sender:self];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = location.x / CGRectGetWidth(self.view.bounds);
        [self.revealTransition updateInteractiveTransition:(1.f - ratio)];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (location.x < CGRectGetMidX(self.view.bounds)) {
            [self.revealTransition finishInteractiveTransition];
            [self clearRevealTransition];
        } else {
            [self.revealTransition cancelInteractiveTransition];
            [self clearRevealTransition];
        }
    }
}

#pragma mark - Unwind Segues

- (IBAction)unwindToGreen:(UIStoryboardSegue *)segue {}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.revealTransition.operation = CHBRevealOperationPresent;
    return self.revealTransition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.revealTransition.operation = CHBRevealOperationDismiss;
    return self.revealTransition;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (!self.revealTransition.interactive) {
        return nil;
    }
    
    return self.revealTransition;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (!self.revealTransition.interactive) {
        return nil;
    }
    
    return self.revealTransition;
}

#pragma mark - Private methods

- (void)clearRevealTransition
{
    _revealTransition = nil;
}

@end
