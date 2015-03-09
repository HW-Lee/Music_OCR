//
//  StaffLineTableViewCell.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "StaffLineTableViewCell.h"

@implementation StaffLineTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (StaffLineTableViewCell *)cell {
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"StaffLineTableViewCell" owner:nil options:nil];
    return items.lastObject;
}

- (IBAction)deleteThis:(id)sender {
}

@end
