function [ inlierData, inlierIdx ] = inlierCheck( data, thresh )
%INLIERCHECK Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        thresh = .3;
    end
    terminated = 0;
    inlier = ones(size(data));
    while ~terminated
        terminated = 1;
        temp = inlier;
        for ii = 1:sum(inlier==1)
            inlierIdx = find(inlier==1);
            leaveOneOutInlier = inlierIdx((1:length(inlierIdx)) ~= ii);
            if thresh*std(data(inlierIdx)) > std( data(leaveOneOutInlier) )
                terminated = 0;
                temp(inlierIdx(ii)) = 0;
            end
        end
        inlier = temp;
    end
    
    inlierIdx = find(inlier == 1);
    inlierData = data(inlierIdx);

end

