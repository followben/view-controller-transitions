//
//  CHBView.m
//  VCTransitions
//
//  Created by Ben Stovold on 02/12/2013.
//  Copyright (c) 2013 Ben Stovold. All rights reserved.
//

#import "CHBView.h"

@interface CHBView ()

@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation CHBView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.button.layer.cornerRadius = CGRectGetWidth(self.button.bounds) / 2;
}

@end
