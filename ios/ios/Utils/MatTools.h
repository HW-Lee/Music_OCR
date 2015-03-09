//
//  MatTools.h
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SORT_DESCEND YES
#define SORT_ASCEND NO
#define AXIS_VERTICAL YES
#define AXIS_HORIZONTAL NO

@interface MatTools : NSObject

+ (cv::Mat)imreadRGBAFromUIImage:(UIImage *)image;
+ (cv::Mat)imreadRGBFromUIImage:(UIImage *)image;
+ (cv::Mat)imreadGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

+ (cv::Mat)getPageOf3DMat:(cv::Mat)mat AtPage:(int)page;
+ (cv::Mat)setPageOf3DMat:(cv::Mat)mat WithPage:(cv::Mat)matPage AtPage:(int)page;
+ (cv::Mat)getRows:(cv::Mat)rows OfMat:(cv::Mat)mat;
+ (cv::Mat)getRowsVec:(std::vector<int>)rows OfMat:(cv::Mat)mat;
+ (cv::Mat)getCols:(cv::Mat)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)getColsVec:(std::vector<int>)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)getRows:(cv::Mat)rows Cols:(cv::Mat)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)getRowsVec:(std::vector<int>)rows ColsVec:(std::vector<int>)cols OfMat:(cv::Mat)mat;
+ (cv::Mat)swapRow:(int)row1 AndRow:(int)row2 OfMat:(cv::Mat)mat;
+ (cv::Mat)swapCol:(int)col1 AndCol:(int)col2 OfMat:(cv::Mat)mat;
+ (cv::Mat)find2DMat:(cv::Mat)mat WithLogic:(NSString *)logic WithValue:(double)value;

+ (cv::Mat)resize2DMat:(cv::Mat)mat ByScale:(double)scale;
+ (cv::Mat)resizeMat:(cv::Mat)mat ByScale:(double)scale;
+ (cv::Mat)round2DMat:(cv::Mat)mat;
+ (cv::Mat)roundMat:(cv::Mat)mat;
+ (cv::Mat)binaryResultsComparedTo2DMat:(cv::Mat)mat WithLogic:(NSString *)logic WithValue:(double)value;
+ (cv::Mat)normalize2DMat:(cv::Mat)mat UniformlyBetween:(double)start And:(double)end;
+ (cv::Mat)normalize2DMat:(cv::Mat)mat;
+ (cv::Mat)bounded2DMat:(cv::Mat)mat BetweenMinValue:(double)minV AndMaxValue:(double)maxV;
+ (cv::Mat)boundedMat:(cv::Mat)mat BetweenMinValue:(double)minV AndMaxValue:(double)maxV;
+ (cv::Mat)meanOf2DMat:(cv::Mat)mat AlongWithTheAxis:(BOOL)axis;
+ (cv::Mat)meanOf2DMat:(cv::Mat)mat;
+ (cv::Mat)sumOf2DMat:(cv::Mat)mat AlongWithTheAxis:(BOOL)axis;
+ (cv::Mat)sumOf2DMat:(cv::Mat)mat;
+ (cv::Mat)diff2DMat:(cv::Mat)mat;
+ (cv::Mat)sort2DMat:(cv::Mat)mat WithCriterion:(BOOL)criterion AlongWithTheAxis:(BOOL)axis;
+ (cv::Mat)sort2DMat:(cv::Mat)mat WithCriterion:(BOOL)criterion AlongWithTheAxis:(BOOL)axis AtIdx:(int)idx;

+ (cv::Mat)positionsMatWithRows:(int)rows WithCols:(int)cols WithPages:(int)pages;

+ (NSString *)stringWithType:(int)type;
+ (void)printMatrix:(cv::Mat)matrix;

@end
