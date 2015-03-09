//
//  ImageTools.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "ImageTools.h"
#import "MatTools.h"

@implementation ImageTools

+ (cv::Mat)hybridImages:(std::vector<cv::Mat>)images WithOrientation:(BOOL)opt {
    cv::Mat sizeList = cv::Mat::zeros((int)images.size(), 2, CV_32SC1);
    int rows = 0, cols = 0;
    for (int i = 0; i < images.size(); i++) {
        sizeList.at<int>(i, 0) = images[i].size().height;
        sizeList.at<int>(i, 1) = images[i].size().width;
        rows += sizeList.at<int>(i, 0);
        cols += sizeList.at<int>(i, 1);
    }
    cv::Mat image32, hybridImg;
    int type = (int)(images[0].elemSize()/images[0].elemSize1());
    if (opt == HYBRID_VERTICAL) {
        hybridImg = cv::Mat::zeros(rows, cvRound((double)cols/(double)sizeList.rows), CV_32SC(type));
        int startIdx = 0;
        for (int idx = 0; idx < images.size(); idx++) {
            images[idx].convertTo(image32, CV_64FC(type));
            if (image32.rows != sizeList.at<int>(idx, 0) || image32.cols != hybridImg.cols)
                cv::resize(image32, image32, cv::Size(0, 0),
                           (double)hybridImg.cols/image32.cols, 1, CV_INTER_LINEAR);
            [MatTools boundedMat:image32 BetweenMinValue:0 AndMaxValue:255];
            image32.convertTo(image32, CV_32SC(type));
            for (int ii = startIdx; ii < startIdx + sizeList.at<int>(idx, 0); ii++)
                for (int jj = 0; jj < hybridImg.cols; jj++)
                    switch (type) {
                        case 1:
                            hybridImg.at<int>(ii, jj) = image32.at<int>(ii-startIdx, jj);
                            break;
                        case 2:
                            hybridImg.at<cv::Vec2i>(ii, jj) = image32.at<cv::Vec2i>(ii-startIdx, jj);
                            break;
                        case 3:
                            hybridImg.at<cv::Vec3i>(ii, jj) = image32.at<cv::Vec3i>(ii-startIdx, jj);
                            break;
                        default:
                            hybridImg.at<cv::Vec4i>(ii, jj) = image32.at<cv::Vec4i>(ii-startIdx, jj);
                            break;
                    }
            startIdx += sizeList.at<int>(idx, 0);
        }
    } else {
        hybridImg = cv::Mat::zeros(cvRound((double)rows/(double)sizeList.rows), cols, CV_32SC(type));
        int startIdx = 0;
        for (int idx = 0; idx < images.size(); idx++) {
            images[idx].convertTo(image32, CV_64FC(type));
            if (image32.rows != hybridImg.rows || image32.cols != sizeList.at<int>(idx, 1))
                cv::resize(image32, image32, cv::Size(0, 0),
                           1, (double)hybridImg.rows/image32.rows, CV_INTER_LINEAR);
            [MatTools boundedMat:image32 BetweenMinValue:0 AndMaxValue:255];
            image32.convertTo(image32, CV_32SC(type));
            for (int ii = 0; ii < hybridImg.rows; ii++)
                for (int jj = startIdx; jj < startIdx + sizeList.at<int>(idx, 1); jj++)
                    switch (type) {
                        case 1:
                            hybridImg.at<int>(ii, jj) = image32.at<int>(ii, jj-startIdx);
                            break;
                        case 2:
                            hybridImg.at<cv::Vec2i>(ii, jj) = image32.at<cv::Vec2i>(ii, jj-startIdx);
                            break;
                        case 3:
                            hybridImg.at<cv::Vec3i>(ii, jj) = image32.at<cv::Vec3i>(ii, jj-startIdx);
                            break;
                        default:
                            hybridImg.at<cv::Vec4i>(ii, jj) = image32.at<cv::Vec4i>(ii, jj-startIdx);
                            break;
                    }
            startIdx += sizeList.at<int>(idx, 1);
        }
    }
    hybridImg.convertTo(hybridImg, images[0].type());
    return hybridImg;
}

