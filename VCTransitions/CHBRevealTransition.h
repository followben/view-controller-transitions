//
//  CHBRevealTransition.h
//  VCTransitions
//
//  Created by Ben Stovold on 02/12/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

typedef NS_ENUM(NSUInteger, CHBRevealOperation) {
    CHBRevealOperationPresent,
    CHBRevealOperationDismiss
};

@protocol CHBRevealTransition <NSObject>

@property (nonatomic, assign) CHBRevealOperation operation;

@end
