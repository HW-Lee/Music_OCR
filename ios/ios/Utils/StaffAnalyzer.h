//
//  StaffAnalyzer.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaffInfo.h"

@interface StaffAnalyzer : NSObject

+ (std::vector<std::vector<int>>)clusterLinesWithPoints:(cv::Mat)pts;
+ (cv::Mat)inliersCheckWithData:(cv::Mat)data WithThresh:(double)thresh;
+ (cv::Mat)inliersCheckWithData:(cv::Mat)data;
+ (NSArray *)findStafflinesWithImageData:(cv::Mat)img_gray; //
+ (NSArray *)findStafflinesWithImage:(UIImage *)img;

@end
