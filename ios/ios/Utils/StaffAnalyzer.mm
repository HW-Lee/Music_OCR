//
//  StaffAnalyzer.m
//  AnalyzeUrMusic
//
//  Created by HW Lee on 2014/12/18.
//  Copyright (c) 2014年 HW Lee. All rights reserved.
//

#import "StaffAnalyzer.h"
#import "MatTools.h"
#import "StaffInfo.h"

@implementation StaffAnalyzer

+ (std::vector<std::vector<int>>)clusterLinesWithPoints:(cv::Mat)pts {
    cv::Mat pts64;
    std::vector<std::vector<int>> lineGroup(0);
    pts.convertTo(pts64, CV_64FC1);
    cv::Mat idxCol(1, pts64.rows, CV_64FC1);
    for (int i = 0; i < pts64.rows; i++)
        idxCol.at<double>(0, i) = i;
    pts64 = pts64.t();
    pts64.push_back(idxCol);
    pts64 = pts64.t();
    double maxY = pts64.at<double>(0, 1);
    for (int i = 0; i < pts64.rows; i++)
        if (pts64.at<double>(i, 1) > maxY)
            maxY = pts64.at<double>(i, 1);
    for (int i = 0; i < pts64.rows; i++)
        pts64.at<double>(i, 1) /= maxY;
    std::vector<int> uniqueXIdx(1, 0);
    pts64 = [MatTools sort2DMat:pts64 WithCriterion:SORT_ASCEND AlongWithTheAxis:AXIS_VERTICAL];
    for (int i = 1; i < pts64.rows; i++) {
        if ((int)pts64.at<double>(i, 0) != (int)pts64.at<double>(i-1, 0))
            uniqueXIdx.push_back(i);
    }
    std::vector<int> clusterTag(pts64.rows, 0);
    std::vector<double> clusterRefs(0);
    double thresh = .05;
    int Ncluster = 1;
    if (uniqueXIdx.size() > 0 && uniqueXIdx[1] > 0) {
        cv::Mat initRefs = pts64.rowRange(0, uniqueXIdx[1]);
        initRefs = initRefs.colRange(1, 3);
        initRefs = [MatTools sort2DMat:initRefs WithCriterion:SORT_ASCEND AlongWithTheAxis:AXIS_VERTICAL];
        clusterTag[(int)initRefs.at<double>(0, 1)] = 1;
        clusterRefs.push_back(initRefs.at<double>(0, 0));
        for (int i = 1; i < initRefs.rows; i++) {
            if (initRefs.at<double>(i, 0)-initRefs.at<double>(i-1, 0) > thresh) {
                Ncluster++;
                clusterTag[(int)initRefs.at<double>(i, 1)] = Ncluster;
                clusterRefs.push_back(initRefs.at<double>(i, 0));
            }
        }
    }
    if (uniqueXIdx.size() > 1) {
        for (int i = 1; i < uniqueXIdx.size(); i++) {
            int startIdx = uniqueXIdx[i];
            int endIdx = (i == uniqueXIdx.size()-1) ? pts64.rows:uniqueXIdx[i+1];
            for (int j = startIdx; j < endIdx; j++) {
                double v = (clusterRefs[0] > pts64.at<double>(j, 1)) ?
                    clusterRefs[0]-pts64.at<double>(j, 1):pts64.at<double>(j, 1)-clusterRefs[0];
                int loc = 0;
                
                // Equivalent instruction: [v, loc] = min( abs(clusterRefs - pts(jj)) );
                for (int k = 1; k < clusterRefs.size(); k++) {
                    double diff = (clusterRefs[k] > pts64.at<double>(j, 1)) ?
                        clusterRefs[k]-pts64.at<double>(j, 1):pts64.at<double>(j, 1)-clusterRefs[k];
                    if (diff < v) {
                        v = diff;
                        loc = k;
                    }
                }
                if (v < thresh) {
                    clusterTag[(int)pts64.at<double>(j, 2)] = loc + 1;
                    clusterRefs[loc] = pts64.at<double>(j, 1);
                } else {
                    Ncluster++;
                    clusterRefs.push_back(pts64.at<double>(j, 1));
                    clusterTag[(int)pts64.at<double>(j, 2)] = Ncluster;
                }
            }
        }
        double range = pts64.at<double>(pts64.rows-1, 0) - pts64.at<double>(0, 0);
        pts64 = [MatTools sort2DMat:pts64 WithCriterion:SORT_ASCEND AlongWithTheAxis:AXIS_VERTICAL AtIdx:2];
        //[MatTools printMatrix:pts64];
        std::vector<int> clusterIdx(0);
        for (int i = 1; i <= Ncluster; i++) {
            double xMax = -1, xMin = -1;
            for (int j = 0; j < clusterTag.size(); j++) {
                if (clusterTag[j] == i) {
                    clusterIdx.push_back(j);
                    if (xMin == -1 && xMax == -1) {
                        xMin = pts64.at<double>(j, 0);
                        xMax = xMin;
                    } else {
                        xMin = (pts64.at<double>(j, 0) > xMin) ? xMin:pts64.at<double>(j, 0);
                        xMax = (pts64.at<double>(j, 0) > xMax) ? pts64.at<double>(j, 0):xMax;
                    }
                }
            }
            if (clusterIdx.size() > 0 && xMax-xMin < .2*range) {
                for (int j = 0; j < clusterIdx.size(); j++)
                    clusterTag[clusterIdx[j]] = 0;
                for (int j = 0; j < clusterTag.size(); j++)
                    if (clusterTag[j] >= i)
                        clusterTag[j]--;
                Ncluster--;
                i--;
            }
            clusterIdx.clear();
        }
        lineGroup = std::vector<std::vector<int>>(Ncluster);
        for (int i = 0; i < lineGroup.size(); i++)
            lineGroup[i] = std::vector<int>(0);
        for (int i = 0; i < clusterTag.size(); i++)
            if (clusterTag[i] > 0)
                lineGroup[clusterTag[i]-1].push_back(i);
    }
    std::vector<int> line;
    for (int i = 0; i < lineGroup.size(); i++)
        line = lineGroup[i];
    return lineGroup;
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

+ (NSArray *)findStafflinesWithImageData:(cv::Mat)img_gray {
    NSMutableArray *staffLines;
    double maxV, minV;
    cv::Mat img_gray64;
    cv::Mat boxes(0, 5, CV_64FC1);
    img_gray.convertTo(img_gray64, CV_64FC1);
    cv::minMaxLoc(img_gray64, &minV, &maxV);
    img_gray64 = (img_gray64 - minV) / (maxV - minV);
    cv::Mat img_binary = [MatTools binaryResultsComparedTo2DMat:img_gray64 WithLogic:@"<" WithValue:.6];
    for (int i = 0; i < img_binary.cols; i++) {
        cv::Mat colScanned = img_binary.col(i);
        cv::Mat crossPts(0, 1, CV_32SC1);
        // Equivalent instruction:
        //      crossPts = find(diff(colScanned).^2 > 0);
        for (int j = 0; j < colScanned.rows-1; j++) {
            if (colScanned.at<uchar>(j, 0) != colScanned.at<uchar>(j+1, 0)) {
                cv::Mat pts(1, 1, CV_32SC1);
                pts.at<int>(0, 0) = j;
                crossPts.push_back(pts);
            }
        }
        if (crossPts.rows > 0) {
            // Equivalent instruction:
            //      intervals = [crossPts(1) diff(crossPts) length(colScanned)-crossPts(end)];
            //      intervals = [intervals' [1; crossPts'+1;]];
            cv::Mat intervals(0, 1, CV_32SC1);
            cv::Mat dummy(1, 1, CV_32SC1);
            dummy.at<int>(0, 0) = crossPts.at<int>(0, 0);
            intervals.push_back(dummy.clone());
            intervals.push_back([MatTools diff2DMat:crossPts]);
            dummy.at<int>(0, 0) = colScanned.rows - crossPts.at<int>(crossPts.rows-1);
            intervals.push_back(dummy.clone());
            dummy.at<int>(0, 0) = 1;
            cv::Mat temp = crossPts + 1;
            dummy.push_back(temp);
            dummy = dummy.t();
            intervals = intervals.t();
            intervals.push_back(dummy.clone());
            intervals = intervals.t();
            // Equivalent instruction:
            //      idx = 1:length(intervals);
            //      zerosInterv = intervals( mod(idx, 2) == (colScanned(crossPts(1))==0), : );
            //      onesInterv = intervals( mod(idx, 2) == (colScanned(crossPts(1))==1), : );
            std::vector<int> zerosRow(0), onesRow(0);
            for (int j = 0; j < intervals.rows; j++) {
                if (( (j+1) % 2 ) == ( colScanned.at<uchar>(crossPts.at<int>(0, 0), 0) == 0 ))
                    zerosRow.push_back(j);
                else
                    onesRow.push_back(j);
            }
            cv::Mat zerosInterv = [MatTools getRowsVec:zerosRow OfMat:intervals];
            cv::Mat onesInterv = [MatTools getRowsVec:onesRow OfMat:intervals];
            // Equivalent instruction:
            //      for jj = 1:size(onesInterv, 1)-4
            //          window = zerosInterv(jj:jj+3, 1);
            //          if sum( (window - mean(window))/mean(window) < .1 ) == 4
            //              v = onesInterv(jj:jj+4, 1);
            //              if sum( (v-mean(v))/mean(v) < .5 ) < 5
            //                  continue;
            //              end
            //              detectedRegion = [zerosInterv(jj, 2)-mean(window); zerosInterv(jj+3, 2)+2*mean(window)];
            //              detectedRegion = max( round(detectedRegion), 1 );
            //              detectedRegion = min( round(detectedRegion), length(rowScanned) );
            //              % [idx region_min region_max lineWidth lineSpace]
            //              boxes = [boxes; ii detectedRegion' mean(v) mean(window)];
            //         end
            //      end
            for (int j = 0; j < onesInterv.rows-4; j++) {
                cv::Mat window = zerosInterv.rowRange(j, j+4).col(0);
                double windowMean = [MatTools meanOf2DMat:window].at<double>(0, 0);
                cv::Mat bin = [MatTools binaryResultsComparedTo2DMat:cv::abs(window-windowMean)/windowMean
                                                           WithLogic:@"<"
                                                           WithValue:.1];
                if ((int)[MatTools sumOf2DMat:bin].at<double>(0, 0) == 4) {
                    cv::Mat v = onesInterv.rowRange(j, j+5).col(0);
                    double vMean = [MatTools meanOf2DMat:v].at<double>(0, 0);
                    bin = [MatTools binaryResultsComparedTo2DMat:cv::abs(v-vMean)/vMean
                                                       WithLogic:@"<"
                                                       WithValue:.5];
                    if ((int)[MatTools sumOf2DMat:bin].at<double>(0, 0) >= 5) {
                        cv::Mat box(1, 5, CV_64FC1);
                        box.at<double>(0, 0) = i;
                        box.at<double>(0, 1) = ((double)zerosInterv.at<int>(j, 1)-windowMean > 0) ?
                            (double)zerosInterv.at<int>(j, 1)-windowMean:0;
                        box.at<double>(0, 2) = ((double)zerosInterv.at<int>(j+3, 1)+2*windowMean < colScanned.rows-1) ?
                            (double)zerosInterv.at<int>(j+3, 1)+2*windowMean:colScanned.rows-1;
                        box.at<double>(0, 3) = vMean;
                        box.at<double>(0, 4) = windowMean;
                        boxes.push_back(box);
                    }
                }
            }
        }
    }
    // Equivalent instruction:
    //      pts = [boxes(:, 1) mean(boxes(:, 2:3), 2)];
    //      [lines npts] = clusterLines(pts);
    //      stafflineCenter = cell(size(lines, 2), 1);
    //      slopes = zeros(size(lines, 2), 1);
    //      widths = slopes;
    //      spaces = slopes;
    //      for ii = 1:size(lines, 2)
    //          x = pts(lines(1:npts(ii), ii), 1);
    //          y = pts(lines(1:npts(ii), ii), 2);
    //          w = [x ones(length(x), 1)] \ y;
    //          stafflineCenter{ii} = w;
    //          slopes(ii) = w(1);
    //          widths(ii) = mean( boxes(lines(1:npts(ii), ii), 4) );
    //          spaces(ii) = mean( boxes(lines(1:npts(ii), ii), 5) );
    //      end
    //      [~, idx] = inlierCheck(slopes, .1);
    //      stafflineCenter = stafflineCenter(idx);
    //      intercepts = zeros(length(idx), 1);
    //      for ii = 1:length(intercepts)
    //          intercepts(ii) = stafflineCenter{ii}(2);
    //      end
    //      [~, idx] = sort(intercepts, 'ascend');
    //      staffInfo.centerLine = stafflineCenter(idx);
    //      staffInfo.lineWidth = round(widths);
    //      staffInfo.lineSpace = round(spaces);
    cv::Mat pts(boxes.rows, 2, CV_32SC1);
    for (int i = 0; i < boxes.rows; i++) {
        pts.at<int>(i, 0) = cvRound(boxes.at<double>(i, 0));
        pts.at<int>(i, 1) = cvRound(.5*boxes.at<double>(i, 1)+.5*boxes.at<double>(i, 2));
    }
    std::vector<std::vector<int>> lines = [self clusterLinesWithPoints:pts];
    cv::Mat staffLineCenters(0, 2, CV_64FC1);
    cv::Mat slopes((int)lines.size(), 1, CV_64FC1);
    cv::Mat widths((int)lines.size(), 1, CV_64FC1);
    cv::Mat spaces((int)lines.size(), 1, CV_64FC1);
    for (int i = 0; i < lines.size(); i++) {
        cv::Mat X = [MatTools getRowsVec:lines[i] OfMat:pts].col(0);
        cv::Mat y = [MatTools getRowsVec:lines[i] OfMat:pts].col(1);
        X.convertTo(X, CV_64FC1);
        y.convertTo(y, CV_64FC1);
        X = X.t();
        cv::Mat onesVec = cv::Mat::ones(X.size(), X.type());
        X.push_back(onesVec);
        X = X.t();
        cv::Mat w = (X.t()*X).inv()*X.t()*y;
        w = w.t();
        staffLineCenters.push_back(w.clone());
        slopes.at<double>(i, 0) = w.at<double>(0, 0);
        widths.at<double>(i, 0) = [MatTools meanOf2DMat:
                                   [MatTools getRowsVec:lines[i] OfMat:boxes].col(3)].at<double>(0, 0);
        spaces.at<double>(i, 0) = [MatTools meanOf2DMat:
                                   [MatTools getRowsVec:lines[i] OfMat:boxes].col(4)].at<double>(0, 0);
    }
    cv::Mat idx = [self inliersCheckWithData:slopes WithThresh:.1];
    cv::Mat intercepts = [MatTools getRows:idx OfMat:staffLineCenters].col(1);
    intercepts = intercepts.t();
    idx = idx.t();
    idx.convertTo(idx, intercepts.type());
    intercepts.push_back(idx);
    intercepts = intercepts.t();
    intercepts = [MatTools sort2DMat:intercepts WithCriterion:SORT_ASCEND AlongWithTheAxis:AXIS_VERTICAL];
    idx = intercepts.col(1);
    idx.convertTo(idx, CV_32SC1);
    staffLineCenters = [MatTools getRows:idx OfMat:staffLineCenters];
    widths = [MatTools getRows:idx OfMat:widths];
    spaces = [MatTools getRows:idx OfMat:spaces];
    staffLines = [[NSMutableArray alloc] initWithCapacity:idx.rows];
    for (int i = 0; i < idx.rows; i++) {
        [staffLines addObject:[[StaffInfo alloc] initWithSlope:staffLineCenters.at<double>(i, 0)
                                                     Intercept:staffLineCenters.at<double>(i, 1)
                                                     LineWidth:cvRound(widths.at<double>(i, 0))
                                                     LineSpace:cvRound(spaces.at<double>(i, 0))]];
    }
    return staffLines;
}

+ (NSArray *)findStafflinesWithImage:(UIImage *)img {
    return [self findStafflinesWithImageData:[MatTools imreadGrayFromUIImage:img]];
}

@end
