function [ lineGroup, Npts ] = clusterLines( pts2D )
%CLUSTERLINES Summary of this function goes here
%   Detailed explanation goes here
    scatter(pts2D(:, 1), pts2D(:, 2));
    if isempty(pts2D)
        lineGroup = [];
        Npts = [];
        return;
    end
    pts2D(:, 2) = pts2D(:, 2) / max(pts2D(:, 2));
    idx = unique(pts2D(:, 1));
    idx_cnt = zeros(size(idx));
    for ii = 1:length(idx)
        idx_cnt(ii) = sum(pts2D(:, 1) == idx(ii));
    end
    
    clusterTag = zeros(size(pts2D, 1), 1);
    thresh = .05;
    Ncluster = 1;
    clusterRefs = pts2D(1, 2);
    if idx_cnt(1) > 1
        ptsDiff = diff(pts2D(pts2D(:, 1)==idx(1), 2));
        Ncluster = Ncluster + sum( ptsDiff > thresh );
        clusterTag([1; 1+find(ptsDiff > thresh)]) = (1:Ncluster)';
        clusterRefs = [clusterRefs; pts2D(1+find(ptsDiff > thresh), 2)];
    end
    
    if length(idx_cnt) > 1
        for ii = 2:length(idx_cnt)
            offsetIdx = find(pts2D(:, 1)==idx(ii), 1)-1;
            pts = pts2D(pts2D(:, 1)==idx(ii), 2);
            for jj = 1:length(pts)
                [v, loc] = min( abs(clusterRefs - pts(jj)) );
                if v < thresh
                    clusterTag(offsetIdx+jj) = loc;
                    clusterRefs(loc) = pts(jj);
                else
                    Ncluster = Ncluster + 1;
                    clusterRefs = [clusterRefs; pts(jj)];
                    clusterTag(offsetIdx+jj) = Ncluster;
                end
            end
        end
        range = max(idx)-min(idx);
        maxCnt = 0;
        for ii = 1:Ncluster
            if ( max( pts2D(clusterTag==ii, 1) ) - min( pts2D(clusterTag==ii, 1) ) ) < .2*range
                clusterTag(clusterTag==ii) = 0;
                clusterTag(clusterTag>=ii) = clusterTag(clusterTag>=ii)-1;
            end
            if sum(clusterTag == ii) > maxCnt
                maxCnt = sum(clusterTag == ii);
            end
        end
        Ncluster = max(clusterTag);
        lineGroup = zeros(maxCnt, Ncluster);
        Npts = zeros(Ncluster, 1);
        for ii = 1:Ncluster
            clusterIdx = find(clusterTag==ii);
            if isempty(clusterIdx)
                continue;
            end
            lineGroup(1:length(clusterIdx), ii) = clusterIdx;
            lineGroup(length(clusterIdx):end, ii) = lineGroup(length(clusterIdx), ii);
            Npts(ii) = length(clusterIdx);
        end
    end

end

