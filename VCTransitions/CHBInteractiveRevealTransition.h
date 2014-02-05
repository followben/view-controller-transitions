//
//  CHBInteractiveModalRevealTransition.h
//  VCTransitions
//
//  Created by Ben Stovold on 02/12/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

#import "CHBRevealTransition.h"

@interface CHBInteractiveRevealTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, CHBRevealTransition>

@property (nonatomic, assign, getter = isInteractive) BOOL interactive;

@end
