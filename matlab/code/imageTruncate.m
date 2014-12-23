function [ im_truncated ] = imageTruncate( im, bounds,  opt)
%IMAGETRUNCATE Summary of this function goes here
%   Detailed explanation goes here
    switch lower(opt)
        case 'vertical'
            opt = 1;
            bounds = round( bounded(bounds, [1 1; size(im, 1) size(im, 1)]) );
        case 'horizontal'
            opt = 0;
            bounds = round( bounded(bounds, [1 1; size(im, 2) size(im, 2)]) );
    end
    
    regionMax = round( max(bounds(:, 2)) );
    regionMin = round( min(bounds(:, 1)) );
    boundsShift = round( bounds - regionMin + 1 );
    if opt
        im_truncated = zeros(regionMax-regionMin+1, size(im, 2), size(im, 3));
        for ii = 1:size(bounds, 1)
            im_truncated(boundsShift(ii, 1):boundsShift(ii, 2), ii, :) = ...
                im(bounds(ii, 1):bounds(ii, 2), ii, :);
        end
    else
        im_truncated = zeros(size(im, 1), regionMax-regionMin+1, size(im, 3));
        for ii = 1:size(bounds, 1)
            im_truncated(ii, boundsShift(ii, 1):boundsShift(ii, 2), :) = ...
                im(ii, bounds(ii, 1):bounds(ii, 2), :);
        end
    end

end

function data = bounded(data, bounds)
    dim = size(data, 2);
    for ii = 1:dim
        maxV = bounds(2, ii);
        minV = bounds(1, ii);
        data(:, ii) = max(data(:, ii), minV);
        data(:, ii) = min(data(:, ii), maxV);
    end
end