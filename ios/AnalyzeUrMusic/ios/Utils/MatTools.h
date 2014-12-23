//
//  MatTools.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatTools : NSObject

+ (cv::Mat)imreadRGBAFromUIImage:(UIImage *)image;
+ (cv::Mat)imreadRGBFromUIImage:(UIImage *)image;
+ (cv::Mat)imreadGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

+ (cv::Mat)getPageOf3DMat:(cv::Mat)mat AtPage:(int)page;
+ (cv::Mat)getRows:(cv::Mat)rows OfMat:(cv::Mat)mat;
+ (cv::Mat)getRowsVec:(std::vector<int>)rows OfMat:(cv::Mat)mat;
+ (cv::Mat)getCols:(cv::Mat)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)getColsVec:(std::vector<int>)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)getRows:(cv::Mat)rows Cols:(cv::Mat)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)getRowsVec:(std::vector<int>)rows ColsVec:(std::vector<int>)cols OfMat:(cv::Mat)mat;

+ (cv::Mat)resize2DMat:(cv::Mat)mat ByScale:(double)scale;
+ (cv::Mat)round2DMat:(cv::Mat)mat;
+ (cv::Mat)binaryResultsComparedTo2DMat:(cv::Mat)mat WithLogic:(NSString *)logic WithValue:(double)value;
+ (cv::Mat)normalize2DMat:(cv::Mat)mat UniformlyBetween:(double)start And:(double)end;
+ (cv::Mat)normalize2DMat:(cv::Mat)mat;
+ (cv::Mat)bounded2DMat:(cv::Mat)mat BetweenMinValue:(double)minV AndMaxValue:(double)maxV;

+ (cv::Mat)positionsMatWithRows:(int)rows WithCols:(int)cols WithPages:(int)pages;

+ (NSString *)stringWithType:(int)type;
+ (void)printMatrix:(cv::Mat)matrix;

@end