+ (cv::Mat)truncateImageData:(cv::Mat)imgData WithBounds:(cv::Mat)bounds WithOrientation:(BOOL)orientation {
    cv::Mat boundsRd = [MatTools round2DMat:bounds];
    cv::Mat imgDataDbl;
    cv::Mat im_truncated;
    double regionMax, regionMin;
    
    if (orientation == TRUNCATE_VERTICAL) {
        for (int i = 0; i < boundsRd.rows; i++) {
            if (boundsRd.at<int>(i, 0) < 0)
                boundsRd.at<int>(i, 0) = 0;
            else if (boundsRd.at<int>(i, 0) > imgData.rows-1)
                boundsRd.at<int>(i, 0) = imgData.rows - 1;
            if (boundsRd.at<int>(i, 1) < 0)
                boundsRd.at<int>(i, 1) = 0;
            else if (boundsRd.at<int>(i, 1) > imgData.rows-1)
                boundsRd.at<int>(i, 1) = imgData.rows - 1;
        }
    } else {
        for (int i = 0; i < boundsRd.rows; i++) {
            if (boundsRd.at<int>(i, 0) < 0)
                boundsRd.at<int>(i, 0) = 0;
            else if (boundsRd.at<int>(i, 0) > imgData.cols-1)
                boundsRd.at<int>(i, 0) = imgData.cols - 1;
            if (boundsRd.at<int>(i, 1) < 0)
                boundsRd.at<int>(i, 1) = 0;
            else if (boundsRd.at<int>(i, 1) > imgData.cols-1)
                boundsRd.at<int>(i, 1) = imgData.cols - 1;
        }
    }
    
    cv::minMaxLoc(boundsRd.col(0), &regionMin, NULL);
    cv::minMaxLoc(boundsRd.col(1), NULL, &regionMax);
    
    int type;
    if (imgData.elemSize()/imgData.elemSize1() == 1)
        type = CV_64FC1;
    else if (imgData.elemSize()/imgData.elemSize1() == 2)
        type = CV_64FC2;
    else if (imgData.elemSize()/imgData.elemSize1() == 3)
        type = CV_64FC3;
    else
        type = CV_64FC4;
    imgData.convertTo(imgDataDbl, type);
    if (orientation == TRUNCATE_VERTICAL) {
        im_truncated = cv::Mat::zeros((int)(regionMax-regionMin+1), imgData.cols, type);
        for (int i = 0; i < boundsRd.rows; i++) {
            for (int k = boundsRd.at<int>(i, 0); k <= boundsRd.at<int>(i, 1); k++) {
                 if (imgData.elemSize()/imgData.elemSize1() == 1)
                     im_truncated.at<double>(k - (int)regionMin, i) = imgDataDbl.at<double>(k, i);
                else if (imgData.elemSize()/imgData.elemSize1() == 2)
                    im_truncated.at<cv::Vec2d>(k - (int)regionMin, i) = imgDataDbl.at<cv::Vec2d>(k, i);
                else if (imgData.elemSize()/imgData.elemSize1() == 3)
                    im_truncated.at<cv::Vec3d>(k - (int)regionMin, i) = imgDataDbl.at<cv::Vec3d>(k, i);
                else if (imgData.elemSize()/imgData.elemSize1() == 4)
                    im_truncated.at<cv::Vec4d>(k - (int)regionMin, i) = imgDataDbl.at<cv::Vec4d>(k, i);
            }
        }
    } else {
        im_truncated = cv::Mat::zeros(imgData.rows, (int)(regionMax-regionMin+1), type);
        for (int i = 0; i < boundsRd.rows; i++) {
            for (int k = boundsRd.at<int>(i, 0); k <= boundsRd.at<int>(i, 1); k++) {
                if (imgData.elemSize()/imgData.elemSize1() == 1)
                    im_truncated.at<double>(i, k - (int)regionMin) = imgDataDbl.at<double>(i, k);
                else if (imgData.elemSize()/imgData.elemSize1() == 2)
                    im_truncated.at<cv::Vec2d>(i, k - (int)regionMin) = imgDataDbl.at<cv::Vec2d>(i, k);
                else if (imgData.elemSize()/imgData.elemSize1() == 3)
                    im_truncated.at<cv::Vec3d>(i, k - (int)regionMin) = imgDataDbl.at<cv::Vec3d>(i, k);
                else if (imgData.elemSize()/imgData.elemSize1() == 4)
                    im_truncated.at<cv::Vec4d>(i, k - (int)regionMin) = imgDataDbl.at<cv::Vec4d>(i, k);
            }
        }
    }
    im_truncated.convertTo(im_truncated, imgData.type());
    return im_truncated;
}

