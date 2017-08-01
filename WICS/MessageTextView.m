//
//  MessageTextView.m
//  WICS
//
//  Created by Rosalia Dupont on 8/1/17.
//  Copyright © 2017 Make School. All rights reserved.
//

#import "MessageTextView.h"

@implementation MessageTextView

- (instancetype)init
{
    if (self = [super init]) {
        // Do something
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.placeholder = NSLocalizedString(@"Message", nil);
    self.placeholderColor = [UIColor lightGrayColor];
    self.pastableMediaTypes = SLKPastableMediaTypeAll;
    
    self.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0].CGColor;
}

@end
