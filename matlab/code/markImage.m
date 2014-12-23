function [ im ] = markImage( im, xx, yy, rgb )
%MARKIMAGE Summary of this function goes here
%   Detailed explanation goes here
    if size(im, 3) == 1
        im = gray2rgb(im);
    end
    
    data = [xx(:) yy(:)];
    bounds = [1 1; size(im, 2) size(im, 1)];
    data = bounded(data, bounds);
    xx = round(data(:, 1));
    yy = round(data(:, 2));
    
    yunique = unique(yy);
    for jj = 1:length(yunique)
        for ii = 1:size(im, 3)
            im(yunique(jj), xx(yy==yunique(jj)), ii) = rgb(ii);
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