+ (cv::Mat)markImage3Data:(cv::Mat)imgData
                WithXData:(std::vector<int>)xx
                WithYData:(std::vector<int>)yy
               WithColorR:(int)r
               WithColorG:(int)g
               WithColorB:(int)b {
    cv::Vec3b rgb;
    if (r > 255)
        rgb[0] = 255;
    else if (r < 0)
        rgb[0] = 0;
    else
        rgb[0] = r;
    if (g > 255)
        rgb[1] = 255;
    else if (g < 0)
        rgb[1] = 0;
    else
        rgb[1] = g;
    if (b > 255)
        rgb[2] = 255;
    else if (b < 0)
        rgb[2] = 0;
    else
        rgb[2] = b;
    return [self markImage3Data:imgData WithXDataVec:xx WithYDataVec:yy WithColorVec:rgb];
}

+ (cv::Mat)markImage3Data:(cv::Mat)imgData
             WithXDataVec:(std::vector<int>)xx
             WithYDataVec:(std::vector<int>)yy
             WithColorVec:(cv::Vec3b)rgb {
    cv::Mat imgOut = imgData.clone();
    for (int i = 0; i < xx.size(); i++) {
        imgOut.at<cv::Vec3b>(xx[i], yy[i])[0] = rgb[0];
        imgOut.at<cv::Vec3b>(xx[i], yy[i])[1] = rgb[1];
        imgOut.at<cv::Vec3b>(xx[i], yy[i])[2] = rgb[2];
    }
    return imgOut;
}

+ (cv::Mat)markImage3Data:(cv::Mat)imgData WithPtsData:(cv::Mat)pts WithColor:(cv::Vec3b)rgb {
    cv::Mat imgOut = imgData.clone();
    for (int i = 0; i < pts.rows; i++) {
        int x = pts.at<int>(i, 0);
        int y = pts.at<int>(i, 1);
        imgOut.at<cv::Vec3b>(x, y) = rgb;
    }
    return imgOut;
}

+ (cv::Mat)markImage3Data:(cv::Mat)imgData
           WithPtsDataVec:(std::vector<cv::Point>)pts
             WithColorVec:(cv::Vec3b)rgb {
    cv::Mat imgOut = imgData.clone();
    for (int i = 0; i < pts.size(); i++) {
        imgOut.at<cv::Vec3b>((int)pts[i].x, (int)pts[i].y) = rgb;
    }
    return imgOut;
}

+ (cv::Mat)rotateImgMat:(cv::Mat)img WithDegree:(double)deg {
    cv::Mat rotatedMat;
    cv::Point2f pt(img.cols/2., img.rows/2.);
    cv::Mat r = cv::getRotationMatrix2D(pt, deg, 1.);
    cv::warpAffine(img, rotatedMat, r, cv::Size(img.cols, img.rows));
    return rotatedMat;
}

@end
