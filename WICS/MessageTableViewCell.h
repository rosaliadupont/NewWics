//
//  MessageTableViewCell.h
//  WICS
//
//  Created by Rosalia Dupont on 8/1/17.
//  Copyright © 2017 Make School. All rights reserved.
//

#ifndef MessageTableViewCell_h
#define MessageTableViewCell_h
#import <UIKit/UIKit.h>

static CGFloat kMessageTableViewCellMinimumHeight = 50.0;
static CGFloat kMessageTableViewCellAvatarHeight = 30.0;

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";

@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *thumbnailView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) BOOL usedForMessage;

+ (CGFloat)defaultFontSize;

@end

#endif /* MessageTableViewCell_h */
