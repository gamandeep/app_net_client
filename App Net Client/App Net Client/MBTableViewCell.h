//
//  MBTableViewCell.h
//  App Net Client
//
//  Created by Gamandeep on 11/04/14.
//  Copyright (c) 2014 MB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MBTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* postLabel;
@property (nonatomic, weak) IBOutlet UIImageView* picView;

@end
