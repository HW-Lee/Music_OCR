function [ img_gray, staffInfo ] = find_stafflines( img_gray )
%FIND_STAFFLINES Summary of this function goes here
%   Detailed explanation goes here

    range = max(img_gray(:)) - min(img_gray(:));
    img_gray = ( img_gray-min(img_gray(:)) ) / range;
    img_gray = (img_gray < .6);
    boxes = [];
    for ii = 1:round(size(img_gray, 2))
        rowScanned = img_gray(:, ii)';
        crossPts = find(diff(rowScanned).^2 > 0);
        if ~isempty(crossPts)
            intervals = [crossPts(1) diff(crossPts) length(rowScanned)-crossPts(end)];
            intervals = [intervals' [1; crossPts'+1;]];
            idx = 1:length(intervals);
            zerosInterv = intervals( mod(idx, 2) == (rowScanned(crossPts(1))==0), : );
            onesInterv = intervals( mod(idx, 2) == (rowScanned(crossPts(1))==1), : );
            for jj = 1:size(onesInterv, 1)-4
                window = zerosInterv(jj:jj+3, 1);
                if sum( (window - mean(window))/mean(window) < .1 ) == 4
                    v = onesInterv(jj:jj+4, 1);
                    if sum( (v-mean(v))/mean(v) < .5 ) < 5
                        continue;
                    end
                    detectedRegion = [zerosInterv(jj, 2)-mean(window); zerosInterv(jj+3, 2)+2*mean(window)];
                    detectedRegion = max( round(detectedRegion), 1 );
                    detectedRegion = min( round(detectedRegion), length(rowScanned) );
                    region = [(0:5)+detectedRegion(1) (0:5)+detectedRegion(2)];
                    img_gray(region, ii) = 1;
                    
                    % [idx region_min region_max lineWidth lineSpace]
                    boxes = [boxes; ii detectedRegion' mean(v) mean(window)];
                end
            end
        end
    end
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