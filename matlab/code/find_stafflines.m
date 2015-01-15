function [ img_gray, staffInfo ] = find_stafflines( img_gray )
%FIND_STAFFLINES Summary of this function goes here
%   Detailed explanation goes here

    img_gray = imgBinarization(img_gray, .6);
    boxes = staveColScanning(img_gray);
    pts = [boxes(:, 1) mean(boxes(:, 2:3), 2)];
    [lines npts] = clusterLines(pts);
    stafflineCenter = cell(size(lines, 2), 1);
    slopes = zeros(size(lines, 2), 1);
    widths = slopes;
    spaces = slopes;
    for ii = 1:size(lines, 2)
        x = pts(lines(1:npts(ii), ii), 1);
        y = pts(lines(1:npts(ii), ii), 2);
        w = [x ones(length(x), 1)] \ y;
        stafflineCenter{ii} = w;
        slopes(ii) = w(1);
        widths(ii) = mean( boxes(lines(1:npts(ii), ii), 4) );
        spaces(ii) = mean( boxes(lines(1:npts(ii), ii), 5) );
    end
    [~, idx] = inlierCheck(slopes, .1);
    stafflineCenter = stafflineCenter(idx);
    intercepts = zeros(length(idx), 1);
    for ii = 1:length(intercepts)
        intercepts(ii) = stafflineCenter{ii}(2);
    end
    [~, idx] = sort(intercepts, 'ascend');
    staffInfo.centerLine = stafflineCenter(idx);
    staffInfo.lineWidth = round(widths);
    staffInfo.lineSpace = round(spaces);
    
end