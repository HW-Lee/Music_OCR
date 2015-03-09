//
//  StaffIndicationViewController.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffIndicationViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property NSArray *staffInfoArr;
@property cv::Mat imgData;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end
