//
//  ImageTools.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TRUNCATE_VERTICAL NO
#define TRUNCATE_HORIZONTAL YES
#define HYBRID_VERTICAL NO
#define HYBRID_HORIZONTAL YES

@interface ImageTools : NSObject

+ (cv::Mat)hybridImages:(std::vector<cv::Mat>)images WithOrientation:(BOOL)opt;
+ (cv::Mat)truncateImageData:(cv::Mat)imgData WithBounds:(cv::Mat)bounds WithOrientation:(BOOL)orientation;
+ (cv::Mat)markImage3Data:(cv::Mat)imgData
                WithXData:(std::vector<int>)xx
                WithYData:(std::vector<int>)yy
               WithColorR:(int)r
               WithColorG:(int)g
               WithColorB:(int)b;
+ (cv::Mat)markImage3Data:(cv::Mat)imgData
             WithXDataVec:(std::vector<int>)xx
             WithYDataVec:(std::vector<int>)yy
             WithColorVec:(cv::Vec3b)rgb;
+ (cv::Mat)markImage3Data:(cv::Mat)imgData WithPtsData:(cv::Mat)pts WithColor:(cv::Vec3b)rgb;
+ (cv::Mat)markImage3Data:(cv::Mat)imgData
           WithPtsDataVec:(std::vector<cv::Point>)pts
             WithColorVec:(cv::Vec3b)rgb;
+ (cv::Mat)rotateImgMat:(cv::Mat)img WithDegree:(double)deg;

@end
