//
//  TypingIndicatorView.h
//  WICS
//
//  Created by Rosalia Dupont on 8/1/17.
//  Copyright © 2017 Make School. All rights reserved.
//

#ifndef TypingIndicatorView_h
#define TypingIndicatorView_h
#import <UIKit/UIKit.h>
#import "SLKTypingIndicatorProtocol.h"

static CGFloat kTypingIndicatorViewMinimumHeight = 80.0;
static CGFloat kTypingIndicatorViewAvatarHeight = 30.0;

@interface TypingIndicatorView : UIView <SLKTypingIndicatorProtocol>

- (void)presentIndicatorWithName:(NSString *)name image:(UIImage *)image;
- (void)dismissIndicator;

@end

#endif /* TypingIndicatorView_h */
