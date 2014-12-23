//
//  matTools.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "MatTools.h"

@implementation MatTools

+ (cv::Mat)imreadRGBAFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (cv::Mat)imreadRGBFromUIImage:(UIImage *)image {
    cv::Mat cvMatRGBA = [self imreadRGBAFromUIImage:image];
    cv::Mat cvMat;
    cv::cvtColor(cvMatRGBA, cvMat, CV_RGBA2RGB);
    return cvMat;
}

+ (cv::Mat)imreadGrayFromUIImage:(UIImage *)image {
    cv::Mat cvMatRGBA = [self imreadRGBAFromUIImage:image];
    cv::Mat cvMat;
    cv::cvtColor(cvMatRGBA, cvMat, CV_RGBA2GRAY);
    return cvMat;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+ (cv::Mat)getPageOf3DMat:(cv::Mat)mat AtPage:(int)page {
    int type = mat.type() % 8;
    int vecLength = mat.type() / 8 + 1;
    int dataType;
    if (type == 0)
        dataType = CV_8UC1;
    else if (type == 1)
        dataType = CV_8SC1;
    else if (type == 2)
        dataType = CV_16UC1;
    else if (type == 3)
        dataType = CV_16SC1;
    else if (type == 4)
        dataType = CV_32SC1;
    else if (type == 5)
        dataType = CV_32FC1;
    else
        dataType = CV_64FC1;
    cv::Mat mat64;
    mat.convertTo(mat64, CV_64FC1);
    cv::Mat cvMat = cv::Mat::zeros(mat.rows, mat.cols, CV_64FC1);
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            if (vecLength == 1)
                cvMat.at<double>(i, j) = mat64.at<double>(i, j);
            else if (vecLength == 2)
                    cvMat.at<double>(i, j) = mat64.at<cv::Vec2d>(i, j)[page];
            else if (vecLength == 3)
                    cvMat.at<double>(i, j) = mat64.at<cv::Vec3d>(i, j)[page];
            else if (vecLength == 4)
                    cvMat.at<double>(i, j) = mat64.at<cv::Vec4d>(i, j)[page];
        }
    }
    cvMat.convertTo(cvMat, dataType);
    return cvMat;
}

+ (cv::Mat)positionsMatWithRows:(int)rows WithCols:(int)cols WithPages:(int)pages {
    cv::Mat cvMat;
    cv::Mat fundMat = cv::Mat::zeros(rows, cols, CV_32SC1);
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            fundMat.at<int>(i, j) = 10*(i+1) + (j+1);
    if (pages == 1)
        cvMat = fundMat.clone();
    else if (pages == 2) {
        cvMat = cv::Mat::zeros(rows, cols, CV_32SC2);
        for (int i = 0; i < rows; i++)
            for (int j = 0; j < cols; j++)
                for (int p = 0; p < pages; p++)
                    cvMat.at<cv::Vec2i>(i, j)[p] = fundMat.at<int>(i, j)*10 + (p+1);
    } else if (pages == 3) {
        cvMat = cv::Mat(rows, cols, CV_32SC3);
        for (int i = 0; i < rows; i++)
            for (int j = 0; j < cols; j++)
                for (int p = 0; p < pages; p++)
                    cvMat.at<cv::Vec3i>(i, j)[p] = fundMat.at<int>(i, j)*10 + (p+1);
    } else {
        cvMat = cv::Mat::zeros(rows, cols, CV_32SC4);
        for (int i = 0; i < rows; i++)
            for (int j = 0; j < cols; j++)
                for (int p = 0; p < pages; p++)
                    cvMat.at<cv::Vec4i>(i, j)[p] = fundMat.at<int>(i, j)*10 + (p+1);
    }
    return cvMat;
}

+ (cv::Mat)normalize2DMat:(cv::Mat)mat UniformlyBetween:(double)start And:(double)end {
    cv::Mat doubleInputMat;
    mat.convertTo(doubleInputMat, CV_64FC1);
    double minV, maxV;
    cv::minMaxLoc(doubleInputMat, &minV, &maxV);
    doubleInputMat = (doubleInputMat - minV) / (maxV - minV);
    doubleInputMat = doubleInputMat * (end-start) + start;
    return doubleInputMat;
}

+ (cv::Mat)normalize2DMat:(cv::Mat)mat {
    return [self normalize2DMat:mat UniformlyBetween:0.0 And:1.0];
}

+ (cv::Mat)resize2DMat:(cv::Mat)mat ByScale:(double)scale {
    cv::Mat dst;
    if (scale < 1)
        cv::resize(mat, dst, cv::Size(0, 0), scale, scale, CV_INTER_AREA);
    else
        cv::resize(mat, dst, cv::Size(0, 0), scale, scale, CV_INTER_LINEAR);
    return dst;
}

