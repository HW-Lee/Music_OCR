//
//  StaffAnalyzer.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "StaffAnalyzer.h"
#import "MatTools.h"

@implementation StaffAnalyzer

+ (std::vector<std::vector<int>>)clusterLinesWithPoints:(cv::Mat)pts {
    return std::vector<std::vector<int>>();
}

+ (cv::Mat)inliersCheckWithData:(cv::Mat)dataInput WithThresh:(double)thresh {
    cv::Mat data = dataInput.clone();
    data.convertTo(data, CV_64FC1);
    BOOL terminated = NO;
    BOOL *inlier, *temp;
    int dataLength;
    int inlierIdxCnt;
    int *inlierIdx;
    if (data.cols == 1) {
        inlier = new BOOL[data.rows];
        temp = new BOOL[data.rows];
        dataLength = data.rows;
    } else {
        inlier = new BOOL[data.cols];
        temp = new BOOL[data.cols];
        dataLength = data.cols;
        data.t();
    }
    for (int i = 0; i < dataLength; i++)
        inlier[i] = YES;
    while (!terminated) {
        terminated = YES;
        for (int i = 0; i < dataLength; i++)
            temp[i] = inlier[i];
        inlierIdxCnt = [self inlierNumWithInlier:inlier WithLength:dataLength];
        inlierIdx = new int[inlierIdxCnt];
        int cnt = 0, idx = 0;
        while (cnt < inlierIdxCnt) {
            if (inlier[idx++])
                inlierIdx[cnt++] = idx-1;
        }
        for (int i = 0; i < inlierIdxCnt; i++) {
            if (thresh*thresh*[self varEvalWithData:data WithIdx:inlierIdx IdxLength:inlierIdxCnt] >
                [self varEvalWithData:data WithIdx:inlierIdx IdxLength:inlierIdxCnt LeftIdx:i]) {
                terminated = NO;
                temp[inlierIdx[i]] = NO;
            }
        }
        for (int i = 0; i < dataLength; i++)
            inlier[i] = temp[i];
    }
    cv::Mat results([self inlierNumWithInlier:inlier WithLength:dataLength], 1, CV_32SC1);
    int cnt = 0;
    for (int i = 0; i < dataLength; i++) {
        if (inlier[i])
            results.at<int>(cnt++, 0) = i;
    }
    return results;
}

// Subfunctions of INLIERSCHECK below

+ (int)inlierNumWithInlier:(BOOL *)inlier WithLength:(int)length {
    int cnt = 0;
    for (int i = 0; i < length; i++)
        if (inlier[i])
            cnt++;
    return cnt;
}

+ (double)varEvalWithData:(cv::Mat)data WithIdx:(int *)inlierIdx IdxLength:(int)length {
    double sqrSum = 0.0, sum = 0.0;
    for (int i = 0; i < length; i++) {
        sum += data.at<double>(inlierIdx[i], 0);
        sqrSum += data.at<double>(inlierIdx[i], 0)*data.at<double>(inlierIdx[i], 0);
    }
    double var = sqrSum/length - sum*sum/length/length;
    return var;
}

+ (double)varEvalWithData:(cv::Mat)data WithIdx:(int *)inlierIdx IdxLength:(int)length LeftIdx:(int)idx {
    int *leaveOneOutInlierIdx = new int[length-1];
    for (int i = 0; i < length; i++) {
        if (i > idx)
            leaveOneOutInlierIdx[i-1] = inlierIdx[i];
        else if (i < idx)
            leaveOneOutInlierIdx[i] = inlierIdx[i];
    }
    return [self varEvalWithData:data WithIdx:leaveOneOutInlierIdx IdxLength:length-1];
}

// Subfunctions of INLIERSCHECK above

+ (cv::Mat)inliersCheckWithData:(cv::Mat)data {
    return [self inliersCheckWithData:data WithThresh:.3];
}

+ (StaffInfo *)findStafflinesWithImageData:(cv::Mat)img_gray {
    return [[StaffInfo alloc] init];
}

+ (StaffInfo *)findStafflinesWithImage:(UIImage *)img {
    return [self findStafflinesWithImageData:[MatTools imreadGrayFromUIImage:img]];
}

@end
