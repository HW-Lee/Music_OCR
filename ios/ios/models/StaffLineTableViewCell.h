//
//  StaffLineTableViewCell.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffLineTableViewCell : UITableViewCell

+ (StaffLineTableViewCell *)cell;
@property (weak, nonatomic) IBOutlet UIImageView *ImgView;
- (IBAction)deleteThis:(id)sender;

@end