+ (cv::Mat)round2DMat:(cv::Mat)mat {
    cv::Mat input, output(mat.size(), CV_32SC1);
    mat.convertTo(input, CV_64FC1);
    for (int i = 0; i < input.rows; i++)
        for (int j = 0; j < input.cols; j++)
            output.at<int>(i, j) = cvRound(input.at<double>(i, j));
    return output;
}

+ (cv::Mat)bounded2DMat:(cv::Mat)mat BetweenMinValue:(double)minV AndMaxValue:(double)maxV {
    cv::Mat cvMat;
    mat.convertTo(cvMat, CV_64FC1);
    for (int i = 0; i < cvMat.rows; i++)
        for (int j = 0; j < cvMat.cols; j++)
            if (cvMat.at<double>(i, j) > maxV)
                cvMat.at<double>(i, j) = maxV;
            else if (cvMat.at<double>(i, j) < minV)
                cvMat.at<double>(i, j) = minV;
    cvMat.convertTo(cvMat, mat.type());
    return cvMat;
}

+ (cv::Mat)getCols:(cv::Mat)cols OfMat:(cv::Mat)mat {
    cv::Mat cvMat(0, 0, mat.type());
    cv::Mat matT = mat.t();
    for (int i = 0; i < cols.rows; i++)
        cvMat.push_back(matT.row(cols.at<int>(i, 0)));
    return cvMat.t();
}

+ (cv::Mat)getColsVec:(std::vector<int>)cols OfMat:(cv::Mat)mat {
    cv::Mat cvMat(0, 0, mat.type());
    cv::Mat matT = mat.t();
    for (int i = 0; i < cols.size(); i++)
        cvMat.push_back(matT.row(cols[i]));
    return cvMat.t();
}

+ (cv::Mat)getRows:(cv::Mat)rows OfMat:(cv::Mat)mat {
    cv::Mat cvMat(0, 0, mat.type());
    for (int i = 0; i < rows.rows; i++)
        cvMat.push_back(mat.row(rows.at<int>(i, 0)));
    return cvMat;
}

+ (cv::Mat)getRowsVec:(std::vector<int>)rows OfMat:(cv::Mat)mat {
    cv::Mat cvMat(0, 0, mat.type());
    for (int i = 0; i < rows.size(); i++)
        cvMat.push_back(mat.row(rows[i]));
    return cvMat;
}

+ (cv::Mat)getRows:(cv::Mat)rows Cols:(cv::Mat)cols OfMat:(cv::Mat)mat {
    return [self getCols:cols OfMat:[self getRows:rows OfMat:mat]];
}

+ (cv::Mat)getRowsVec:(std::vector<int>)rows ColsVec:(std::vector<int>)cols OfMat:(cv::Mat)mat {
    return [self getColsVec:cols OfMat:[self getRowsVec:rows OfMat:mat]];
}

+ (cv::Mat)binaryResultsComparedTo2DMat:(cv::Mat)mat WithLogic:(NSString *)logic WithValue:(double)value {
    cv::Mat results = cv::Mat::zeros(mat.rows, mat.cols, CV_8UC1);
    cv::Mat inputMat;
    mat.convertTo(inputMat, CV_64FC1);
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            if ([logic isEqualToString:@">"])
                results.at<uchar>(i, j) = (inputMat.at<double>(i, j) > value);
            else if ([logic isEqualToString:@">="])
                results.at<uchar>(i, j) = (inputMat.at<double>(i, j) >= value);
            else if ([logic isEqualToString:@"=="])
                results.at<uchar>(i, j) = (inputMat.at<double>(i, j) == value);
            else if ([logic isEqualToString:@"<="])
                results.at<uchar>(i, j) = (inputMat.at<double>(i, j) <= value);
            else if ([logic isEqualToString:@"<"])
                results.at<uchar>(i, j) = (inputMat.at<double>(i, j) < value);
        }
    }
    return results;
}

+ (NSString *)stringWithType:(int)type {
    int i = type % 8;
    int j = type / 8 + 1;
    NSString * typeStr;
    if (i == 0)
        typeStr = @"CV_8UC";
    else if (i == 1)
        typeStr = @"CV_8SC";
    else if (i == 2)
        typeStr = @"CV_16UC";
    else if (i == 3)
        typeStr = @"CV_16SC";
    else if (i == 4)
        typeStr = @"CV_32SC";
    else if (i == 5)
        typeStr = @"CV_32FC";
    else
        typeStr = @"CV_64FC";
    typeStr = [NSString stringWithFormat:@"%@%d", typeStr, j];
    return typeStr;
}



+ (void)printMatrix:(cv::Mat)matrix {
    std::cout << matrix << std::endl;
    cv::Mat mat;
    matrix.convertTo(mat, CV_64FC1);
    double minV, maxV;
    cv::minMaxLoc(mat, &minV, &maxV);
    std::cout << "Max value: " << maxV << std::endl;
    std::cout << "Min value: " << minV << std::endl;
}

@end
