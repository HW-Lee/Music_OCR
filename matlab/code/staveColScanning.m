function [ boxes ] = staveColScanning( img_gray )
%STAVECOLSCANNING Summary of this function goes here
%   Detailed explanation goes here
    
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

end

