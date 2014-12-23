function [ Yproj ] = yAxisProjection( im )
%YAXISPROJECTION Summary of this function goes here
%   Detailed explanation goes here
    range = max(im(:)) - min(im(:));
    im = ( im-min(im(:)) ) / range;
    im = (im < .6);
    yy = sum(im, 2);
    Yproj = ones(size(yy));
    for ii = 5:length(Yproj)-5
        Yproj(ii) = log( sum(yy(ii-2:ii+2).^2) );
    end
end

