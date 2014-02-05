//
//  CHBViewController.m
//  VCTransitions
//
//  Created by Ben Stovold on 30/11/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

#import "CHBBlueViewController.h"
#import "CHBAnimatedRevealTransition.h"

@interface CHBBlueViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation CHBBlueViewController

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RevealOrangeFromBlue"]) {
        UIViewController *dvc = segue.destinationViewController;
        
        dvc.transitioningDelegate = self;
        dvc.modalPresentationStyle = UIModalPresentationFullScreen; // should really be UIModalPresentationCustom
        dvc.modalPresentationCapturesStatusBarAppearance = YES;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    CHBAnimatedRevealTransition *animationController = [CHBAnimatedRevealTransition new];
    animationController.operation = CHBRevealOperationPresent;
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    CHBAnimatedRevealTransition *animationController = [CHBAnimatedRevealTransition new];
    animationController.operation = CHBRevealOperationDismiss;
    return animationController;
}

#pragma mark - Unwind Segues

- (IBAction)unwindToBlue:(UIStoryboardSegue *)segue {}

@end
