//
//  StaffIndicationViewController.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "StaffIndicationViewController.h"
#import "StaffLineTableViewCell.h"
#import "StaffInfo.h"
#import "MatTools.h"
#import "ImageTools.h"

@interface StaffIndicationViewController ()

@end

@implementation StaffIndicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _table.delegate = self;
    _table.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_staffInfoArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StaffLineTableViewCell *cell = [_table dequeueReusableCellWithIdentifier:@"StaffLineTableViewCell"];
    if (!cell) {
        [_table registerNib:[UINib nibWithNibName:@"StaffLineTableViewCell" bundle:nil]
     forCellReuseIdentifier:@"StaffLineTableViewCell"];
        cell = [_table dequeueReusableCellWithIdentifier:@"StaffLineTableViewCell"];
    }
    StaffInfo *obj = [_staffInfoArr objectAtIndex:indexPath.row];
    //1.5*( info.lineSpace(ii)*4+info.lineWidth(ii)*5 )
    double margin = 1.5 * (obj.lineSpace*4 + obj.lineWidth*5);
    cv::Mat bounds(_imgData.cols, 2, CV_64FC1);
    for (int i = 0; i < _imgData.cols; i++) {
        bounds.at<double>(i, 0) = (double)i*obj.centerLineSlope + obj.centerLineIntercept - margin;
        bounds.at<double>(i, 1) = (double)i*obj.centerLineSlope + obj.centerLineIntercept + margin;
    }
    cv::Mat truncatedImg = [ImageTools truncateImageData:_imgData
                                              WithBounds:bounds
                                         WithOrientation:TRUNCATE_VERTICAL];
    cell.imageView.image = [MatTools UIImageFromCVMat:truncatedImg];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
