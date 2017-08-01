//
//  Message.h
//  WICS
//
//  Created by Rosalia Dupont on 8/1/17.
//  Copyright © 2017 Make School. All rights reserved.
//

#ifndef Message_h
#define Message_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;

@end

#endif /* Message_h */

